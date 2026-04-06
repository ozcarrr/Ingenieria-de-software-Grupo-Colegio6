using MediatR;

namespace Kairos.Application.Features.Posts.Commands.CreatePost;

public record CreatePostCommand(
    int AuthorId,
    string Content,
    string PostType,
    string? ImageUrl,
    string? EventDate) : IRequest<int>;
