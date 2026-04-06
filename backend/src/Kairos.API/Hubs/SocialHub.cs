using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;

namespace Kairos.API.Hubs;

[Authorize]
public class SocialHub : Hub
{
    // ── Notifications ──────────────────────────────────────────────────────────

    /// <summary>Called by the server to push a like notification to the post author.</summary>
    public async Task NotifyLike(string targetUserId, int postId, string likedByName)
    {
        await Clients.User(targetUserId).SendAsync("ReceiveLike", new
        {
            postId,
            likedByName,
            timestamp = DateTime.UtcNow
        });
    }

    /// <summary>Called by the server to push a follow notification.</summary>
    public async Task NotifyFollow(string targetUserId, string followerName)
    {
        await Clients.User(targetUserId).SendAsync("ReceiveFollow", new
        {
            followerName,
            timestamp = DateTime.UtcNow
        });
    }

    // ── Comment Sections (Groups) ───────────────────────────────────────────────

    /// <summary>Join the SignalR group for a specific post's comment section.</summary>
    public async Task JoinPostComments(int postId)
    {
        await Groups.AddToGroupAsync(Context.ConnectionId, PostGroup(postId));
    }

    /// <summary>Leave the comment section group for a post.</summary>
    public async Task LeavePostComments(int postId)
    {
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, PostGroup(postId));
    }

    /// <summary>Broadcast a new comment to everyone viewing that post.</summary>
    public async Task SendComment(int postId, string content)
    {
        var userId = Context.UserIdentifier ?? "unknown";

        await Clients.Group(PostGroup(postId)).SendAsync("ReceiveComment", new
        {
            postId,
            authorId = userId,
            content,
            timestamp = DateTime.UtcNow
        });
    }

    // ── Typing indicator ───────────────────────────────────────────────────────

    /// <summary>Broadcast typing indicator to everyone in the post's comment section.</summary>
    public async Task SendTyping(int postId)
    {
        var userId = Context.UserIdentifier ?? "unknown";

        await Clients.OthersInGroup(PostGroup(postId)).SendAsync("UserTyping", new
        {
            postId,
            userId,
            timestamp = DateTime.UtcNow
        });
    }

    // ──────────────────────────────────────────────────────────────────────────

    private static string PostGroup(int postId) => $"post-comments-{postId}";
}
