// ============================================================
//  Kairos.Application / Common / Interfaces / ICurriculumGenerator.cs
// ============================================================

using Kairos.Domain.Entities;

namespace Kairos.Application.Common.Interfaces;

public interface ICurriculumGenerator
{
    /// <summary>
    /// Genera el CV en PDF y retorna los bytes del archivo.
    /// </summary>
    byte[] Generate(User user, IEnumerable<UserActivity> activities);
}
