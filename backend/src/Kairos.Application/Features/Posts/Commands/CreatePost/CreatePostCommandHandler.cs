using Kairos.Application.Common.Interfaces;
using Kairos.Domain.Entities;
using MediatR;

namespace Kairos.Application.Features.Posts.Commands.CreatePost;

public class CreatePostCommandHandler(IApplicationDbContext db)
    : IRequestHandler<CreatePostCommand, int>
{
    public async Task<int> Handle(CreatePostCommand request, CancellationToken cancellationToken)
    {
        var postType = Enum.TryParse<PostType>(request.PostType, ignoreCase: true, out var parsed)
            ? parsed
            : PostType.Regular;

        var post = new Post
        {
            AuthorId = request.AuthorId,
            Content = request.Content,
            Type = postType,
            ImageUrl = request.ImageUrl,
            EventDate = request.EventDate
        };

        db.Posts.Add(post);

        db.UserActivities.Add(new UserActivity
        {
            UserId = request.AuthorId,
            ActivityType = ActivityType.PostCreated,
            Description = $"Publicó: \"{request.Content[..Math.Min(60, request.Content.Length)]}...\""
        });

        await db.SaveChangesAsync(cancellationToken);
        return post.Id;
    }
}
