using Kairos.Application.Features.Chat.Queries.GetMessages;
using MediatR;

namespace Kairos.Application.Features.Chat.Commands.SendMessage;

public record SendMessageCommand(
    int    SenderId,
    int    ReceiverId,
    string Content) : IRequest<MessageDto>;
