using MediatR;

namespace Kairos.Application.Features.Jobs.Commands.CreateJobPosting;

public record CreateJobPostingCommand(
    int      CompanyId,
    string   Title,
    string   Description,
    string?  Location,
    DateTime? ExpiresAt) : IRequest<int>;
