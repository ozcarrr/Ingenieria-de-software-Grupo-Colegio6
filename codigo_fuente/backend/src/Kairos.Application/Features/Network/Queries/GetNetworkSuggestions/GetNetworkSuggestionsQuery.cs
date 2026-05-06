using MediatR;

namespace Kairos.Application.Features.Network.Queries.GetNetworkSuggestions;

public record GetNetworkSuggestionsQuery(
    int CurrentUserId,
    int Page     = 1,
    int PageSize = 20) : IRequest<IReadOnlyList<UserSuggestionDto>>;

public record UserSuggestionDto(
    int     Id,
    string  FullName,
    string? Title,
    string? AvatarUrl,
    string? Location,
    string? Bio,
    string? Role,
    int     FollowersCount,
    bool    IsFollowing);
