@echo off
chcp 65001 > nul

REM ▶ 현재 bat 파일 경로 기준으로 BASE_DIR 설정
set "BASE_DIR=%~dp0"
set "BASE_DIR=%BASE_DIR:~0,-1%"
set "VENV_DIR=%BASE_DIR%\.venv"
set "PYTHON_PATH=%VENV_DIR%\Scripts\python.exe"
set "MAIN_SCRIPT=%BASE_DIR%\main.py"
set "REQUIREMENTS_FILE=%BASE_DIR%\requirements.txt"

REM ▶ 날짜 시각 문자열 생성
for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss"') do set "NOW=%%i"
for /f %%d in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd"') do set "TODAY=%%d"

REM ▶ 클라이언트 IP/컴퓨터 이름 가져오기 (이중화를 위한 식별자)
for /f %%c in ('powershell -NoProfile -Command "$env:COMPUTERNAME"') do set "CLIENT_NAME=%%c"

REM ▶ 로그 경로 구성 (날짜별 + 클라이언트별)
set "FULL_LOG_DIR=%BASE_DIR%\backup\log\full\%TODAY%\%CLIENT_NAME%"
set "ERROR_LOG_DIR=%BASE_DIR%\backup\log\error\%TODAY%\%CLIENT_NAME%"
set "FULL_LOG=%FULL_LOG_DIR%\log_%NOW%.txt"
set "ERROR_LOG=%ERROR_LOG_DIR%\log_%NOW%.txt"

REM ▶ 로그 폴더 생성
if not exist "%FULL_LOG_DIR%" mkdir "%FULL_LOG_DIR%"
if not exist "%ERROR_LOG_DIR%" mkdir "%ERROR_LOG_DIR%"

REM ▶ 클라이언트 정보 출력
echo [INFO] 클라이언트: %CLIENT_NAME%
echo [INFO] 로그 경로: %FULL_LOG_DIR%

REM ▶ 가상환경 없으면 생성
if not exist "%PYTHON_PATH%" (
    echo [INFO] 가상환경이 없어 새로 생성합니다...
    cd /d "%BASE_DIR%"
    python -m venv .venv
)

REM ▶ 인코딩 환경 설정
set PYTHONIOENCODING=utf-8

REM ▶ 경로 유효성 검사
if not exist "%PYTHON_PATH%" (
    echo [ERROR] Python 실행 파일을 찾을 수 없습니다: %PYTHON_PATH%
    pause
    exit /b 1
)
if not exist "%MAIN_SCRIPT%" (
    echo [ERROR] main.py 파일을 찾을 수 없습니다: %MAIN_SCRIPT%
    pause
    exit /b 1
)

REM ▶ 패키지 설치
echo [INFO] 필요한 패키지 설치 중...
"%PYTHON_PATH%" -m pip install --upgrade pip > nul
"%PYTHON_PATH%" -m pip install -r "%REQUIREMENTS_FILE%" > nul

REM ▶ main.py 실행 및 로그 저장
echo [INFO] main.py 실행 중...
"%PYTHON_PATH%" "%MAIN_SCRIPT%" > log_temp.txt 2>&1
copy /Y log_temp.txt "%FULL_LOG%" > nul
echo [INFO] 전체 로그 저장됨: %FULL_LOG%

REM ▶ 에러 발생 여부 확인 → 에러 로그로 백업
findstr /i "traceback error exception" log_temp.txt > nul
if %errorlevel% equ 0 (
    copy /Y log_temp.txt "%ERROR_LOG%" > nul
    echo [WARNING] 에러 로그 저장됨: %ERROR_LOG%
) else (
    echo [INFO] 에러 없음
)

REM ▶ 임시 로그 삭제
del log_temp.txt

REM ▶ 결과 마크다운 폴더 열기: markdown/output/YYYY-MM-DD
set "RESULT_PATH=%BASE_DIR%\markdown\output\%TODAY%"
if exist "%RESULT_PATH%" (
    echo [INFO] 결과 폴더 열기: %RESULT_PATH%
    explorer "%RESULT_PATH%"
) else (
    echo [INFO] 결과 폴더가 없습니다: %RESULT_PATH%
)

REM ▶ 180일 지난 로그 폴더 삭제 (날짜별 + 클라이언트별 구조 고려)
echo [INFO] 오래된 로그 폴더 정리 중...
powershell -NoProfile -Command ^
"Get-ChildItem -Path '%BASE_DIR%\backup\log\full' -Directory -Recurse | ^
 Where-Object { $_.PSIsContainer -and $_.LastWriteTime -lt (Get-Date).AddDays(-180) } | Remove-Item -Recurse -Force"

powershell -NoProfile -Command ^
"Get-ChildItem -Path '%BASE_DIR%\backup\log\error' -Directory -Recurse | ^
 Where-Object { $_.PSIsContainer -and $_.LastWriteTime -lt (Get-Date).AddDays(-180) } | Remove-Item -Recurse -Force"

echo.
echo [INFO] 작업 완료. 창을 닫으시거나 아무 키나 누르세요.
pause
echo [INFO] 크롤러가 종료되었습니다.
exit /b 0