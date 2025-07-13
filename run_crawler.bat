@echo off
chcp 65001 > nul

REM ▶ 프로젝트 경로 설정
set "BASE_DIR=D:\workspace\python-crawling-workspace"
set "VENV_DIR=%BASE_DIR%\.venv"
set "PYTHON_PATH=%VENV_DIR%\Scripts\python.exe"
set "MAIN_SCRIPT=%BASE_DIR%\main.py"
set "REQUIREMENTS_FILE=%BASE_DIR%\requirements.txt"

REM ▶ 로그 폴더 준비
if not exist "%BASE_DIR%\backup\log\error" mkdir "%BASE_DIR%\backup\log\error"
if not exist "%BASE_DIR%\backup\log\full" mkdir "%BASE_DIR%\backup\log\full"

REM ▶ 날짜 시각 생성
for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss"') do set "NOW=%%i"

set "TEMP_LOG=log_temp.txt"
set "FULL_LOG=%BASE_DIR%\backup\log\full\log_%NOW%.txt"
set "ERROR_LOG=%BASE_DIR%\backup\log\error\log_%NOW%.txt"

REM ▶ 가상환경 없으면 생성
if not exist "%PYTHON_PATH%" (
    echo [INFO] 가상환경이 없어 새로 생성합니다...
    cd /d "%BASE_DIR%"
    python -m venv .venv
)

REM ▶ 환경변수로 stdout 인코딩 강제 설정
set PYTHONIOENCODING=utf-8

REM ▶ python 실행 파일 존재 확인
if not exist "%PYTHON_PATH%" (
    echo [ERROR] Python 실행 파일을 찾을 수 없습니다: %PYTHON_PATH%
    pause
    exit /b 1
)

REM ▶ main.py 존재 확인
if not exist "%MAIN_SCRIPT%" (
    echo [ERROR] main.py 파일을 찾을 수 없습니다: %MAIN_SCRIPT%
    pause
    exit /b 1
)

REM ▶ 패키지 설치
echo [INFO] 필요한 패키지 설치 중...
"%PYTHON_PATH%" -m pip install --upgrade pip > nul
"%PYTHON_PATH%" -m pip install -r "%REQUIREMENTS_FILE%" > nul

REM ▶ main.py 실행
echo [INFO] main.py 실행 중...
"%PYTHON_PATH%" "%MAIN_SCRIPT%" > "%TEMP_LOG%" 2>&1

REM ▶ 전체 로그 저장
copy /Y "%TEMP_LOG%" "%FULL_LOG%" > nul
echo [INFO] 전체 로그 저장됨: %FULL_LOG%

REM ▶ 에러 포함 시 error 로그로 복사
findstr /i "traceback error exception" "%TEMP_LOG%" > nul
if %errorlevel% equ 0 (
    copy /Y "%TEMP_LOG%" "%ERROR_LOG%" > nul
    echo [WARNING] 에러 로그 저장됨: %ERROR_LOG%
) else (
    echo [INFO] 에러 없음
)

REM ▶ 임시 로그 삭제
del "%TEMP_LOG%"

REM ▶ output 폴더 열기 및 경로 표시
if exist "%BASE_DIR%\output" (
    echo [INFO] 결과 폴더 열기: %BASE_DIR%\output
    explorer "%BASE_DIR%\output"
) else (
    echo [INFO] output 폴더가 없습니다: %BASE_DIR%\output
)

REM ▶ 오래된 에러 로그 삭제
powershell -NoProfile -Command "Get-ChildItem -Path '%BASE_DIR%\backup\log\error' -File | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-180) } | Remove-Item -Force"

echo.
echo [INFO] 작업 완료. 창을 닫으시거나 아무 키나 누르세요.
pause
