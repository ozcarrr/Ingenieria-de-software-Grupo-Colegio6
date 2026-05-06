using Kairos.Application.Common.Interfaces;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Kairos.Application.Features.Network.Queries.GetNetworkSuggestions;

public class GetNetworkSuggestionsQueryHandler(IApplicationDbContext db)
    : IRequestHandler<GetNetworkSuggestionsQuery, IReadOnlyList<UserSuggestionDto>>
{
    public async Task<IReadOnlyList<UserSuggestionDto>> Handle(
        GetNetworkSuggestionsQuery request,
        CancellationToken cancellationToken)
    {
        // IDs the current user already follows
        var alreadyFollowing = (await db.Follows
            .Where(f => f.FollowerId == request.CurrentUserId)
            .Select(f => f.FollowedId)
            .ToListAsync(cancellationToken))
            .ToHashSet();

        var skip = (request.Page - 1) * request.PageSize;

        // Suggest users not yet followed (excluding the user themselves)
        var suggestions = await db.Users
            .Where(u => u.Id != request.CurrentUserId && !alreadyFollowing.Contains(u.Id))
            .OrderByDescending(u => u.Followers.Count)
            .Skip(skip)
            .Take(request.PageSize)
            .Select(u => new UserSuggestionDto(
                u.Id,
                u.FullName,
                u.Institution,
                u.ProfilePictureUrl,
                null,
                u.Bio,
                u.Role,
                u.Followers.Count,
                false))
            .ToListAsync(cancellationToken);

        return suggestions;
    }
}
