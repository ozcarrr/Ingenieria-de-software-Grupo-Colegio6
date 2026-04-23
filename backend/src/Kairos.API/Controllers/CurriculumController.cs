using System.Security.Claims;
using Kairos.Application.Features.Curriculum.Queries.GenerateCurriculum;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;

namespace Kairos.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class CurriculumController(IMediator mediator) : ControllerBase
{
    /// <summary>
    /// Generate and download a CV PDF for the authenticated user,
    /// built from their entire activity history.
    /// </summary>
    [HttpGet("me")]
    [EnableRateLimiting("curriculum")]
    [ProducesResponseType(typeof(FileStreamResult), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status429TooManyRequests)]
    public async Task<IActionResult> GetMyCurriculum(CancellationToken ct)
    {
        var userId = int.Parse(
            User.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? User.FindFirstValue("sub")
            ?? throw new UnauthorizedAccessException());

        var pdfBytes = await mediator.Send(new GenerateCurriculumQuery(userId), ct);

        return File(pdfBytes, "application/pdf",
            $"kairos-cv-{DateTime.UtcNow:yyyy-MM-dd}.pdf");
    }
}
