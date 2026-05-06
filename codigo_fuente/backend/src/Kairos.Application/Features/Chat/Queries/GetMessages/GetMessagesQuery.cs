using MediatR;

namespace Kairos.Application.Features.Chat.Queries.GetMessages;

public record GetMessagesQuery(
    int CurrentUserId,
    int OtherUserId,
    int Page     = 1,
    int PageSize = 40) : IRequest<IReadOnlyList<MessageDto>>;

public record MessageDto(
    int      Id,
    int      SenderId,
    int      ReceiverId,
    string   Content,
    DateTime CreatedAt,
    bool     IsRead);
