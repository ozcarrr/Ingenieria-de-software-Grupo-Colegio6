using System.Net;
using System.Text.Json;
using Kairos.Application.Common.Exceptions;

namespace Kairos.API.Middleware;

public class ExceptionHandlingMiddleware(RequestDelegate next, ILogger<ExceptionHandlingMiddleware> logger)
{
    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await next(context);
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Unhandled exception for {Method} {Path}", context.Request.Method, context.Request.Path);
            await WriteProblemDetailsAsync(context, ex);
        }
    }

    private static Task WriteProblemDetailsAsync(HttpContext context, Exception ex)
    {
        var (statusCode, title) = ex switch
        {
            UnauthorizedAccessException => (HttpStatusCode.Unauthorized,  "No autorizado."),
            ForbiddenException          => (HttpStatusCode.Forbidden,     "Acción no permitida."),
            KeyNotFoundException        => (HttpStatusCode.NotFound,      "Recurso no encontrado."),
            InvalidOperationException   => (HttpStatusCode.Conflict,      "Operación inválida."),
            ArgumentException           => (HttpStatusCode.BadRequest,    "Solicitud inválida."),
            _                           => (HttpStatusCode.InternalServerError, "Error interno del servidor.")
        };

        context.Response.ContentType = "application/problem+json";
        context.Response.StatusCode = (int)statusCode;

        var problemDetails = new
        {
            type = $"https://httpstatuses.com/{(int)statusCode}",
            title,
            status = (int)statusCode,
            detail = ex.Message,
            instance = context.Request.Path.Value
        };

        return context.Response.WriteAsync(JsonSerializer.Serialize(problemDetails));
    }
}
