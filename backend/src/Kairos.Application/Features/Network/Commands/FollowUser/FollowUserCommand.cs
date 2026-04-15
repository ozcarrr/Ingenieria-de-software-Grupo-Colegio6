using MediatR;

namespace Kairos.Application.Features.Network.Commands.FollowUser;

public record FollowUserCommand(int FollowerId, int FollowedId) : IRequest;
