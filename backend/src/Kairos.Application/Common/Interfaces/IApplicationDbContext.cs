using Kairos.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace Kairos.Application.Common.Interfaces;

public interface IApplicationDbContext
{
    DbSet<User> Users { get; }
    DbSet<Post> Posts { get; }
    DbSet<UserActivity> UserActivities { get; }

    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}
