@echo off
REM Rebuild Maven project
cd /d "d:\FPT-KTPM\ki5\SWP301\Project_LBMS\LibraryManagementWebsite"
echo Rebuilding project...
mvn clean package -DskipTests
echo Build completed!
pause
