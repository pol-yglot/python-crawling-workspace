# 뉴스 크롤러 (News Crawler)

## 프로젝트 개요

금융 및 보안 관련 뉴스를 자동으로 크롤링하고 정리하여 마크다운 형식으로 저장하는 Python 프로그램입니다.

## 프로젝트 기능 요약

- **다중 사이트 크롤링**
  - KISA (한국인터넷진흥원) - 보안 관련 공지사항
  - 서울경제 - 금융 뉴스
  - IT조선 - IT/금융 뉴스

- **자동 마크다운 생성**
  - 출처별로 그룹핑된 뉴스 요약
  - 날짜별 자동 저장 (`markdown/output/YYYY-MM-DD/`)
  - 블로그 포스팅에 최적화된 형식

- **키워드 추출 기능** (선택적)
  - KoNLPy를 활용한 주요 키워드 추출
  - 빈도 분석을 통한 핵심 키워드 도출

- **로깅 시스템**
  - 클라이언트별 로그 분리 (컴퓨터명 기준 이중화)
  - 전체 로그 및 에러 로그 자동 저장
  - 180일 이상된 로그 자동 삭제

## Requirements

### 필수 패키지

```txt
beautifulsoup4
requests
selenium
webdriver-manager
konlpy
```

### 추가 요구사항

- **Python 3.7 이상**
- **Chrome 브라우저** (Selenium 사용)
- **JDK 8 이상** (konlpy 키워드 추출 기능 사용 시)

## 실행 방법

### 방법 1: 배치 파일 실행 (권장)

```bash
run_crawler.bat
```

- 자동으로 가상환경 생성 및 패키지 설치
- 클라이언트별 로그 자동 저장
- 실행 완료 후 결과 폴더 자동 열기

### 방법 2: Python 직접 실행

```bash
# 1. 가상환경 생성 (최초 1회)
python -m venv .venv

# 2. 가상환경 활성화 (Windows)
.venv\Scripts\activate

# 3. 패키지 설치
pip install -r requirements.txt

# 4. 프로그램 실행
python main.py
```

### 방법 3: 가상환경 자동 설정 후 실행

```bash
# 가상환경 없이 바로 실행 (자동 생성)
python main.py
```

## 프로젝트 구조

```
python-crawling-workspace/
├── crawler/              # 크롤링 모듈
│   ├── kisa.py          # KISA 크롤링
│   ├── sedaily.py       # 서울경제 크롤링
│   └── itchosun.py      # IT조선 크롤링
├── keywords/             # 키워드 추출 모듈
│   └── extractor.py     # KoNLPy를 활용한 키워드 분석
├── markdown/             # 마크다운 생성 모듈
│   ├── writer.py        # 마크다운 파일 생성
│   └── output/          # 생성된 마크다운 저장 위치
├── backup/
│   └── log/             # 로그 저장 위치
│       ├── full/        # 전체 로그 (날짜/클라이언트별)
│       └── error/        # 에러 로그 (날짜/클라이언트별)
├── main.py              # 메인 실행 파일
├── run_crawler.bat      # 배치 실행 파일
└── requirements.txt     # 필수 패키지 목록
```

## 출력 파일 위치

- **마크다운 파일**: `markdown/output/YYYY-MM-DD/뉴스요약_YYYYMMDD_HHMM.md`
- **로그 파일**: `backup/log/full/YYYY-MM-DD/클라이언트명/log_YYYYMMDD_HHMMSS.txt`
- **에러 로그**: `backup/log/error/YYYY-MM-DD/클라이언트명/log_YYYYMMDD_HHMMSS.txt`

## 주의사항

1. **Chrome 드라이버 경로**: `crawler/kisa.py` 파일의 17번째 줄에서 chromedriver 경로를 환경에 맞게 수정해야 합니다.
2. **키워드 추출 기능**: Java가 설치되지 않은 경우 경고 메시지가 출력되지만, 프로그램은 정상적으로 동작합니다.
3. **네트워크 연결**: 크롤링 대상 사이트에 접근할 수 있는 네트워크 환경이 필요합니다.

## 라이선스

이 프로젝트는 개인 사용을 목적으로 제작되었습니다.

