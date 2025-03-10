#FROM public.ecr.aws/lambda/dotnet:8
#
#WORKDIR /var/task
#
## This COPY command copies the .NET Lambda project's build artifacts from the host machine into the image. 
## The source of the COPY should match where the .NET Lambda project publishes its build artifacts. If the Lambda function is being built 
## with the AWS .NET Lambda Tooling, the `--docker-host-build-output-dir` switch controls where the .NET Lambda project
## will be built. The .NET Lambda project templates default to having `--docker-host-build-output-dir`
## set in the aws-lambda-tools-defaults.json file to "bin/Release/lambda-publish".
##
## Alternatively Docker multi-stage build could be used to build the .NET Lambda project inside the image.
## For more information on this approach checkout the project's README.md file.
#COPY "bin/Release/lambda-publish"  .

# Stage 1: Build Stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy csproj and restore as distinct layers
COPY ["DietiDeals24.Lambda.RegisterUserPostConfirmation.csproj", "DietiDeals24.Lambda.RegisterUserPostConfirmation/"]
RUN dotnet restore "DietiDeals24.Lambda.RegisterUserPostConfirmation/DietiDeals24.Lambda.RegisterUserPostConfirmation.csproj"

WORKDIR "/src/DietiDeals24.Lambda.RegisterUserPostConfirmation"
COPY . .
RUN dotnet build "DietiDeals24.Lambda.RegisterUserPostConfirmation.csproj" --configuration Release --output /app/build

# Stage 2: Publish Stage
FROM build AS publish
RUN dotnet publish "DietiDeals24.Lambda.RegisterUserPostConfirmation.csproj" \
    --configuration Release \
    --runtime linux-x64 \
    --self-contained false \
    --output /app/publish \
    -p:PublishReadyToRun=true

# Stage 3: Runtime Stage
FROM public.ecr.aws/lambda/dotnet:8 AS final
ENV BACKEND_URL=http://indirizzo-ec2/api/Authentication/register-user
WORKDIR /var/task
COPY --from=publish /app/publish .
CMD [ "DietiDeals24.Lambda.RegisterUserPostConfirmation::DietiDeals24.Lambda.RegisterUserPostConfirmation.Function::FunctionHandler" ]