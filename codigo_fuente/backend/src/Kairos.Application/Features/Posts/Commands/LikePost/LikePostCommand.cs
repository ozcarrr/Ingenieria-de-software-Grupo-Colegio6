using MediatR;

namespace Kairos.Application.Features.Posts.Commands.LikePost;

/// <summary>Toggle a like on a post. Returns the new LikesCount.</summary>
public record LikePostCommand(int PostId, int UserId) : IRequest<int>;
