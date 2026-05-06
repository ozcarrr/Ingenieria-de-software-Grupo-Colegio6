using System.Security.Claims;
using Kairos.Application.Features.Network.Commands.FollowUser;
using Kairos.Application.Features.Network.Commands.UnfollowUser;
using Kairos.Application.Features.Network.Queries.GetFollowing;
using Kairos.Application.Features.Network.Queries.GetNetworkSuggestions;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Kairos.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class NetworkController(IMediator mediator) : ControllerBase
{
    private int GetUserId() => int.Parse(
        User.FindFirstValue(ClaimTypes.NameIdentifier)
        ?? User.FindFirstValue("sub")
        ?? throw new UnauthorizedAccessException());

    /// <summary>Get users that the current user follows (for chat suggestions).</summary>
    [HttpGet("following")]
    [ProducesResponseType(typeof(IReadOnlyList<UserSuggestionDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetFollowing(CancellationToken ct)
    {
        var result = await mediator.Send(new GetFollowingQuery(GetUserId()), ct);
        return Ok(result);
    }

    /// <summary>Get suggested users to follow (not yet followed).</summary>
    [HttpGet("suggestions")]
    [ProducesResponseType(typeof(IReadOnlyList<UserSuggestionDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetSuggestions(
        [FromQuery] int page     = 1,
        [FromQuery] int pageSize = 20,
        CancellationToken ct     = default)
    {
        var result = await mediator.Send(
            new GetNetworkSuggestionsQuery(GetUserId(), page, pageSize), ct);
        return Ok(result);
    }

    /// <summary>Follow a user.</summary>
    [HttpPost("{userId:int}/follow")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<IActionResult> Follow(int userId, CancellationToken ct)
    {
        await mediator.Send(new FollowUserCommand(GetUserId(), userId), ct);
        return NoContent();
    }

    /// <summary>Unfollow a user.</summary>
    [HttpDelete("{userId:int}/follow")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<IActionResult> Unfollow(int userId, CancellationToken ct)
    {
        await mediator.Send(new UnfollowUserCommand(GetUserId(), userId), ct);
        return NoContent();
    }
}
