using MediatR;

namespace Kairos.Application.Features.Curriculum.Queries.GenerateCurriculum;

public record GenerateCurriculumQuery(int UserId) : IRequest<byte[]>;
