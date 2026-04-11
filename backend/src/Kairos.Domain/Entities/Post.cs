// ── Post ─────────────────────────────────────────────────────
namespace Kairos.Domain.Entities;
/// <summary>
/// General  — cualquier usuario puede publicar (texto + imagen/video + fecha opcional).
/// Event    — solo company o staff (texto + imagen/video + fecha obligatoria).
/// Job      — solo company (texto + imagen/video, sin fecha).
/// </summary>
public enum PostType { General, Event, Job }

public class Post
{
    public int      Id              { get; set; }
    public string   Content         { get; set; } = string.Empty;
    public PostType Type            { get; set; } = PostType.General;
    public string?  ImageUrl        { get; set; }
    public string?  EventDate       { get; set; }
    // LikesCount y CommentsCount son contadores desnormalizados:
    // se guardan directamente en el post para evitar COUNT(*) en cada query del feed.
    public int      LikesCount      { get; set; }
    public int      CommentsCount   { get; set; }
    public DateTime CreatedAt       { get; set; } = DateTime.UtcNow;

    public int  AuthorId    { get; set; }
    public User Author      { get; set; } = null!;

    public ICollection<Comment> Comments { get; set; } = [];
    public ICollection<Like>    Likes    { get; set; } = [];
}