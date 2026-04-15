using MediatR;

namespace Kairos.Application.Features.Network.Commands.UnfollowUser;

public record UnfollowUserCommand(int FollowerId, int FollowedId) : IRequest;
