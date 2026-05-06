using Kairos.Application.Common.Interfaces;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;

namespace Kairos.Infrastructure.Services;

public class ReportGeneratorService : IReportGeneratorService
{
    static ReportGeneratorService()
    {
        QuestPDF.Settings.License = LicenseType.Community;
    }

    public byte[] GenerateUserEngagementReport(
        int userId, string fullName, string institution,
        int month, int year,
        int postsCreated, int likesReceived, int commentsPosted, int followersGained)
    {
        var monthName = new DateTime(year, month, 1).ToString("MMMM yyyy");

        return Document.Create(container =>
        {
            container.Page(page =>
            {
                page.Size(PageSizes.A4);
                page.Margin(40);
                page.DefaultTextStyle(t => t.FontSize(11).FontFamily("Arial"));

                page.Header().Column(col =>
                {
                    col.Item().Text($"Reporte de actividad — {monthName}")
                        .FontSize(20).Bold().FontColor(Colors.Grey.Darken3);

                    col.Item().Text(fullName)
                        .FontSize(13).FontColor(Colors.Grey.Darken2);

                    col.Item().Text(institution)
                        .FontSize(11).FontColor(Colors.Grey.Medium);

                    col.Item().PaddingTop(6)
                        .LineHorizontal(1).LineColor(Colors.Grey.Lighten1);
                });

                page.Content().PaddingTop(20).Column(col =>
                {
                    col.Item().Text("Resumen del período")
                        .FontSize(14).Bold().FontColor(Colors.Grey.Darken2);

                    col.Item().PaddingTop(12).Table(table =>
                    {
                        table.ColumnsDefinition(c =>
                        {
                            c.RelativeColumn(3);
                            c.RelativeColumn(1);
                        });

                        AddRow(table, "Publicaciones creadas", postsCreated);
                        AddRow(table, "Likes recibidos",        likesReceived);
                        AddRow(table, "Comentarios realizados", commentsPosted);
                        AddRow(table, "Nuevos seguidores",      followersGained);
                    });
                });

                page.Footer().AlignCenter().Text(txt =>
                {
                    txt.Span("Kairos · Generado el ")
                        .FontSize(9).FontColor(Colors.Grey.Lighten1);
                    txt.Span(DateTime.UtcNow.ToString("dd/MM/yyyy"))
                        .FontSize(9).FontColor(Colors.Grey.Lighten1);
                });
            });
        }).GeneratePdf();
    }

    private static void AddRow(TableDescriptor table, string label, int value)
    {
        table.Cell().Padding(6).Text(label).FontColor(Colors.Grey.Darken2);
        table.Cell().Padding(6).AlignRight().Text(value.ToString()).Bold();
    }
}
