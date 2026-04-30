using Kairos.Application.Common.Interfaces;
using Kairos.Domain.Entities;
using MediatR;

namespace Kairos.Application.Features.Jobs.Commands.CreateJobPosting;

public class CreateJobPostingCommandHandler(IApplicationDbContext db)
    : IRequestHandler<CreateJobPostingCommand, int>
{
    public async Task<int> Handle(CreateJobPostingCommand request, CancellationToken cancellationToken)
    {
        var posting = new JobPosting
        {
            CompanyId   = request.CompanyId,
            Title       = request.Title,
            Description = request.Description,
            Location    = request.Location,
            ImageUrl    = request.ImageUrl,
            ExpiresAt   = request.ExpiresAt,
            Status      = JobStatus.Open,
        };

        db.JobPostings.Add(posting);
        await db.SaveChangesAsync(cancellationToken);
        return posting.Id;
    }
}
