using Kairos.Application.Common.Interfaces;
using Kairos.Application.Features.Network.Queries.GetNetworkSuggestions;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Kairos.Application.Features.Network.Queries.GetFollowing;

public class GetFollowingQueryHandler(IApplicationDbContext db)
    : IRequestHandler<GetFollowingQuery, IReadOnlyList<UserSuggestionDto>>
{
    public async Task<IReadOnlyList<UserSuggestionDto>> Handle(
        GetFollowingQuery request,
        CancellationToken cancellationToken)
    {
        return await db.Follows
            .Where(f => f.FollowerId == request.CurrentUserId)
            .Include(f => f.Followed)
                .ThenInclude(u => u.Followers)
            .Select(f => new UserSuggestionDto(
                f.Followed.Id,
                f.Followed.FullName,
                f.Followed.Institution,
                f.Followed.ProfilePictureUrl,
                null,
                f.Followed.Bio,
                f.Followed.Role,
                f.Followed.Followers.Count,
                true))
            .ToListAsync(cancellationToken);
    }
}
