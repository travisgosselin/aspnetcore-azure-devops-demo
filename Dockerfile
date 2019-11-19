# multi-stage docker file for build
FROM mcr.microsoft.com/dotnet/core/sdk:2.1 AS build
WORKDIR /app
RUN mkdir output

COPY ./*.sln ./
COPY src/*/*.csproj ./
RUN for file in $(ls *.csproj); do mkdir -p src/${file%.*}/ && mv $file src/${file%.*}/; done
COPY tests/*/*.csproj ./
RUN for file in $(ls *.csproj); do mkdir -p tests/${file%.*}/ && mv $file tests/${file%.*}/; done

RUN dotnet restore
COPY . ./

RUN dotnet test

RUN dotnet publish src/Demo.Web -c Release -o /app/out

# multi-stage docker file for runtime
FROM mcr.microsoft.com/dotnet/core/aspnet:2.1 as runtime
WORKDIR /app

COPY --from=build ["/app/out", "./"]

ENTRYPOINT ["dotnet", "Demo.Web.dll"]