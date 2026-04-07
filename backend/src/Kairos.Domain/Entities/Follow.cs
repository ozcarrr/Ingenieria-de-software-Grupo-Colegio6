// ── Follow ───────────────────────────────────────────────────
// Tabla puente para la relación "seguir" entre usuarios.
// FollowerId → sigue a → FollowedId

namespace Kairos.Domain.Entities;

public class Follow
{
    public int FollowerId   { get; set; }
    public User Follower    { get; set; } = null!;

    public int FollowedId   { get; set; }
    public User Followed    { get; set; } = null!;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}

// ── Post ─────────────────────────────────────────────────────