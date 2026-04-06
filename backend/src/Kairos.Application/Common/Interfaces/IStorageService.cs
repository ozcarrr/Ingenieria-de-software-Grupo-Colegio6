namespace Kairos.Application.Common.Interfaces;

public interface IStorageService
{
    /// <summary>Uploads a stream to Azure Blob Storage and returns the CDN URL.</summary>
    Task<string> UploadAsync(Stream fileStream, string fileName, string contentType, CancellationToken cancellationToken = default);

    /// <summary>Returns the CDN-fronted public URL for a given blob name.</summary>
    string GetCdnUrl(string blobName);
}
