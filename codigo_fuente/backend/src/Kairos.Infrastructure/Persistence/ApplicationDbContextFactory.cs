// ============================================================
//  Kairos.Infrastructure / Persistence / ApplicationDbContextFactory.cs
//  Crear este archivo en esa ruta.
//  Solo lo usa dotnet ef en tiempo de diseño (migraciones).
//  No afecta el comportamiento en producción.
// ============================================================

using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace Kairos.Infrastructure.Data;

public class ApplicationDbContextFactory : IDesignTimeDbContextFactory<ApplicationDbContext>
{
    public ApplicationDbContext CreateDbContext(string[] args)
    {
        var optionsBuilder = new DbContextOptionsBuilder<ApplicationDbContext>();

        // Esta connection string solo se usa para generar las migraciones.
        // Cuando la app corre de verdad, usa la de appsettings.json.
        optionsBuilder.UseMySql(
            "Server=localhost;Port=3306;Database=kairos;User=kairos_user;Password=kairos2026;",
            ServerVersion.AutoDetect("Server=localhost;Port=3306;Database=kairos;User=kairos_user;Password=kairos2026;")
        );

        return new ApplicationDbContext(optionsBuilder.Options);
    }
}
