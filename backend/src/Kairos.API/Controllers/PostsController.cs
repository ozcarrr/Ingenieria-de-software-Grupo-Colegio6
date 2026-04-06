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
    [HttpGet("feed")]
    [ProducesResponseType(typeof(GetFeedResult), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetFeed([FromQuery] int page = 1, [FromQuery] int pageSize = 20, CancellationToken ct = default)
    {
        var result = await mediator.Send(new GetFeedQuery(page, pageSize), ct);
        return Ok(result);
    }

    [HttpPost]
    [ProducesResponseType(typeof(int), StatusCodes.Status201Created)]
    public async Task<IActionResult> CreatePost([FromBody] CreatePostRequest request, CancellationToken ct)
    {
        var authorId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? User.FindFirstValue("sub")
            ?? throw new UnauthorizedAccessException());

        var command = new CreatePostCommand(authorId, request.Content, request.PostType, request.ImageUrl, request.EventDate);
        var postId = await mediator.Send(command, ct);

        return CreatedAtAction(nameof(GetFeed), new { id = postId }, postId);
    }
}

public record CreatePostRequest(string Content, string PostType = "Regular", string? ImageUrl = null, string? EventDate = null);
