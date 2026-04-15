using Kairos.Application.Common.Interfaces;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Kairos.Application.Features.Curriculum.Queries.GenerateCurriculum;

public class GenerateCurriculumQueryHandler(IApplicationDbContext db, ICurriculumGenerator generator)
    : IRequestHandler<GenerateCurriculumQuery, byte[]>
{
    public async Task<byte[]> Handle(GenerateCurriculumQuery request, CancellationToken cancellationToken)
    {
        var user = await db.Users
            .FirstOrDefaultAsync(u => u.Id == request.UserId, cancellationToken)
            ?? throw new KeyNotFoundException($"Usuario {request.UserId} no encontrado.");

        var activities = await db.UserActivities
            .Where(a => a.UserId == request.UserId)
            .OrderByDescending(a => a.CreatedAt)
            .ToListAsync(cancellationToken);

        return generator.Generate(user, activities);
    }
}
