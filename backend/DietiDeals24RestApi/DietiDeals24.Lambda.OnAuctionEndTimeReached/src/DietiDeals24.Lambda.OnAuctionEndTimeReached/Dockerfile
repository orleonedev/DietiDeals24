# Stage 1: Build Stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy csproj and restore as distinct layers
COPY ["DietiDeals24.Lambda.OnAuctionEndTimeReached.csproj", "DietiDeals24.Lambda.OnAuctionEndTimeReached/"]
RUN dotnet restore "DietiDeals24.Lambda.OnAuctionEndTimeReached/DietiDeals24.Lambda.OnAuctionEndTimeReached.csproj"

WORKDIR "/src/DietiDeals24.Lambda.OnAuctionEndTimeReached"
COPY . .
RUN dotnet build "DietiDeals24.Lambda.OnAuctionEndTimeReached.csproj" --configuration Release --output /app/build

# Stage 2: Publish Stage
FROM build AS publish
RUN dotnet publish "DietiDeals24.Lambda.OnAuctionEndTimeReached.csproj" \
    --configuration Release \
    --runtime linux-arm64 \
    --self-contained false \
    --output /app/publish \
    -p:PublishReadyToRun=true

# Stage 3: Runtime Stage
FROM public.ecr.aws/lambda/dotnet:8-arm64 AS final
ENV BACKEND_URL=http://52.50.90.140:80/api/Auction/on-auction-end-time-reached
WORKDIR /var/task
COPY --from=publish /app/publish .
CMD [ "DietiDeals24.Lambda.OnAuctionEndTimeReached::DietiDeals24.Lambda.OnAuctionEndTimeReached.Function::FunctionHandler" ]