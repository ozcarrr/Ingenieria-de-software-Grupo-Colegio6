using Kairos.Application.Common.Interfaces;
using Kairos.Application.Features.Posts.Commands.AddComment;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Kairos.Application.Features.Posts.Queries.GetPostComments;

public class GetPostCommentsQueryHandler(IApplicationDbContext db)
    : IRequestHandler<GetPostCommentsQuery, IReadOnlyList<CommentDto>>
{
    public async Task<IReadOnlyList<CommentDto>> Handle(
        GetPostCommentsQuery request,
        CancellationToken cancellationToken)
    {
        var skip = (request.Page - 1) * request.PageSize;

        return await db.Comments
            .Where(c => c.PostId == request.PostId)
            .Include(c => c.Author)
            .OrderBy(c => c.CreatedAt)
            .Skip(skip)
            .Take(request.PageSize)
            .Select(c => new CommentDto(
                c.Id,
                c.PostId,
                c.AuthorId,
                c.Author.FullName,
                c.Author.ProfilePictureUrl,
                c.Content,
                c.CreatedAt))
            .ToListAsync(cancellationToken);
    }
}
