using Kairos.Domain.Entities;

namespace Kairos.Application.Common.Interfaces;

public interface IJwtService
{
    string GenerateToken(User user);
}
