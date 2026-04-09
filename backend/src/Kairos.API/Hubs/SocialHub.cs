using Microsoft.AspNetCore.SignalR;

namespace Kairos.API.Hubs;

/// <summary>
/// Real-time chat hub.
/// Each conversation between two users is a SignalR Group whose name is derived
/// deterministically from the two participant IDs (sorted + joined), so both
/// sides always compute the same group name independently.
///
/// Flow:
///   1. Client calls JoinConversation(myId, peerId)  → added to the group
///   2. Client calls SendMessage(senderId, peerId, content) → broadcast to group
///   3. Client calls SendTyping(senderId, peerId)     → broadcast to *others* only
///   4. Client calls LeaveConversation(myId, peerId)  → removed from the group
/// </summary>
public class ChatHub : Hub
{
    // ── Internal helpers ───────────────────────────────────────────────────────

    /// <summary>
    /// Returns a canonical group name for a conversation between two users.
    /// Sorting ensures userA_userB == userB_userA.
    /// </summary>
    private static string ConversationGroup(string userA, string userB)
    {
        var ids = new[] { userA, userB };
        Array.Sort(ids, StringComparer.Ordinal);
        return $"chat_{ids[0]}_{ids[1]}";
    }

    // ── Hub methods (invoked by clients) ───────────────────────────────────────

    /// <summary>Add the caller's connection to the conversation group.</summary>
    public async Task JoinConversation(string myId, string peerId)
    {
        var group = ConversationGroup(myId, peerId);
        await Groups.AddToGroupAsync(Context.ConnectionId, group);
    }

    /// <summary>Remove the caller's connection from the conversation group.</summary>
    public async Task LeaveConversation(string myId, string peerId)
    {
        var group = ConversationGroup(myId, peerId);
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, group);
    }

    /// <summary>
    /// Send a chat message. Both participants receive the "ReceiveMessage" event,
    /// so the sender gets confirmation and the peer gets the new message.
    /// </summary>
    public async Task SendMessage(string senderId, string peerId, string content)
    {
        if (string.IsNullOrWhiteSpace(content)) return;

        var group = ConversationGroup(senderId, peerId);

        await Clients.Group(group).SendAsync("ReceiveMessage", new
        {
            senderId,
            content,
            timestamp = DateTime.UtcNow.ToString("HH:mm"),
        });
    }

    /// <summary>
    /// Broadcast a typing indicator to the *other* participant only.
    /// </summary>
    public async Task SendTyping(string senderId, string peerId)
    {
        var group = ConversationGroup(senderId, peerId);

        await Clients.OthersInGroup(group).SendAsync("UserTyping", new
        {
            senderId,
        });
    }
}
