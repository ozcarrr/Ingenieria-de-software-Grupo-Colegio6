using Kairos.Application.Common.Exceptions;
using Kairos.Application.Common.Interfaces;
using MediatR;

namespace Kairos.Application.Features.Posts.Commands.UpdatePost;

public class UpdatePostCommandHandler(IApplicationDbContext db)
    : IRequestHandler<UpdatePostCommand>
{
    public async Task Handle(UpdatePostCommand request, CancellationToken cancellationToken)
    {
        var post = await db.Posts.FindAsync([request.PostId], cancellationToken)
            ?? throw new KeyNotFoundException("Publicación no encontrada.");

        if (post.AuthorId != request.RequesterId)
            throw new ForbiddenException("Solo puedes editar tus propias publicaciones.");

        post.Content = request.Content;
        await db.SaveChangesAsync(cancellationToken);
    }
}
