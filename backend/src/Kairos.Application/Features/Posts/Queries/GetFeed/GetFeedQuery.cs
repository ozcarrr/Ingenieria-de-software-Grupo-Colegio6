using MediatR;

namespace Kairos.Application.Features.Posts.Queries.GetFeed;

public record GetFeedQuery(int Page = 1, int PageSize = 20) : IRequest<GetFeedResult>;

public record PostDto(
    int Id,
    string AuthorName,
    string? AuthorProfilePictureUrl,
    string Content,
    string PostType,
    string? ImageUrl,
    string? EventDate,
    int LikesCount,
    int CommentsCount,
    DateTime CreatedAt);

public record GetFeedResult(IReadOnlyList<PostDto> Posts, int TotalCount, bool HasNextPage);
