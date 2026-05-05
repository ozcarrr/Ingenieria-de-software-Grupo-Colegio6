using System.Net;
using System.Security.Claims;
using System.Text;
using System.Threading.RateLimiting;
using FluentValidation;
using Kairos.API.Hubs;
using Kairos.API.Middleware;
using Kairos.API.RateLimit;
using Kairos.Application.Common.Behaviors;
using Kairos.Application.Features.Auth.Commands.Login;
using Kairos.Infrastructure;
using Kairos.Infrastructure.Persistence;
using MediatR;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

// ── Infrastructure (MySQL, Blob, JWT, PDF) ────────────────────────────────────
builder.Services.AddInfrastructure(builder.Configuration, builder.Environment);

// ── Application (MediatR + FluentValidation) ──────────────────────────────────
builder.Services.AddMediatR(cfg =>
{
    cfg.RegisterServicesFromAssemblyContaining<LoginCommand>();
    cfg.AddOpenBehavior(typeof(ValidationBehavior<,>));
});

builder.Services.AddValidatorsFromAssemblyContaining<LoginCommand>();

// ── Authentication (JWT Bearer) ───────────────────────────────────────────────
var jwtKey = builder.Configuration["Jwt:SecretKey"]
    ?? throw new InvalidOperationException("JWT secret key is not configured.");

builder.Services
    .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(opts =>
    {
        opts.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer           = true,
            ValidateAudience         = true,
            ValidateLifetime         = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer              = builder.Configuration["Jwt:Issuer"],
            ValidAudience            = builder.Configuration["Jwt:Audience"],
            IssuerSigningKey         = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey))
        };

        // Allow JWT via SignalR query string
        opts.Events = new JwtBearerEvents
        {
            OnMessageReceived = ctx =>
            {
                var token = ctx.Request.Query["access_token"];
                if (!string.IsNullOrEmpty(token) &&
                    ctx.Request.Path.StartsWithSegments("/hubs"))
                {
                    ctx.Token = token;
                }
                return Task.CompletedTask;
            }
        };
    });

builder.Services.AddAuthorization();

// ── SignalR ───────────────────────────────────────────────────────────────────
builder.Services.AddSignalR();

// ── Controllers + Swagger ────────────────────────────────────────────────────
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "Kairos API", Version = "v1" });

    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header
    });

    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "Bearer" }
            },
            []
        }
    });
});

// ── CORS ──────────────────────────────────────────────────────────────────────
builder.Services.AddCors(opts =>
    opts.AddDefaultPolicy(policy =>
        policy.WithOrigins(
                  "https://statuesque-llama-6b5882.netlify.app",
                  "http://localhost:3000",
                  "http://localhost:5000",
                  "http://localhost:8080")
              .AllowAnyHeader()
              .AllowAnyMethod()
              .AllowCredentials()));

// ── Rate Limiting ─────────────────────────────────────────────────────────────
builder.Services.AddRateLimiter(options =>
{
    // Login: 5 attempts per 15 minutes, keyed by client IP (localhost is exempt)
    options.AddPolicy("login", context =>
    {
        var ip = context.Connection.RemoteIpAddress;
        if (ip != null && IPAddress.IsLoopback(ip))
            return RateLimitPartition.GetNoLimiter(ip.ToString());

        return RateLimitPartition.GetFixedWindowLimiter(
            partitionKey: ip?.ToString() ?? "unknown",
            factory: _ => new FixedWindowRateLimiterOptions
            {
                PermitLimit = 5,
                Window = TimeSpan.FromMinutes(15),
                QueueLimit = 0
            });
    });

    // CV generation: 5 per 15 min + 20 s minimum gap, keyed by authenticated user ID
    options.AddPolicy<string>("curriculum", context =>
    {
        var userId = context.User.FindFirstValue(ClaimTypes.NameIdentifier) ?? "anon";
        return RateLimitPartition.Get(userId, _ => new CurriculumRateLimiter());
    });

    options.RejectionStatusCode = StatusCodes.Status429TooManyRequests;
});

var app = builder.Build();

// ── Seed datos de testeo (solo en desarrollo) ─────────────────────────────────
if (app.Environment.IsDevelopment())
    await DevDataSeeder.SeedAsync(app.Services);

// ── Middleware pipeline ────────────────────────────────────────────────────────
app.UseCors();
app.UseStaticFiles(); // serves wwwroot/uploads/* in dev

if (!app.Environment.IsDevelopment())
    app.UseHttpsRedirection();

app.UseMiddleware<ExceptionHandlingMiddleware>();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseAuthentication();
app.UseRateLimiter();
app.UseAuthorization();

app.MapControllers();
app.MapHub<SocialHub>("/hubs/chat");
app.MapHub<SocialHub>("/hubs/social");

app.Run();
