using MediatR;

namespace Kairos.Application.Features.Posts.Commands.UpdatePost;

public record UpdatePostCommand(int PostId, int RequesterId, string Content) : IRequest;
