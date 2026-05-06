using Kairos.Application.Common.Interfaces;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Kairos.Application.Features.Network.Commands.UnfollowUser;

public class UnfollowUserCommandHandler(IApplicationDbContext db)
    : IRequestHandler<UnfollowUserCommand>
{
    public async Task Handle(UnfollowUserCommand request, CancellationToken cancellationToken)
    {
        var follow = await db.Follows.FirstOrDefaultAsync(
            f => f.FollowerId == request.FollowerId && f.FollowedId == request.FollowedId,
            cancellationToken);

        if (follow is null) return; // Already not following — idempotent

        db.Follows.Remove(follow);
        await db.SaveChangesAsync(cancellationToken);
    }
}
