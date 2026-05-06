using MediatR;

namespace Kairos.Application.Features.Posts.Commands.AddComment;

public record AddCommentCommand(int PostId, int AuthorId, string Content) : IRequest<CommentDto>;

public record CommentDto(
    int      Id,
    int      PostId,
    int      AuthorId,
    string   AuthorName,
    string?  AuthorAvatarUrl,
    string   Content,
    DateTime CreatedAt);
