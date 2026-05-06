// ============================================================
//  Kairos.Infrastructure / Services / CurriculumGeneratorService.cs
// ============================================================

using Kairos.Application.Common.Interfaces;
using Kairos.Domain.Entities;
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

    public byte[] Generate(User user, IEnumerable<UserActivity> activities)
    {
        return Document.Create(container =>
        {
            container.Page(page =>
            {
                page.Size(PageSizes.A4);
                page.Margin(40);
                page.DefaultTextStyle(t => t.FontSize(11).FontFamily("Arial"));

                // ── Encabezado ────────────────────────────────────────
                page.Header().Column(col =>
                {
                    col.Item().Text(user.FullName)
                        .FontSize(22).Bold().FontColor(Colors.Grey.Darken3);

                    col.Item().Text(user.Email)
                        .FontSize(11).FontColor(Colors.Grey.Medium);

                    if (!string.IsNullOrWhiteSpace(user.Institution))
                        col.Item().Text(user.Institution)
                            .FontSize(11).FontColor(Colors.Grey.Medium);

                    if (!string.IsNullOrWhiteSpace(user.Bio))
                    {
                        col.Item().PaddingTop(8).Text(user.Bio)
                            .FontSize(11).FontColor(Colors.Grey.Darken1);
                    }

                    col.Item().PaddingTop(6)
                        .LineHorizontal(1).LineColor(Colors.Grey.Lighten1);
                });

                // ── Contenido ─────────────────────────────────────────
                page.Content().PaddingTop(16).Column(col =>
                {
                    var grouped = activities
                        .GroupBy(a => a.ActivityType)
                        .OrderBy(g => g.Key.ToString());

                    foreach (var group in grouped)
                    {
                        // Título de sección (tipo de actividad)
                        col.Item().PaddingTop(12).Text(FormatSection(group.Key))
                            .FontSize(13).Bold().FontColor(Colors.Grey.Darken2);

                        col.Item().PaddingTop(2)
                            .LineHorizontal(0.5f).LineColor(Colors.Grey.Lighten2);

                        // Ítems de la sección
                        foreach (var activity in group.OrderByDescending(a => a.CreatedAt))
                        {
                            col.Item().PaddingTop(6).Row(row =>
                            {
                                row.ConstantItem(110).Text(
                                    activity.CreatedAt.ToString("dd MMM yyyy"))
                                    .FontSize(10).FontColor(Colors.Grey.Medium);

                                row.RelativeItem().Text(activity.Description)
                                    .FontSize(11).FontColor(Colors.Grey.Darken3);
                            });
                        }
                    }

                    // Mensaje si no hay actividades
                    if (!activities.Any())
                    {
                        col.Item().PaddingTop(20).Text("Sin actividades registradas.")
                            .FontSize(11).FontColor(Colors.Grey.Medium).Italic();
                    }
                });

                // ── Pie de página ─────────────────────────────────────
                page.Footer().AlignCenter().Text(txt =>
                {
                    txt.Span("Generado por Kairos · ")
                        .FontSize(9).FontColor(Colors.Grey.Lighten1);
                    txt.Span(DateTime.UtcNow.ToString("dd/MM/yyyy"))
                        .FontSize(9).FontColor(Colors.Grey.Lighten1);
                });
            });
        }).GeneratePdf();
    }

    // Convierte el enum a un título legible para el PDF
    private static string FormatSection(ActivityType type) => type switch
    {
        ActivityType.Login           => "Accesos al sistema",
        ActivityType.PostCreated     => "Publicaciones",
        ActivityType.PostLiked       => "Interacciones",
        ActivityType.CommentPosted   => "Comentarios",
        ActivityType.ProfileUpdated  => "Actualizaciones de perfil",
        ActivityType.JobApplied      => "Postulaciones laborales",
        ActivityType.FollowedUser    => "Red de contactos",
        ActivityType.UserFollowed    => "Nuevos seguidores",
        _                            => type.ToString()
    };
}
