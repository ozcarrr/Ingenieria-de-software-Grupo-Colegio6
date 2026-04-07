// ── JobApplication ───────────────────────────────────────────
// Un estudiante postula a una oferta.
namespace Kairos.Domain.Entities;
public enum ApplicationStatus { Pending, Reviewed, Accepted, Rejected }

public class JobApplication
{
    public int               Id        { get; set; }
    public ApplicationStatus Status    { get; set; } = ApplicationStatus.Pending;
    public string?           CvUrl     { get; set; }  // PDF generado con QuestPDF
    public DateTime          CreatedAt { get; set; } = DateTime.UtcNow;

    public int        JobId   { get; set; }
    public JobPosting Job     { get; set; } = null!;

    public int  ApplicantId { get; set; }
    public User Applicant   { get; set; } = null!;
}