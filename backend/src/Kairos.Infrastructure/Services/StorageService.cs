using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;
using Kairos.Application.Common.Interfaces;
using Microsoft.Extensions.Options;

namespace Kairos.Infrastructure.Services;

public class AzureBlobOptions
{
    public const string Section = "AzureBlob";
    public string ConnectionString { get; set; } = string.Empty;
    public string ContainerName { get; set; } = string.Empty;
    public string CdnBaseUrl { get; set; } = string.Empty;
}

public class StorageService(IOptions<AzureBlobOptions> options) : IStorageService
{
    private readonly AzureBlobOptions _opts = options.Value;

    public async Task<string> UploadAsync(
        Stream fileStream,
        string fileName,
        string contentType,
        CancellationToken cancellationToken = default)
    {
        var container = new BlobContainerClient(_opts.ConnectionString, _opts.ContainerName);
        await container.CreateIfNotExistsAsync(PublicAccessType.None, cancellationToken: cancellationToken);

        var blob = container.GetBlobClient(fileName);

        await blob.UploadAsync(fileStream, new BlobHttpHeaders { ContentType = contentType }, cancellationToken: cancellationToken);

        return GetCdnUrl(fileName);
    }

    public string GetCdnUrl(string blobName) =>
        $"{_opts.CdnBaseUrl.TrimEnd('/')}/{blobName}";
}
