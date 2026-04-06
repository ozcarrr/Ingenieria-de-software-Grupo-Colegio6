namespace Kairos.Domain.Entities;

public enum PostType { Regular, Event }

public class Post
{
    public int Id { get; set; }
    public string Content { get; set; } = string.Empty;
    public PostType Type { get; set; } = PostType.Regular;
    public string? ImageUrl { get; set; }
    public string? EventDate { get; set; }
    public int LikesCount { get; set; }
    public int CommentsCount { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public int AuthorId { get; set; }
    public User Author { get; set; } = null!;
}
