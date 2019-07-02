# escape=`
FROM jetbrains/teamcity-agent:2019.1-windowsservercore

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Install Windows features to enable ASP.NET building
RUN Install-WindowsFeature NET-Framework-45-ASPNET ; `
Install-WindowsFeature Web-Asp-Net45

# Install Microsoft Build Tools 2019
RUN Invoke-WebRequest -UseBasicParsing https://download.visualstudio.microsoft.com/download/pr/4da568ff-b8aa-43ab-92ec-a8129370b49a/6fb89b999fed6f395622e004bfe442eb/vs_buildtools.exe -OutFile vs_BuildTools.exe; `
    # Installer won't detect DOTNET_SKIP_FIRST_TIME_EXPERIENCE if ENV is used, must use setx /M
    setx /M DOTNET_SKIP_FIRST_TIME_EXPERIENCE 1; `
    Start-Process vs_BuildTools.exe `
        -ArgumentList `
            '--add', 'Microsoft.VisualStudio.Workload.DataBuildTools', `
            '--add', 'Microsoft.VisualStudio.Workload.WebBuildTools', `
            '--add', 'Microsoft.VisualStudio.Workload.NodeBuildTools', `
            '--add', 'Microsoft.Net.Core.Component.SDK.2.1', `
            '--add', 'Microsoft.Net.Component.4.7.1.SDK', `
            '--add', 'Microsoft.Net.Component.4.7.SDK', `
            '--add', 'Microsoft.Net.Component.4.6.2.SDK', `
            '--includeRecommended', '--includeOptional', '--quiet' `
        -NoNewWindow -Wait; `
    Remove-Item -Force vs_buildtools.exe;

# Install AWSPowerShell
RUN Install-PackageProvider -Name NuGet -Force; Install-Module -Name AWSPowerShell -Force

# Install node 8.10
ADD https://nodejs.org/dist/v8.10.0/node-v8.10.0-win-x64.zip C:\\temp\\node-v8.10.0-win-x64.zip
RUN Expand-Archive C:\temp\node-v8.10.0-win-x64.zip \"C:/Program Files\"; Rename-Item \"C:/Program Files/node-v8.10.0-win-x64\" nodejs
RUN SETX PATH \"C:/Program Files/nodejs\"
RUN npm install -g bower
