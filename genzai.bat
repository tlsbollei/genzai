@echo off
setlocal enabledelayedexpansion
color 0C

echo.
echo   	                             
echo 	######  ###### #    # ######   ##   # 
echo 	#       #      ##   #     #   #  #  # 
echo 	#  #### #####  # #  #    #   #    # # 
echo 	#     # #      #  # #   #    ###### # 
echo 	#     # #      #   ##  #     #    # # 
echo 	####### ###### #    # ###### #    # # 
echo                                   
echo.

set "log_file=results.txt"
set "target_domain="
set "target_ip="
set "local_network="
set "dns_records=www ns mx a cname txt"

echo [+] Result Log > "%log_file%"
echo [+] ================ >> "%log_file%"
echo [+] %date% %time% >> "%log_file%"
echo. >> "%log_file%"

:arp_scan
echo [+] Scanning local network for devices using ARP...
for /L %%i in (1,1,254) do (
    set "ip=192.168.1.%%i"  REM Change this to your local subnet
    ping -n 1 -w 1 !ip! >nul
    if !errorlevel! equ 0 (
        echo [+] Device Found: !ip! >> "%log_file%"
        arp -a !ip! >> "%log_file%"
    )
)
echo. >> "%log_file%"

:dns_enum
echo [+] Enter target domain for DNS enumeration:
set /p target_domain="> "
echo [+] Enumerating DNS records for !target_domain! ... >> "%log_file%"
for %%r in (%dns_records%) do (
    nslookup -type=%%r !target_domain! >> "%log_file%"
)
echo. >> "%log_file%"

:http_header_check
echo [+] Enter target IP or domain for HTTP header security check:
set /p target_ip="> "
echo [+] Checking HTTP security headers for !target_ip! ... >> "%log_file%"
curl -I !target_ip! >> "%log_file%"
echo. >> "%log_file%"

:check_services
echo [+] Checking for common services on !target_ip! ...
echo [+] Checking FTP service... >> "%log_file%"
echo | ftp -n !target_ip! >nul 2>&1
if !errorlevel! equ 0 (
    echo [+] FTP service is running. >> "%log_file%"
) else (
    echo [+] No FTP service detected. >> "%log_file%"
)

echo [+] Checking SMB service... >> "%log_file%"
net use \\!target_ip!\IPC$ "" >nul 2>&1
if !errorlevel! equ 0 (
    echo [+] SMB service is running. >> "%log_file%"
) else (
    echo [+] No SMB service detected. >> "%log_file%"
)

echo [+] Checking SSH service... >> "%log_file%"
plink -ssh !target_ip! -batch exit >nul 2>&1
if !errorlevel! equ 0 (
    echo [+] SSH service is running. >> "%log_file%"
) else (
    echo [+] No SSH service detected. >> "%log_file%"
)
echo. >> "%log_file%"

echo [+] Job done. Log file : %log_file%
pause
exit