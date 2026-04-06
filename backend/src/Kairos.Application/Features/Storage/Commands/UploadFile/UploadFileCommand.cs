using MediatR;

namespace Kairos.Application.Features.Storage.Commands.UploadFile;

public record UploadFileCommand(Stream FileStream, string FileName, string ContentType) : IRequest<UploadFileResult>;

public record UploadFileResult(string CdnUrl, string BlobName);
