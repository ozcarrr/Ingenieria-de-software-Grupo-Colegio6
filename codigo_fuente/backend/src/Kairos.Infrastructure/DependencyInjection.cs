// ============================================================
//  Kairos.Infrastructure / DependencyInjection.cs
//  Llamar el metodo "builder.Services.AddInfrastructure(builder.Configuration)" desde Program.cs
// ============================================================

using Kairos.Application.Common.Interfaces;
using Kairos.Infrastructure.Data;
using Kairos.Infrastructure.Services;
using Microsoft.AspNetCore.Hosting;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

namespace Kairos.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(
        this IServiceCollection services,
        IConfiguration configuration,
        IWebHostEnvironment env)
    {
        var connectionString = configuration.GetConnectionString("DefaultConnection")
            ?? throw new InvalidOperationException("No se encontró 'DefaultConnection' en appsettings.json");

        services.AddDbContext<ApplicationDbContext>(options =>
            options.UseMySql(
                connectionString,
                ServerVersion.AutoDetect(connectionString),
                mysqlOptions =>
                {
                    // Reintentar hasta 3 veces si la BD no está disponible al arrancar
                    mysqlOptions.EnableRetryOnFailure(
                        maxRetryCount: 3,
                        maxRetryDelay: TimeSpan.FromSeconds(5),
                        errorNumbersToAdd: null);
                }
            )
        );

        // Registrar la interfaz → implementación concreta
        // Cuando algo pide IApplicationDbContext, DI entrega ApplicationDbContext
        services.AddScoped<IApplicationDbContext>(
            provider => provider.GetRequiredService<ApplicationDbContext>());

        // JWT
        services.Configure<JwtOptions>(configuration.GetSection(JwtOptions.Section));
        services.AddScoped<IJwtService, JwtService>();

        // Storage: local filesystem in dev, Azure Blob in production
        services.Configure<AzureBlobOptions>(configuration.GetSection(AzureBlobOptions.Section));
        if (env.IsDevelopment())
            services.AddScoped<IStorageService, LocalStorageService>();
        else
            services.AddScoped<IStorageService, StorageService>();

        // PDF generation
        services.AddScoped<ICurriculumGenerator, CurriculumGenerator>();
        services.AddScoped<IReportGeneratorService, ReportGeneratorService>();

        return services;
    }
}
