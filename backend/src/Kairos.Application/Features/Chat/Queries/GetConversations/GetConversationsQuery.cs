using MediatR;

namespace Kairos.Application.Features.Chat.Queries.GetConversations;

public record GetConversationsQuery(int UserId) : IRequest<IReadOnlyList<ConversationDto>>;

public record ConversationDto(
    int      OtherUserId,
    string   OtherUserName,
    string?  OtherUserAvatarUrl,
    string?  OtherUserTitle,
    string   LastMessage,
    DateTime LastMessageAt,
    bool     HasUnread);
