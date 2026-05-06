using Kairos.Application.Common.Interfaces;
using Kairos.Domain.Entities;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Kairos.Application.Features.Posts.Commands.AddComment;

public class AddCommentCommandHandler(IApplicationDbContext db)
    : IRequestHandler<AddCommentCommand, CommentDto>
{
    public async Task<CommentDto> Handle(AddCommentCommand request, CancellationToken cancellationToken)
    {
        var post = await db.Posts.FindAsync([request.PostId], cancellationToken)
            ?? throw new KeyNotFoundException($"Post {request.PostId} no encontrado.");

        var author = await db.Users.FindAsync([request.AuthorId], cancellationToken)
            ?? throw new KeyNotFoundException($"Usuario {request.AuthorId} no encontrado.");

        var comment = new Comment
        {
            PostId   = request.PostId,
            AuthorId = request.AuthorId,
            Content  = request.Content,
        };

        db.Comments.Add(comment);
        post.CommentsCount += 1;
        await db.SaveChangesAsync(cancellationToken);

        return new CommentDto(
            comment.Id,
            comment.PostId,
            comment.AuthorId,
            author.FullName,
            author.ProfilePictureUrl,
            comment.Content,
            comment.CreatedAt);
    }
}
