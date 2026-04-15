using Kairos.Application.Common.Interfaces;
using Kairos.Domain.Entities;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Kairos.Application.Features.Posts.Commands.LikePost;

public class LikePostCommandHandler(IApplicationDbContext db)
    : IRequestHandler<LikePostCommand, int>
{
    public async Task<int> Handle(LikePostCommand request, CancellationToken cancellationToken)
    {
        var post = await db.Posts.FindAsync([request.PostId], cancellationToken)
            ?? throw new KeyNotFoundException($"Post {request.PostId} no encontrado.");

        var existing = await db.Likes
            .FirstOrDefaultAsync(l => l.PostId == request.PostId && l.UserId == request.UserId,
                cancellationToken);

        if (existing is not null)
        {
            // Already liked — remove the like (toggle off)
            db.Likes.Remove(existing);
            post.LikesCount = Math.Max(0, post.LikesCount - 1);
        }
        else
        {
            db.Likes.Add(new Like { PostId = request.PostId, UserId = request.UserId });
            post.LikesCount += 1;
        }

        await db.SaveChangesAsync(cancellationToken);
        return post.LikesCount;
    }
}
