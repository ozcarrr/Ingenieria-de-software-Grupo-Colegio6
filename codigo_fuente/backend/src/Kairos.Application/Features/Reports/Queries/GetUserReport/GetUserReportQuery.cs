using MediatR;

namespace Kairos.Application.Features.Reports.Queries.GetUserReport;

public record GetUserReportQuery(int UserId, int Month, int Year) : IRequest<byte[]>;
