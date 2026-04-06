using Kairos.Application.Common.Interfaces;
using MediatR;

namespace Kairos.Application.Features.Storage.Commands.UploadFile;

public class UploadFileCommandHandler(IStorageService storage)
    : IRequestHandler<UploadFileCommand, UploadFileResult>
{
    public async Task<UploadFileResult> Handle(UploadFileCommand request, CancellationToken cancellationToken)
    {
        var ext = Path.GetExtension(request.FileName);
        var blobName = $"{Guid.NewGuid()}{ext}";

        var cdnUrl = await storage.UploadAsync(request.FileStream, blobName, request.ContentType, cancellationToken);

        return new UploadFileResult(cdnUrl, blobName);
    }
}
