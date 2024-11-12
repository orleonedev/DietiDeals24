# Usa un’immagine ufficiale di .NET come immagine base
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80

# Crea l'immagine build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["DietiDeals24/DietiDeals24.csproj", "./"]
RUN dotnet restore "./DietiDeals24.csproj"
COPY . .
WORKDIR "/src/"
RUN dotnet publish "DietiDeals24.csproj" -c Release -o /app/publish

# Crea l’immagine finale per eseguire l’app
FROM base AS final
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "DietiDeals24.dll"]
