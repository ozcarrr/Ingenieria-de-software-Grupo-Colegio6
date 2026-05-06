using Kairos.Application.Common.Interfaces;
using Kairos.Domain.Entities;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Kairos.Application.Features.Reports.Queries.GetUserReport;

public class GetUserReportQueryHandler(IApplicationDbContext db, IReportGeneratorService reportGenerator)
    : IRequestHandler<GetUserReportQuery, byte[]>
{
    public async Task<byte[]> Handle(GetUserReportQuery request, CancellationToken cancellationToken)
    {
        var user = await db.Users
            .FirstOrDefaultAsync(u => u.Id == request.UserId, cancellationToken)
            ?? throw new KeyNotFoundException($"Usuario {request.UserId} no encontrado.");

        var from = new DateTime(request.Year, request.Month, 1, 0, 0, 0, DateTimeKind.Utc);
        var to = from.AddMonths(1);

        var activities = await db.UserActivities
            .Where(a => a.UserId == request.UserId && a.CreatedAt >= from && a.CreatedAt < to)
            .ToListAsync(cancellationToken);

        int postsCreated   = activities.Count(a => a.ActivityType == ActivityType.PostCreated);
        int likesReceived  = activities.Count(a => a.ActivityType == ActivityType.PostLiked);
        int commentsPosted = activities.Count(a => a.ActivityType == ActivityType.CommentPosted);
        int followersGained = activities.Count(a => a.ActivityType == ActivityType.UserFollowed);

        return reportGenerator.GenerateUserEngagementReport(
            user.Id, user.FullName, user.Institution ?? "—",
            request.Month, request.Year,
            postsCreated, likesReceived, commentsPosted, followersGained);
    }
}
