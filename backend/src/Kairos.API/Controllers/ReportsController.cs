using System.Security.Claims;
using Kairos.Application.Features.Reports.Queries.GetUserReport;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Kairos.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ReportsController(IMediator mediator) : ControllerBase
{
    /// <summary>
    /// Generate a monthly social engagement PDF for the authenticated user.
    /// </summary>
    [HttpGet("me")]
    [ProducesResponseType(typeof(FileStreamResult), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetMyReport(
        [FromQuery] int month = 0,
        [FromQuery] int year = 0,
        CancellationToken ct = default)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? User.FindFirstValue("sub")
            ?? throw new UnauthorizedAccessException());

        var now = DateTime.UtcNow;
        var reportMonth = month > 0 ? month : now.Month;
        var reportYear  = year  > 0 ? year  : now.Year;

        var pdfBytes = await mediator.Send(new GetUserReportQuery(userId, reportMonth, reportYear), ct);

        return File(pdfBytes, "application/pdf",
            $"kairos-reporte-{reportYear}-{reportMonth:D2}.pdf");
    }
}
