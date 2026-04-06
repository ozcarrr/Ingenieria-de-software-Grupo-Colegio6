using Kairos.Application.Features.Storage.Commands.UploadFile;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Kairos.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class StorageController(IMediator mediator) : ControllerBase
{
    private static readonly HashSet<string> AllowedContentTypes =
    [
        "image/jpeg", "image/png", "image/webp", "image/gif", "video/mp4"
    ];

    /// <summary>
    /// Upload a file to Azure Blob Storage.
    /// Returns the CDN URL to use as ImageUrl on posts or ProfilePictureUrl on the user profile.
    /// </summary>
    [HttpPost("upload")]
    [ProducesResponseType(typeof(UploadFileResult), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [RequestSizeLimit(52_428_800)] // 50 MB
    public async Task<IActionResult> Upload(IFormFile file, CancellationToken ct)
    {
        if (file is null || file.Length == 0)
            return BadRequest(new { detail = "No se proporcionó ningún archivo." });

        if (!AllowedContentTypes.Contains(file.ContentType))
            return BadRequest(new { detail = $"Tipo de archivo no permitido: {file.ContentType}" });

        await using var stream = file.OpenReadStream();
        var result = await mediator.Send(
            new UploadFileCommand(stream, file.FileName, file.ContentType), ct);

        return Ok(result);
    }
}
