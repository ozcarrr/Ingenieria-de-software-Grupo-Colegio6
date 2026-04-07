// ── Like ─────────────────────────────────────────────────────
// Clave compuesta (UserId + PostId) para evitar likes duplicados a nivel de BD.
namespace Kairos.Domain.Entities;

public class Like
{
    public int  UserId  { get; set; }
    public User User    { get; set; } = null!;

    public int  PostId  { get; set; }
    public Post Post    { get; set; } = null!;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}