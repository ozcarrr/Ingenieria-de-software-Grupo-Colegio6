using Kairos.Application.Common.Interfaces;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;

namespace Kairos.Infrastructure.Services;

public class CurriculumGenerator : ICurriculumGenerator
{
    static CurriculumGenerator()
    {
        QuestPDF.Settings.License = LicenseType.Community;
    }

    
    
}
