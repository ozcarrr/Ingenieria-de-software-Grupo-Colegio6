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
    public async Task<IActionResult> Upload(CancellationToken ct)
    {
        if (!Request.HasFormContentType)
        {
            var corrected = await TryRecoverMultipartContentTypeAsync(ct);
            if (!corrected)
            {
                return BadRequest(new { detail = "La solicitud debe enviarse como multipart/form-data." });
            }
        }

        var form = await Request.ReadFormAsync(ct);
        var file = form.Files.GetFile("file");

        if (file is null || file.Length == 0)
            return BadRequest(new { detail = "No se proporcionó ningún archivo." });

        if (!AllowedContentTypes.Contains(file.ContentType))
            return BadRequest(new { detail = $"Tipo de archivo no permitido: {file.ContentType}" });

        await using var stream = file.OpenReadStream();
        var result = await mediator.Send(
            new UploadFileCommand(stream, file.FileName, file.ContentType), ct);

        return Ok(result);
    }

    private async Task<bool> TryRecoverMultipartContentTypeAsync(CancellationToken ct)
    {
        Request.EnableBuffering();

        using var reader = new StreamReader(Request.Body, leaveOpen: true);
        var raw = await reader.ReadToEndAsync(ct);
        Request.Body.Position = 0;

        if (string.IsNullOrWhiteSpace(raw) || !raw.StartsWith("--", StringComparison.Ordinal))
            return false;

        var firstLineEnd = raw.IndexOf("\r\n", StringComparison.Ordinal);
        if (firstLineEnd <= 2)
            return false;

        var boundary = raw[2..firstLineEnd].Trim();
        if (string.IsNullOrWhiteSpace(boundary))
            return false;

        Request.ContentType = $"multipart/form-data; boundary={boundary}";
        return true;
    }
}
