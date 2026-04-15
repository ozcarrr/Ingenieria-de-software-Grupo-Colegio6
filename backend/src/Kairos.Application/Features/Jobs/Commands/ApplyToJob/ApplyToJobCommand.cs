using MediatR;

namespace Kairos.Application.Features.Jobs.Commands.ApplyToJob;

public record ApplyToJobCommand(int JobId, int ApplicantId, string? CvUrl) : IRequest<int>;
