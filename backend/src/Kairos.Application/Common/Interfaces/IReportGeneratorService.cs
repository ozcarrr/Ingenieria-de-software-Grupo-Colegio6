namespace Kairos.Application.Common.Interfaces;

public interface IReportGeneratorService
{
    /// <summary>Generates a monthly social engagement PDF report for the given user.</summary>
    byte[] GenerateUserEngagementReport(int userId, string fullName, string institution, int month, int year,
        int postsCreated, int likesReceived, int commentsPosted, int followersGained);
}
