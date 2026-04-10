using System.Security.Claims;
using Kairos.Application.Features.Posts.Commands.CreatePost;
using Kairos.Application.Features.Posts.Queries.GetFeed;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Kairos.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class PostsController(IMediator mediator) : ControllerBase
{
    /// <summary>
    /// Returns a paginated feed of all posts, newest first.
    /// Each item includes the author's role so the client can render
    /// type-specific UI (event badge, job card, etc.).
    /// </summary>
    [HttpGet("feed")]
    [ProducesResponseType(typeof(GetFeedResult), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetFeed(
        [FromQuery] int page     = 1,
        [FromQuery] int pageSize = 20,
        CancellationToken ct     = default)
    {
        var result = await mediator.Send(new GetFeedQuery(page, pageSize), ct);
        return Ok(result);
    }

    /// <summary>
    /// Create a post.
    ///
    /// PostType rules:
    ///   - "general" → any authenticated user
    ///   - "event"   → company or staff only; EventDate is required
    ///   - "job"     → company only
    ///
    /// Returns 201 with the new post ID on success.
    /// Returns 400 for validation errors, 403 for role violations.
    /// </summary>
    [HttpPost]
    [ProducesResponseType(typeof(int), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> CreatePost(
        [FromBody] CreatePostRequest request,
        CancellationToken ct)
    {
        var authorId = int.Parse(
            User.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? User.FindFirstValue("sub")
            ?? throw new UnauthorizedAccessException());

        var authorRole =
            User.FindFirstValue(ClaimTypes.Role)
            ?? "student";

        var command = new CreatePostCommand(
            authorId,
            authorRole,
            request.Content,
            request.PostType,
            request.ImageUrl,
            request.EventDate);

        var postId = await mediator.Send(command, ct);

        return CreatedAtAction(nameof(GetFeed), new { id = postId }, postId);
    }
}

/// <summary>Request body for POST /api/posts.</summary>
public record CreatePostRequest(
    string  Content,
    string  PostType  = "general",   // "general" | "event" | "job"
    string? ImageUrl  = null,
    string? EventDate = null);
