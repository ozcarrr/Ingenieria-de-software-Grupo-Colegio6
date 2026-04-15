using Kairos.Application.Common.Interfaces;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Kairos.Application.Features.Chat.Queries.GetMessages;

public class GetMessagesQueryHandler(IApplicationDbContext db)
    : IRequestHandler<GetMessagesQuery, IReadOnlyList<MessageDto>>
{
    public async Task<IReadOnlyList<MessageDto>> Handle(
        GetMessagesQuery request,
        CancellationToken cancellationToken)
    {
        var uid   = request.CurrentUserId;
        var other = request.OtherUserId;
        var skip  = (request.Page - 1) * request.PageSize;

        var messages = await db.Messages
            .Where(m =>
                (m.SenderId == uid   && m.ReceiverId == other) ||
                (m.SenderId == other && m.ReceiverId == uid))
            .OrderBy(m => m.CreatedAt)
            .Skip(skip)
            .Take(request.PageSize)
            .Select(m => new MessageDto(
                m.Id,
                m.SenderId,
                m.ReceiverId,
                m.Content,
                m.CreatedAt,
                m.IsRead))
            .ToListAsync(cancellationToken);

        // Mark received messages as read
        var unread = await db.Messages
            .Where(m => m.SenderId == other && m.ReceiverId == uid && !m.IsRead)
            .ToListAsync(cancellationToken);

        foreach (var m in unread) m.IsRead = true;
        if (unread.Count > 0)
            await db.SaveChangesAsync(cancellationToken);

        return messages;
    }
}
