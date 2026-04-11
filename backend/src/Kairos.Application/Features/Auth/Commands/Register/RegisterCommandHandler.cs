using Kairos.Application.Common.Interfaces;
using Kairos.Domain.Entities;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Kairos.Application.Features.Auth.Commands.Register;

public class RegisterCommandHandler(IApplicationDbContext db)
    : IRequestHandler<RegisterCommand, RegisterResult>
{
    public async Task<RegisterResult> Handle(RegisterCommand request, CancellationToken cancellationToken)
    {
        var emailExists = await db.Users.AnyAsync(u => u.Email == request.Email, cancellationToken);
        if (emailExists) throw new InvalidOperationException("El correo ya está registrado.");

        var usernameExists = await db.Users.AnyAsync(u => u.Username == request.Username, cancellationToken);
        if (usernameExists) throw new InvalidOperationException("El nombre de usuario ya está en uso.");

        var user = new User
        {
            Username = request.Username,
            Email = request.Email,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
            FullName = request.FullName,
            Institution = request.Institution,
            Role = request.Role ?? "student"
        };

        db.Users.Add(user);
        await db.SaveChangesAsync(cancellationToken);

        return new RegisterResult(user.Id, user.Email);
    }
}
