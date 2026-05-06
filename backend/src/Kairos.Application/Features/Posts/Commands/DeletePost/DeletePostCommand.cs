using MediatR;

namespace Kairos.Application.Features.Posts.Commands.DeletePost;

public record DeletePostCommand(int PostId, int RequesterId, string RequesterRole) : IRequest;
