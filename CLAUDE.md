# CLAUDE.md

이 파일은 Claude Code(claude.ai/code)가 이 저장소에서 작업할 때 참고하는 가이드입니다.

## 프로젝트 개요

엑셀 파일에 정리된 주식 리스트를 읽어 Yahoo Finance(yfinance)에서 재무 지표를 수집한 뒤, 날짜가 붙은 새 엑셀 파일(`_output_YYYYMMDD.xlsx`)로 저장하는 단일 파일 Python 스크립트(`main.py`)입니다. 국내(KOSPI/KOSDAQ)와 해외(NYSE/NASDAQ) 시장을 모두 지원합니다.

## 환경 설정

```bash
pip install -r requirements.txt  # Python 3.8 이상
```

기본 입력 파일 경로: `files/domestic/data.xlsx`(국내), `files/overseas/data.xlsx`(해외)

## 실행

```bash
python main.py
```

또는 직접 함수 호출:

```python
# 국내 — 종목명 또는 6자리 종목코드가 담긴 열
process_stock_file(file_path="files/domestic/data.xlsx", market_type="국내", column_name="종목명", has_ticker=False)

# 해외 — 티커가 이미 담긴 열
process_stock_file(file_path="files/overseas/data.xlsx", market_type="해외", column_name="티커", has_ticker=True)
```

## 코드 구조

모든 로직은 `main.py` 한 파일에 있으며 세 개의 함수로 구성됩니다.

**`get_domestic_ticker(query)`** — 종목명 또는 6자리 종목코드를 Yahoo Finance 티커(`005930.KS`, `035720.KQ`)로 변환합니다. `FinanceDataReader.StockListing('KRX')` 결과를 모듈 전역 변수 `df_krx`에 최초 1회만 로드하여 캐싱합니다.

**`get_overseas_ticker(query)`** — Yahoo Finance 검색 API(`query2.finance.yahoo.com/v1/finance/search`)에 종목명을 쿼리해 첫 번째 심볼을 반환합니다.

**`process_stock_file(...)`** — 메인 파이프라인: 엑셀 읽기 → 행 순회 → 티커 변환 → `yf.Ticker(ticker).info` 호출 → DataFrame에 지표 기록 → 결과 엑셀 저장.

## 주요 구현 세부사항

- **국내 PBR 보정**: KRX 종목은 `yf.Ticker.info['priceToBook']`이 자주 누락됩니다. 없을 경우 `equity = (totalDebt / debtToEquity) * 100` 으로 자본을 역산한 뒤 `PBR = marketCap / equity`로 직접 계산하는 Fallback 로직이 내장되어 있습니다.
- **호출 제한 방지**: 각 티커 조회 후 `time.sleep(0.5)` 적용.
- **출력 파일명**: `{원본경로}_output_{YYYYMMDD}.xlsx` — 원본 파일은 수정하지 않습니다.
- **금액 단위**: 시가총액·잉여현금흐름은 10¹²으로 나눠 조(兆) 단위로 저장합니다.
- **비율 단위**: ROE, 영업이익률, 각종 성장률은 `* 100`을 해서 퍼센트 값으로 저장합니다.
