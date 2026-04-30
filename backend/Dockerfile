FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY Kairos.sln .
COPY src/Kairos.API/Kairos.API.csproj             src/Kairos.API/
COPY src/Kairos.Application/Kairos.Application.csproj src/Kairos.Application/
COPY src/Kairos.Domain/Kairos.Domain.csproj       src/Kairos.Domain/
COPY src/Kairos.Infrastructure/Kairos.Infrastructure.csproj src/Kairos.Infrastructure/

RUN dotnet restore

COPY . .
RUN dotnet publish src/Kairos.API/Kairos.API.csproj -c Release -o /app/out

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

COPY --from=build /app/out .

RUN mkdir -p wwwroot/uploads

ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080

ENTRYPOINT ["dotnet", "Kairos.API.dll"]
