using System.Security.Claims;
using Kairos.Application.Features.Chat.Commands.SendMessage;
using Kairos.Application.Features.Chat.Queries.GetConversations;
using Kairos.Application.Features.Chat.Queries.GetMessages;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Kairos.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ChatController(IMediator mediator) : ControllerBase
{
    private int GetUserId() => int.Parse(
        User.FindFirstValue(ClaimTypes.NameIdentifier)
        ?? User.FindFirstValue("sub")
        ?? throw new UnauthorizedAccessException());

    /// <summary>Get all conversations for the current user, sorted by most recent message.</summary>
    [HttpGet("conversations")]
    [ProducesResponseType(typeof(IReadOnlyList<ConversationDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetConversations(CancellationToken ct)
    {
        var result = await mediator.Send(new GetConversationsQuery(GetUserId()), ct);
        return Ok(result);
    }

    /// <summary>Get the message history between the current user and another user.</summary>
    [HttpGet("messages/{otherUserId:int}")]
    [ProducesResponseType(typeof(IReadOnlyList<MessageDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetMessages(
        int otherUserId,
        [FromQuery] int page     = 1,
        [FromQuery] int pageSize = 40,
        CancellationToken ct     = default)
    {
        var result = await mediator.Send(
            new GetMessagesQuery(GetUserId(), otherUserId, page, pageSize), ct);
        return Ok(result);
    }

    /// <summary>Send a direct message and persist it. Also triggers a SignalR notification.</summary>
    [HttpPost("messages/{receiverId:int}")]
    [ProducesResponseType(typeof(MessageDto), StatusCodes.Status201Created)]
    public async Task<IActionResult> SendMessage(
        int receiverId,
        [FromBody] SendMessageRequest request,
        CancellationToken ct)
    {
        var dto = await mediator.Send(
            new SendMessageCommand(GetUserId(), receiverId, request.Content), ct);

        return CreatedAtAction(
            nameof(GetMessages),
            new { otherUserId = receiverId },
            dto);
    }
}

public record SendMessageRequest(string Content);
