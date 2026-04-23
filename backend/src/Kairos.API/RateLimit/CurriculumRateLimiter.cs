using System.Threading.RateLimiting;

namespace Kairos.API.RateLimit;

// Enforces two independent constraints on CV generation:
//   1. Max 5 requests per 15-minute window (per user)
//   2. Minimum 20-second gap between any two consecutive requests
internal sealed class CurriculumRateLimiter : RateLimiter
{
    private readonly FixedWindowRateLimiter _quotaLimiter;
    private DateTime _lastRequest = DateTime.MinValue;
    private readonly SemaphoreSlim _semaphore = new(1, 1);

    internal CurriculumRateLimiter()
    {
        _quotaLimiter = new FixedWindowRateLimiter(new FixedWindowRateLimiterOptions
        {
            PermitLimit = 5,
            Window = TimeSpan.FromMinutes(15),
            QueueLimit = 0,
            QueueProcessingOrder = QueueProcessingOrder.OldestFirst
        });
    }

    public override TimeSpan? IdleDuration => _quotaLimiter.IdleDuration;
    public override RateLimiterStatistics? GetStatistics() => _quotaLimiter.GetStatistics();

    protected override RateLimitLease AttemptAcquireCore(int permitCount)
    {
        _semaphore.Wait();
        try { return CheckAndAcquire(permitCount); }
        finally { _semaphore.Release(); }
    }

    protected override async ValueTask<RateLimitLease> AcquireAsyncCore(int permitCount, CancellationToken ct)
    {
        await _semaphore.WaitAsync(ct);
        try { return CheckAndAcquire(permitCount); }
        finally { _semaphore.Release(); }
    }

    private RateLimitLease CheckAndAcquire(int permitCount)
    {
        var now = DateTime.UtcNow;
        if (now - _lastRequest < TimeSpan.FromSeconds(20))
            return RejectedLease.Instance;

        var lease = _quotaLimiter.AttemptAcquire(permitCount);
        if (lease.IsAcquired)
            _lastRequest = now;
        return lease;
    }

    protected override void Dispose(bool disposing)
    {
        if (disposing)
        {
            _quotaLimiter.Dispose();
            _semaphore.Dispose();
        }
        base.Dispose(disposing);
    }
}

internal sealed class RejectedLease : RateLimitLease
{
    internal static readonly RejectedLease Instance = new();
    public override bool IsAcquired => false;
    public override IEnumerable<string> MetadataNames => [];
    public override bool TryGetMetadata(string metadataName, out object? metadata)
    {
        metadata = null;
        return false;
    }
}
