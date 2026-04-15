using Kairos.Application.Common.Interfaces;
using Kairos.Domain.Entities;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Kairos.Application.Features.Network.Commands.FollowUser;

public class FollowUserCommandHandler(IApplicationDbContext db)
    : IRequestHandler<FollowUserCommand>
{
    public async Task Handle(FollowUserCommand request, CancellationToken cancellationToken)
    {
        if (request.FollowerId == request.FollowedId)
            throw new InvalidOperationException("No puedes seguirte a ti mismo.");

        var exists = await db.Follows.AnyAsync(
            f => f.FollowerId == request.FollowerId && f.FollowedId == request.FollowedId,
            cancellationToken);

        if (exists) return; // Already following — idempotent

        db.Follows.Add(new Follow
        {
            FollowerId = request.FollowerId,
            FollowedId = request.FollowedId,
        });

        await db.SaveChangesAsync(cancellationToken);
    }
}
