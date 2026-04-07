// ============================================================
//  Kairos.Infrastructure / DependencyInjection.cs
//  Llamar el metodo "builder.Services.AddInfrastructure(builder.Configuration)" desde Program.cs
// ============================================================

using Kairos.Application.Common.Interfaces;
using Kairos.Infrastructure.Data;
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

        return services;
    }
}
