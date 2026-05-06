namespace Kairos.Domain.Entities;

public class Message
{
    public int      Id           { get; set; }
    public string   Content      { get; set; } = string.Empty;
    public DateTime CreatedAt    { get; set; } = DateTime.UtcNow;

    // Sender
    public int  SenderId { get; set; }
    public User Sender   { get; set; } = null!;

    // Receiver (direct message)
    public int  ReceiverId { get; set; }
    public User Receiver   { get; set; } = null!;

    public bool IsRead { get; set; } = false;
}
