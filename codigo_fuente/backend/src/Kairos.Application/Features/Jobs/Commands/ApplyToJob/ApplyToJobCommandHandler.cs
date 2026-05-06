using Kairos.Application.Common.Interfaces;
using Kairos.Domain.Entities;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Kairos.Application.Features.Jobs.Commands.ApplyToJob;

public class ApplyToJobCommandHandler(IApplicationDbContext db)
    : IRequestHandler<ApplyToJobCommand, int>
{
    public async Task<int> Handle(ApplyToJobCommand request, CancellationToken cancellationToken)
    {
        // Prevent duplicate applications
        var alreadyApplied = await db.JobApplications
            .AnyAsync(a => a.JobId == request.JobId && a.ApplicantId == request.ApplicantId,
                cancellationToken);

        if (alreadyApplied)
            throw new InvalidOperationException("Ya postulaste a esta oferta.");

        var job = await db.JobPostings.FindAsync([request.JobId], cancellationToken)
            ?? throw new KeyNotFoundException($"Oferta {request.JobId} no encontrada.");

        if (job.Status != JobStatus.Open)
            throw new InvalidOperationException("Esta oferta ya no está disponible.");

        var application = new JobApplication
        {
            JobId       = request.JobId,
            ApplicantId = request.ApplicantId,
            CvUrl       = request.CvUrl,
            Status      = ApplicationStatus.Pending,
        };

        db.JobApplications.Add(application);
        await db.SaveChangesAsync(cancellationToken);
        return application.Id;
    }
}
