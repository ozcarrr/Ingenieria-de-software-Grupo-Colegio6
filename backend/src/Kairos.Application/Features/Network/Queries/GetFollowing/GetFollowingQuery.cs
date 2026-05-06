using Kairos.Application.Features.Network.Queries.GetNetworkSuggestions;
using MediatR;

namespace Kairos.Application.Features.Network.Queries.GetFollowing;

public record GetFollowingQuery(int CurrentUserId) : IRequest<IReadOnlyList<UserSuggestionDto>>;
