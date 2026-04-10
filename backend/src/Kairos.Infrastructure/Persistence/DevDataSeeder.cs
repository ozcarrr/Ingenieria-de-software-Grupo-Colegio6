using Kairos.Domain.Entities;
using Kairos.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace Kairos.Infrastructure.Persistence;

public static class DevDataSeeder
{
    public static async Task SeedAsync(IServiceProvider services)
    {
        using var scope = services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();

        await db.Database.MigrateAsync();

        // ── Usuarios de testeo ──────────────────────────────────────────────
        var testUsers = new[]
        {
            new
            {
                Username = "kairos_user1",
                Email    = "kairos_user1@kairos.cl",
                Password = "Kairos2026!",
                FullName = "Usuario Estudiante",
                Role     = "student",
                Institution = "Liceo Técnico Cardenal José María Caro",
            },
            new
            {
                Username = "kairos_user2",
                Email    = "kairos_user2@kairos.cl",
                Password = "Kairos2026!",
                FullName = "Usuario Staff",
                Role     = "staff",
                Institution = "Liceo Técnico Cardenal José María Caro",
            },
        };

        foreach (var seed in testUsers)
        {
            var exists = await db.Users.AnyAsync(u => u.Username == seed.Username);
            if (exists) continue;

            db.Users.Add(new User
            {
                Username    = seed.Username,
                Email       = seed.Email,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(seed.Password),
                FullName    = seed.FullName,
                Role        = seed.Role,
                Institution = seed.Institution,
            });
        }

        await db.SaveChangesAsync();
    }
}
