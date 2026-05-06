using Kairos.Application.Common.Interfaces;
using Kairos.Application.Features.Chat.Queries.GetMessages;
using Kairos.Domain.Entities;
using MediatR;

namespace Kairos.Application.Features.Chat.Commands.SendMessage;

public class SendMessageCommandHandler(IApplicationDbContext db)
    : IRequestHandler<SendMessageCommand, MessageDto>
{
    public async Task<MessageDto> Handle(SendMessageCommand request, CancellationToken cancellationToken)
    {
        var message = new Message
        {
            SenderId   = request.SenderId,
            ReceiverId = request.ReceiverId,
            Content    = request.Content,
        };

        db.Messages.Add(message);
        await db.SaveChangesAsync(cancellationToken);

        return new MessageDto(
            message.Id,
            message.SenderId,
            message.ReceiverId,
            message.Content,
            message.CreatedAt,
            message.IsRead);
    }
}
