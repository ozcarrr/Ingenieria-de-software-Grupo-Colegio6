using MediatR;

namespace Kairos.Application.Features.Auth.Commands.Register;

public record RegisterCommand(
    string Username,
    string Email,
    string Password,
    string FullName,
    string? Institution) : IRequest<RegisterResult>;

public record RegisterResult(int UserId, string Email);
