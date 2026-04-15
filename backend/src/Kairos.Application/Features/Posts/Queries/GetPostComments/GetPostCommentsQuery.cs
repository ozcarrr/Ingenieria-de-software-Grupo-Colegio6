using Kairos.Application.Features.Posts.Commands.AddComment;
using MediatR;

namespace Kairos.Application.Features.Posts.Queries.GetPostComments;

public record GetPostCommentsQuery(int PostId, int Page = 1, int PageSize = 20)
    : IRequest<IReadOnlyList<CommentDto>>;
