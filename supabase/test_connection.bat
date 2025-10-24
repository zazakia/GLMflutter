@echo off
echo ================================================
echo Supabase Network Connection Diagnostic Utility
echo ================================================
echo.
echo This utility tests network connectivity to Supabase services
echo without modifying any configuration or linking to projects.
echo.
echo All test results will be logged to CLI_SETUP_LOG.txt
echo.

:: Define log path using script directory
set LOG_PATH=%~dp0CLI_SETUP_LOG.txt

:: Create or append to log file
echo ================================================ >> "%LOG_PATH%"
echo %date% %time% - Running Network Connection Diagnostics >> "%LOG_PATH%"
echo ================================================ >> "%LOG_PATH%"

:: Initialize test results
set NETWORK_PASS=0
set DNS_PASS=0
set PORT_PASS=0
set PROXY_DETECTED=0
set SSL_PASS=0
set AVG_LATENCY=0

:: Step 1: Basic Network Tests
echo Step 1: Testing basic network connectivity...
echo %date% %time% - Testing basic network connectivity... >> "%LOG_PATH%"

echo Testing internet connection...
ping -n 1 google.com >nul 2>&1
if errorlevel 1 (
    echo [FAILED] No internet connection
    echo %date% %time% - ERROR: No internet connection >> "%LOG_PATH%"
) else (
    echo [SUCCESS] Internet connection active
    echo %date% %time% - Internet connection successful >> "%LOG_PATH%"
    set NETWORK_PASS=1
)

echo.
echo Testing connectivity to Supabase API...
ping -n 1 api.supabase.com >nul 2>&1
if errorlevel 1 (
    echo [FAILED] Cannot reach api.supabase.com
    echo %date% %time% - ERROR: Cannot reach api.supabase.com >> "%LOG_PATH%"
) else (
    echo [SUCCESS] api.supabase.com reachable
    echo %date% %time% - api.supabase.com reachable >> "%LOG_PATH%"
)

echo.
echo Testing connectivity to Supabase main domain...
ping -n 1 supabase.com >nul 2>&1
if errorlevel 1 (
    echo [FAILED] Cannot reach supabase.com
    echo %date% %time% - ERROR: Cannot reach supabase.com >> "%LOG_PATH%"
) else (
    echo [SUCCESS] supabase.com reachable
    echo %date% %time% - supabase.com reachable >> "%LOG_PATH%"
)

echo.
if "%1"=="--debug" pause
if "%1"=="-debug" pause

:: Step 2: DNS Resolution Tests
echo Step 2: Testing DNS resolution...
echo %date% %time% - Testing DNS resolution... >> "%LOG_PATH%"

echo Testing DNS resolution for api.supabase.com...
nslookup api.supabase.com > temp_dns_output.txt 2>&1
if errorlevel 1 (
    echo [FAILED] DNS resolution failed for api.supabase.com
    echo %date% %time% - ERROR: DNS resolution failed for api.supabase.com >> "%LOG_PATH%"
) else (
    echo [SUCCESS] DNS resolution successful for api.supabase.com
    echo %date% %time% - DNS resolution successful for api.supabase.com >> "%LOG_PATH%"
    set DNS_PASS=1
)

echo.
echo Testing DNS resolution for supabase.com...
nslookup supabase.com >> temp_dns_output.txt 2>&1
if errorlevel 1 (
    echo [FAILED] DNS resolution failed for supabase.com
    echo %date% %time% - ERROR: DNS resolution failed for supabase.com >> "%LOG_PATH%"
) else (
    echo [SUCCESS] DNS resolution successful for supabase.com
    echo %date% %time% - DNS resolution successful for supabase.com >> "%LOG_PATH%"
)

echo.
echo Testing DNS resolution for project endpoint...
nslookup tzmpwqiaqalrdwdslmkx.supabase.co >> temp_dns_output.txt 2>&1
if errorlevel 1 (
    echo [WARNING] DNS resolution failed for project endpoint
    echo %date% %time% - WARNING: DNS resolution failed for project endpoint >> "%LOG_PATH%"
) else (
    echo [SUCCESS] DNS resolution successful for project endpoint
    echo %date% %time% - DNS resolution successful for project endpoint >> "%LOG_PATH%"
)

:: Clean up temp file
if exist temp_dns_output.txt del temp_dns_output.txt

echo.
if "%1"=="--debug" pause
if "%1"=="-debug" pause

:: Step 3: Port Accessibility Tests
echo Step 3: Testing port accessibility...
echo %date% %time% - Testing port accessibility... >> "%LOG_PATH%"

echo Testing port 443 (HTTPS) to api.supabase.com...
powershell -NoProfile -Command "try { Test-NetConnection -ComputerName api.supabase.com -Port 443 -WarningAction SilentlyContinue | Select-Object TcpTestSucceeded } catch { Write-Output 'ERROR' }" > temp_port_api.txt 2>&1
find "True" temp_port_api.txt >nul
if errorlevel 1 (
    echo [FAILED] Port 443 not accessible to api.supabase.com
    echo %date% %time% - ERROR: Port 443 not accessible to api.supabase.com >> "%LOG_PATH%"
) else (
    echo [SUCCESS] Port 443 accessible to api.supabase.com
    echo %date% %time% - Port 443 accessible to api.supabase.com >> "%LOG_PATH%"
    set PORT_PASS=1
)

echo.
echo Testing port 443 (HTTPS) to supabase.com...
powershell -NoProfile -Command "try { Test-NetConnection -ComputerName supabase.com -Port 443 -WarningAction SilentlyContinue | Select-Object TcpTestSucceeded } catch { Write-Output 'ERROR' }" > temp_port_main.txt 2>&1
find "True" temp_port_main.txt >nul
if errorlevel 1 (
    echo [FAILED] Port 443 not accessible to supabase.com
    echo %date% %time% - ERROR: Port 443 not accessible to supabase.com >> "%LOG_PATH%"
) else (
    echo [SUCCESS] Port 443 accessible to supabase.com
    echo %date% %time% - Port 443 accessible to supabase.com >> "%LOG_PATH%"
)

echo.
echo Testing port 5432 (PostgreSQL) to project endpoint...
powershell -NoProfile -Command "try { Test-NetConnection -ComputerName tzmpwqiaqalrdwdslmkx.supabase.co -Port 5432 -WarningAction SilentlyContinue | Select-Object TcpTestSucceeded } catch { Write-Output 'ERROR' }" > temp_port_db.txt 2>&1
find "True" temp_port_db.txt >nul
if errorlevel 1 (
    echo [INFO] Port 5432 not accessible (expected - database port is restricted)
    echo %date% %time% - INFO: Port 5432 not accessible (expected) >> "%LOG_PATH%"
) else (
    echo [INFO] Port 5432 accessible (unexpected but not an issue)
    echo %date% %time% - INFO: Port 5432 accessible >> "%LOG_PATH%"
)

:: Clean up temp files
if exist temp_port_api.txt del temp_port_api.txt
if exist temp_port_main.txt del temp_port_main.txt
if exist temp_port_db.txt del temp_port_db.txt

echo.
if "%1"=="--debug" pause
if "%1"=="-debug" pause

:: Step 4: Proxy Detection
echo Step 4: Detecting proxy configuration...
echo %date% %time% - Detecting proxy configuration... >> "%LOG_PATH%"

:: Check system proxy settings
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" | find "ProxyEnable" | find "0x1" >nul
if errorlevel 1 (
    echo [INFO] No system proxy detected
    echo %date% %time% - INFO: No system proxy detected >> "%LOG_PATH%"
) else (
    echo [DETECTED] System proxy is enabled
    echo %date% %time% - INFO: System proxy detected >> "%LOG_PATH%"
    set PROXY_DETECTED=1
    
    echo Proxy server details:
    reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" | find "ProxyServer"
    reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" | find "ProxyServer" >> "%LOG_PATH%" 2>&1
)

:: Check environment variables for proxy
if defined HTTP_PROXY (
    echo [DETECTED] HTTP_PROXY environment variable set
    echo %date% %time% - INFO: HTTP_PROXY environment variable detected >> "%LOG_PATH%"
    set PROXY_DETECTED=1
    echo HTTP_PROXY: %HTTP_PROXY%
)

if defined HTTPS_PROXY (
    echo [DETECTED] HTTPS_PROXY environment variable set
    echo %date% %time% - INFO: HTTPS_PROXY environment variable detected >> "%LOG_PATH%"
    set PROXY_DETECTED=1
    echo HTTPS_PROXY: %HTTPS_PROXY%
)

echo.
if "%1"=="--debug" pause
if "%1"=="-debug" pause

:: Step 5: SSL/TLS Verification
echo Step 5: Testing SSL/TLS connectivity...
echo %date% %time% - Testing SSL/TLS connectivity... >> "%LOG_PATH%"

:: Test SSL connection using PowerShell
echo Testing SSL certificate for api.supabase.com...
powershell -NoProfile -Command "try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $req = [System.Net.WebRequest]::Create('https://api.supabase.com'); $req.GetResponse() | Out-Null; Write-Output 'SSL_SUCCESS' } catch { Write-Output 'SSL_ERROR: ' + $_.Exception.Message }" > temp_ssl_test.txt 2>&1

find "SSL_SUCCESS" temp_ssl_test.txt >nul
if errorlevel 1 (
    echo [FAILED] SSL/TLS connection failed
    echo %date% %time% - ERROR: SSL/TLS connection failed >> "%LOG_PATH%"
    echo Error details:
    type temp_ssl_test.txt | find "SSL_ERROR"
    type temp_ssl_test.txt >> "%LOG_PATH%" 2>&1
) else (
    echo [SUCCESS] SSL/TLS connection successful
    echo %date% %time% - SSL/TLS connection successful >> "%LOG_PATH%"
    set SSL_PASS=1
)

:: Clean up temp file
if exist temp_ssl_test.txt del temp_ssl_test.txt

echo.
if "%1"=="--debug" pause
if "%1"=="-debug" pause

:: Step 6: Latency Measurement
echo Step 6: Measuring network latency...
echo %date% %time% - Measuring network latency... >> "%LOG_PATH%"

echo Measuring latency to api.supabase.com...
for /f "tokens=5" %%i in ('ping -n 4 api.supabase.com ^| find "Average"') do set LATENCY=%%i
if defined LATENCY (
    echo Average latency to api.supabase.com: %LATENCY%ms
    echo %date% %time% - Average latency to api.supabase.com: %LATENCY%ms >> "%LOG_PATH%"
    set AVG_LATENCY=%LATENCY%
) else (
    echo Could not measure latency to api.supabase.com
    echo %date% %time% - Could not measure latency to api.supabase.com >> "%LOG_PATH%"
)

echo.
echo Measuring latency to supabase.com...
for /f "tokens=5" %%i in ('ping -n 4 supabase.com ^| find "Average"') do set LATENCY2=%%i
if defined LATENCY2 (
    echo Average latency to supabase.com: %LATENCY2%ms
    echo %date% %time% - Average latency to supabase.com: %LATENCY2%ms >> "%LOG_PATH%"
) else (
    echo Could not measure latency to supabase.com
    echo %date% %time% - Could not measure latency to supabase.com >> "%LOG_PATH%"
)

echo.
if "%1"=="--debug" pause
if "%1"=="-debug" pause

:: Step 7: Firewall Detection
echo Step 7: Detecting potential firewall issues...
echo %date% %time% - Detecting potential firewall issues... >> "%LOG_PATH%"

echo Checking Windows Firewall status...
netsh advfirewall show currentprofile | find "State" | find "ON" >nul
if errorlevel 1 (
    echo [INFO] Windows Firewall is off or not blocking
    echo %date% %time% - INFO: Windows Firewall is off or not blocking >> "%LOG_PATH%"
) else (
    echo [INFO] Windows Firewall is active
    echo %date% %time% - INFO: Windows Firewall is active >> "%LOG_PATH%"
    echo Note: Windows Firewall may be blocking connections
)

echo.
echo Checking for common antivirus interference...
sc query "Windows Defender Firewall" | find "RUNNING" >nul
if errorlevel 1 (
    echo [INFO] Windows Defender Firewall service not running
    echo %date% %time% - INFO: Windows Defender Firewall service not running >> "%LOG_PATH%"
) else (
    echo [INFO] Windows Defender Firewall service is running
    echo %date% %time% - INFO: Windows Defender Firewall service is running >> "%LOG_PATH%"
)

echo.
if "%1"=="--debug" pause
if "%1"=="-debug" pause

:: Step 8: Results Summary
echo ================================================
echo Network Diagnostic Results Summary
echo ================================================
echo.
echo %date% %time% - Generating diagnostic summary... >> "%LOG_PATH%"

echo Network connectivity: 
if %NETWORK_PASS% equ 1 (
    echo [PASS]
    echo - Network connectivity: [PASS] >> "%LOG_PATH%"
) else (
    echo [FAIL]
    echo - Network connectivity: [FAIL] >> "%LOG_PATH%"
)

echo DNS resolution: 
if %DNS_PASS% equ 1 (
    echo [PASS]
    echo - DNS resolution: [PASS] >> "%LOG_PATH%"
) else (
    echo [FAIL]
    echo - DNS resolution: [FAIL] >> "%LOG_PATH%"
)

echo Port accessibility: 
if %PORT_PASS% equ 1 (
    echo [PASS]
    echo - Port accessibility: [PASS] >> "%LOG_PATH%"
) else (
    echo [FAIL]
    echo - Port accessibility: [FAIL] >> "%LOG_PATH%"
)

echo Proxy status: 
if %PROXY_DETECTED% equ 1 (
    echo [DETECTED]
    echo - Proxy status: [DETECTED] >> "%LOG_PATH%"
) else (
    echo [NOT DETECTED]
    echo - Proxy status: [NOT DETECTED] >> "%LOG_PATH%"
)

echo SSL/TLS status: 
if %SSL_PASS% equ 1 (
    echo [PASS]
    echo - SSL/TLS status: [PASS] >> "%LOG_PATH%"
) else (
    echo [FAIL]
    echo - SSL/TLS status: [FAIL] >> "%LOG_PATH%"
)

echo Average latency: %AVG_LATENCY%ms
echo - Average latency: %AVG_LATENCY%ms >> "%LOG_PATH%"

echo Firewall status: 
if %NETWORK_PASS% equ 1 (
    echo [ALLOWING]
    echo - Firewall status: [ALLOWING] >> "%LOG_PATH%"
) else (
    echo [POTENTIALLY BLOCKING]
    echo - Firewall status: [POTENTIALLY BLOCKING] >> "%LOG_PATH%"
)

echo.
echo ================================================
echo Troubleshooting Recommendations
echo ================================================
echo.

if %NETWORK_PASS% equ 0 (
    echo RECOMMENDATION: Fix network connectivity first
    echo - Check your internet connection
    echo - Try resetting your network adapter
    echo - Contact your network administrator
    echo.
)

if %DNS_PASS% equ 0 (
    echo RECOMMENDATION: Fix DNS resolution issues
    echo - Try flushing DNS cache: ipconfig /flushdns
    echo - Change DNS servers to 8.8.8.8 and 8.8.4.4 (Google DNS)
    echo - Check if your ISP is blocking DNS queries
    echo.
)

if %PORT_PASS% equ 0 (
    echo RECOMMENDATION: Fix port accessibility
    echo - Configure firewall to allow outbound connections on port 443
    echo - Check if corporate firewall is blocking HTTPS connections
    echo - Try connecting from a different network
    echo.
)

if %PROXY_DETECTED% equ 1 (
    echo RECOMMENDATION: Configure proxy for Supabase CLI
    echo - Set HTTP_PROXY and HTTPS_PROXY environment variables
    echo - Configure proxy settings in your network
    echo - Try bypassing proxy for testing
    echo.
)

if %SSL_PASS% equ 0 (
    echo RECOMMENDATION: Fix SSL/TLS issues
    echo - Update your system certificates
    echo - Check system date and time
    echo - Disable SSL scanning in antivirus software
    echo.
)

if %AVG_LATENCY% gtr 500 (
    echo RECOMMENDATION: High latency detected
    echo - Consider using a VPN to route through different region
    echo - Try connecting from a different network
    echo - Latency may cause timeout issues with CLI operations
    echo.
)

echo.
echo ================================================
echo %date% %time% - Network diagnostic completed >> "%LOG_PATH%"
echo ================================================
echo.
echo Log file saved to: %LOG_PATH%
echo.

:: Determine exit code
set EXIT_CODE=0
if %NETWORK_PASS% equ 0 set EXIT_CODE=1
if %DNS_PASS% equ 0 set EXIT_CODE=1
if %PORT_PASS% equ 0 set EXIT_CODE=1
if %SSL_PASS% equ 0 set EXIT_CODE=1

if %EXIT_CODE% equ 0 (
    echo Overall result: ALL TESTS PASSED
    echo Your network should be ready for Supabase CLI operations.
) else (
    echo Overall result: SOME TESTS FAILED
    echo Please address the issues above before proceeding with CLI operations.
)

echo.
if "%1"=="--debug" pause
if "%1"=="-debug" pause
exit /b %EXIT_CODE%