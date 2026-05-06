using Kairos.Application.Common.Exceptions;
using Kairos.Application.Common.Interfaces;
using MediatR;

namespace Kairos.Application.Features.Posts.Commands.DeletePost;

public class DeletePostCommandHandler(IApplicationDbContext db)
    : IRequestHandler<DeletePostCommand>
{
    public async Task Handle(DeletePostCommand request, CancellationToken cancellationToken)
    {
        var post = await db.Posts.FindAsync([request.PostId], cancellationToken)
            ?? throw new KeyNotFoundException("Publicación no encontrada.");

        var isStaff = request.RequesterRole.Equals("staff", StringComparison.OrdinalIgnoreCase);
        if (!isStaff && post.AuthorId != request.RequesterId)
            throw new ForbiddenException("No tienes permiso para eliminar esta publicación.");

        db.Posts.Remove(post);
        await db.SaveChangesAsync(cancellationToken);
    }
}
