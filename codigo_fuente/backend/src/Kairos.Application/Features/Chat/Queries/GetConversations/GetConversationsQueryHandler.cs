using Kairos.Application.Common.Interfaces;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Kairos.Application.Features.Chat.Queries.GetConversations;

public class GetConversationsQueryHandler(IApplicationDbContext db)
    : IRequestHandler<GetConversationsQuery, IReadOnlyList<ConversationDto>>
{
    public async Task<IReadOnlyList<ConversationDto>> Handle(
        GetConversationsQuery request,
        CancellationToken cancellationToken)
    {
        var userId = request.UserId;

        // Get all messages where this user is sender or receiver
        var messages = await db.Messages
            .Where(m => m.SenderId == userId || m.ReceiverId == userId)
            .Include(m => m.Sender)
            .Include(m => m.Receiver)
            .OrderByDescending(m => m.CreatedAt)
            .ToListAsync(cancellationToken);

        // Group by the other participant and keep only the latest message per conversation
        var conversations = messages
            .GroupBy(m => m.SenderId == userId ? m.ReceiverId : m.SenderId)
            .Select(g =>
            {
                var latest     = g.First();
                var otherUser  = latest.SenderId == userId ? latest.Receiver : latest.Sender;
                var hasUnread  = g.Any(m => m.ReceiverId == userId && !m.IsRead);
                return new ConversationDto(
                    otherUser.Id,
                    otherUser.FullName,
                    otherUser.ProfilePictureUrl,
                    otherUser.Institution,
                    latest.Content,
                    latest.CreatedAt,
                    hasUnread);
            })
            .OrderByDescending(c => c.LastMessageAt)
            .ToList();

        return conversations;
    }
}
