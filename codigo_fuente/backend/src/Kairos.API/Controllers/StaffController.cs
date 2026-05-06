using System.Security.Claims;
using Kairos.Application.Common.Interfaces;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Kairos.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class StaffController(IApplicationDbContext db) : ControllerBase
{
    private string GetRole() =>
        User.FindFirstValue(ClaimTypes.Role) ?? "student";

    /// <summary>List users pending approval.</summary>
    [HttpGet("registration-requests")]
    public async Task<IActionResult> GetPendingRegistrations(CancellationToken ct)
    {
        if (GetRole() != "staff") return Forbid();

        var pending = await db.Users
            .Where(u => u.Status == "pending")
            .OrderBy(u => u.CreatedAt)
            .Select(u => new
            {
                u.Id,
                u.FullName,
                u.Email,
                u.Username,
                u.Role,
                u.Institution,
                u.CreatedAt,
            })
            .ToListAsync(ct);

        return Ok(pending);
    }

    /// <summary>Approve a pending user account.</summary>
    [HttpPost("users/{id:int}/approve")]
    public async Task<IActionResult> ApproveUser(int id, CancellationToken ct)
    {
        if (GetRole() != "staff") return Forbid();

        var user = await db.Users.FindAsync([id], ct);
        if (user is null) return NotFound();

        user.Status = "approved";
        await db.SaveChangesAsync(ct);
        return NoContent();
    }

    /// <summary>Reject a pending user account.</summary>
    [HttpPost("users/{id:int}/reject")]
    public async Task<IActionResult> RejectUser(int id, CancellationToken ct)
    {
        if (GetRole() != "staff") return Forbid();

        var user = await db.Users.FindAsync([id], ct);
        if (user is null) return NotFound();

        user.Status = "rejected";
        await db.SaveChangesAsync(ct);
        return NoContent();
    }

    /// <summary>Permanently delete any user account (staff only).</summary>
    [HttpDelete("users/{id:int}")]
    public async Task<IActionResult> DeleteUser(int id, CancellationToken ct)
    {
        if (GetRole() != "staff") return Forbid();

        var user = await db.Users.FindAsync([id], ct);
        if (user is null) return NotFound();

        db.Users.Remove(user);
        await db.SaveChangesAsync(ct);
        return NoContent();
    }

    /// <summary>List all registered users (for staff dashboard).</summary>
    [HttpGet("users")]
    public async Task<IActionResult> GetAllUsers(CancellationToken ct)
    {
        if (GetRole() != "staff") return Forbid();

        var users = await db.Users
            .OrderBy(u => u.FullName)
            .Select(u => new
            {
                u.Id,
                u.FullName,
                u.Email,
                u.Username,
                u.Role,
                u.Institution,
                u.Status,
                u.CreatedAt,
            })
            .ToListAsync(ct);

        return Ok(users);
    }
}
