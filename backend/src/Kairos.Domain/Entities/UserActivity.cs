namespace Kairos.Domain.Entities;

public enum ActivityType { PostCreated, PostLiked, CommentPosted, UserFollowed, ProfileUpdated }

public class UserActivity
{
    public int Id { get; set; }
    public ActivityType ActivityType { get; set; }
    public string Description { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public int UserId { get; set; }
    public User User { get; set; } = null!;
}
