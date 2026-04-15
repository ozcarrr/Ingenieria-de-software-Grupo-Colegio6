using System.Security.Claims;
using Kairos.Application.Features.Jobs.Commands.ApplyToJob;
using Kairos.Application.Features.Jobs.Commands.CreateJobPosting;
using Kairos.Application.Features.Jobs.Queries.GetJobs;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Kairos.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class JobsController(IMediator mediator) : ControllerBase
{
    private int GetUserId() => int.Parse(
        User.FindFirstValue(ClaimTypes.NameIdentifier)
        ?? User.FindFirstValue("sub")
        ?? throw new UnauthorizedAccessException());

    /// <summary>List job postings. Optionally filter by search term or status.</summary>
    [HttpGet]
    [ProducesResponseType(typeof(GetJobsResult), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetJobs(
        [FromQuery] string? search   = null,
        [FromQuery] string? status   = "Open",
        [FromQuery] int     page     = 1,
        [FromQuery] int     pageSize = 20,
        CancellationToken   ct       = default)
    {
        var result = await mediator.Send(new GetJobsQuery(search, status, page, pageSize), ct);
        return Ok(result);
    }

    /// <summary>Create a new job posting (company only).</summary>
    [HttpPost]
    [ProducesResponseType(typeof(int), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> CreateJobPosting(
        [FromBody] CreateJobRequest request,
        CancellationToken ct)
    {
        var role = User.FindFirstValue(ClaimTypes.Role) ?? "student";
        if (role != "company")
            return Forbid();

        var id = await mediator.Send(new CreateJobPostingCommand(
            GetUserId(),
            request.Title,
            request.Description,
            request.Location,
            request.ExpiresAt), ct);

        return CreatedAtAction(nameof(GetJobs), new { id }, id);
    }

    /// <summary>Apply to a job posting.</summary>
    [HttpPost("{jobId:int}/apply")]
    [ProducesResponseType(typeof(int), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> ApplyToJob(
        int jobId,
        [FromBody] ApplyRequest request,
        CancellationToken ct)
    {
        try
        {
            var applicationId = await mediator.Send(
                new ApplyToJobCommand(jobId, GetUserId(), request.CvUrl), ct);
            return CreatedAtAction(nameof(GetJobs), new { id = applicationId }, applicationId);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { detail = ex.Message });
        }
    }
}

public record CreateJobRequest(
    string    Title,
    string    Description,
    string?   Location  = null,
    DateTime? ExpiresAt = null);

public record ApplyRequest(string? CvUrl = null);
