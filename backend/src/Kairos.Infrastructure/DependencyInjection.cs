using Kairos.Application.Common.Interfaces;
using Kairos.Infrastructure.Persistence;
using Kairos.Infrastructure.Services;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace Kairos.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        // MySQL via Pomelo
        var connectionString = configuration.GetConnectionString("DefaultConnection")
            ?? throw new InvalidOperationException("Connection string 'DefaultConnection' is not configured.");

        services.AddDbContext<ApplicationDbContext>(options =>
            options.UseMySql(connectionString, ServerVersion.AutoDetect(connectionString)));

        services.AddScoped<IApplicationDbContext>(sp =>
            sp.GetRequiredService<ApplicationDbContext>());

        // Azure Blob
        services.Configure<AzureBlobOptions>(configuration.GetSection(AzureBlobOptions.Section));
        services.AddScoped<IStorageService, StorageService>();

        // JWT
        services.Configure<JwtOptions>(configuration.GetSection(JwtOptions.Section));
        services.AddScoped<IJwtService, JwtService>();

        // PDF Reports
        services.AddSingleton<IReportGeneratorService, ReportGeneratorService>();

        return services;
    }
}
