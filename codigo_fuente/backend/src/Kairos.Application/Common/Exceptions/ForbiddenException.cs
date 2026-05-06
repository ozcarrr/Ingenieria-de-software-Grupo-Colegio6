namespace Kairos.Application.Common.Exceptions;

/// <summary>Thrown when an authenticated user attempts an action they are not allowed to perform.</summary>
public class ForbiddenException(string message) : Exception(message);
