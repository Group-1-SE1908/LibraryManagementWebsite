$TOMCAT_HOME = "D:\SetupForTomcat\apache-tomcat-10.1.52\apache-tomcat-10.1.52"
$WAR_SRC     = "$PSScriptRoot\target\lbms.war"
$WEBAPPS     = "$TOMCAT_HOME\webapps"

# Dừng Tomcat nếu đang chạy
$running = Get-Process -Name "java" -ErrorAction SilentlyContinue
if ($running) {
    Write-Host "Dang dung Tomcat..."
    & "$TOMCAT_HOME\bin\shutdown.bat"
    Start-Sleep -Seconds 3
}

# Xóa bản deploy cũ
if (Test-Path "$WEBAPPS\lbms.war") { Remove-Item "$WEBAPPS\lbms.war" -Force }
if (Test-Path "$WEBAPPS\lbms")     { Remove-Item "$WEBAPPS\lbms" -Recurse -Force }

# Copy WAR mới
Write-Host "Copy WAR len Tomcat..."
Copy-Item $WAR_SRC $WEBAPPS

# Khởi động Tomcat
Write-Host "Khoi dong Tomcat..."
Start-Process "$TOMCAT_HOME\bin\startup.bat"

Write-Host "Deploy xong! Truy cap: http://localhost:8080/lbms"
