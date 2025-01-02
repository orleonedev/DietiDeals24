# Use the official .NET runtime image for the final stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
USER $APP_UID
WORKDIR /app
ENV ASPNETCORE_HTTP_PORTS=5029
#ENV ASPNETCORE_HTTPS_PORTS=5030
EXPOSE 5029
#EXPOSE 5030

# Use the .NET SDK image for building the app
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
# Copy the .csproj files and restore dependencies
COPY ["DietiDeals24.RestApi/DietiDeals24.RestApi.csproj", "DietiDeals24.RestApi/"]
COPY ["DietiDeals24.DataAccessLayer/DietiDeals24.DataAccessLayer.csproj", "DietiDeals24.DataAccessLayer/"]
RUN dotnet restore "DietiDeals24.RestApi/DietiDeals24.RestApi.csproj"

# Copy the entire solution and build it
COPY . .
WORKDIR "/src/DietiDeals24.RestApi"
RUN dotnet build "DietiDeals24.RestApi.csproj" -c $BUILD_CONFIGURATION -o /app/build

# Publish the application
FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "DietiDeals24.RestApi.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# Use the runtime image for the final app
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "DietiDeals24.RestApi.dll"]
