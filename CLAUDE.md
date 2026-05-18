# CLAUDE.md

이 파일은 Claude Code(claude.ai/code)가 이 저장소에서 작업할 때 참고하는 가이드입니다.

## 프로젝트 개요

구글 드라이브의 네이티브 구글 시트(또는 로컬 엑셀)에 정리된 주식 리스트를 읽어 Yahoo Finance(yfinance)에서 재무 지표를 수집한 뒤, 날짜가 붙은 새 엑셀 파일(`_output_YYYYMMDD.xlsx`)로 드라이브 동기화 폴더에 저장하는 단일 파일 Python 스크립트(`main.py`)입니다. 국내(KOSPI/KOSDAQ)와 해외(NYSE/NASDAQ) 시장을 모두 지원합니다.

## 환경 설정

```bash
pip install -r requirements.txt  # Python 3.8 이상
```

**기본 입력**: 구글 드라이브 동기화 폴더의 네이티브 구글 시트
- `<DRIVE_BASE>/국내주식_기업.gsheet`(국내), `<DRIVE_BASE>/해외주식_기업.gsheet`(해외)
- `DRIVE_BASE` 기본값: `~/Google Drive/내 드라이브/Stocks`
  - "내 드라이브"는 한글 로케일 기준 — 영문 계정은 `My Drive`
  - `STOCK_DRIVE_BASE` 환경변수로 폴더를 직접 지정 가능
- **필수 전제**: 각 구글 시트를 "링크가 있는 모든 사용자: 뷰어"로 공유해야 함.
  `.gsheet`는 doc_id만 담은 포인터라, doc_id를 파싱해 구글 export URL
  (`/export?format=xlsx`)에서 xlsx로 내려받아 읽습니다. 비공개 시트면 로그인
  HTML이 반환돼 실패하며, 해당 경우 안내 메시지를 stderr로 출력합니다.
- 로컬 `.xlsx` 경로를 넘기면 기존처럼 `pd.read_excel`로 읽습니다(하위호환).

## 실행

```bash
python main.py
```

또는 직접 함수 호출:

```python
import os
from main import process_stock_file, DRIVE_BASE

# 국내 — 종목명 또는 6자리 종목코드가 담긴 열
process_stock_file(file_path=os.path.join(DRIVE_BASE, "국내주식_기업.gsheet"),
                    market_type="국내", column_name="종목명", has_ticker=False)

# 해외 — 티커가 이미 담긴 열
process_stock_file(file_path=os.path.join(DRIVE_BASE, "해외주식_기업.gsheet"),
                    market_type="해외", column_name="티커", has_ticker=True)
```

## 코드 구조

모든 로직은 `main.py` 한 파일에 있으며 네 개의 함수로 구성됩니다.

**`load_input_df(file_path)`** — 입력 DataFrame 로드. `.gsheet`면 doc_id를 파싱해 구글 export URL에서 xlsx로 내려받고, 그 외 경로는 `pd.read_excel`로 읽습니다. 파일 미존재·비공개 시트·파싱 실패 시 안내 메시지를 stderr로 출력하고 `None`을 반환합니다.

**`_load_krx_listing()` / `get_domestic_ticker(query)`** — 종목명 또는 6자리 종목코드를 Yahoo Finance 티커(`005930.KS`, `035720.KQ`)로 변환합니다. KIND 상장법인목록 다운로드(`kind.krx.co.kr/corpgeneral/corpList.do`)를 `_load_krx_listing()`으로 받아 Code/Name/Market(유가→KOSPI, 코스닥→KOSDAQ, 코넥스→KONEX)로 정규화한 뒤 모듈 전역 변수 `df_krx`에 최초 1회만 캐싱합니다.

**`get_overseas_ticker(query)`** — Yahoo Finance 검색 API(`query2.finance.yahoo.com/v1/finance/search`)에 종목명을 쿼리해 첫 번째 심볼을 반환합니다.

**`process_stock_file(...)`** — 메인 파이프라인: `load_input_df`로 입력 로드 → 행 순회 → 티커 변환 → `yf.Ticker(ticker).info` 호출 → DataFrame에 지표 기록 → 결과 엑셀 저장.

## 주요 구현 세부사항

- **국내 PBR 보정**: KRX 종목은 `yf.Ticker.info['priceToBook']`이 자주 누락됩니다. 없을 경우 `equity = (totalDebt / debtToEquity) * 100` 으로 자본을 역산한 뒤 `PBR = marketCap / equity`로 직접 계산하는 Fallback 로직이 내장되어 있습니다.
- **호출 제한 방지**: 각 티커 조회 후 `time.sleep(0.5)` 적용.
- **출력 파일명**: `{입력경로(확장자 제거)}_output_{YYYYMMDD}.xlsx` — 입력이 드라이브 동기화 폴더 안이면 결과도 같은 폴더에 저장돼 데스크톱 앱이 자동 업로드합니다. 원본/구글 시트는 수정하지 않습니다.
- **금액 단위**: 시가총액·잉여현금흐름은 10¹²으로 나눠 조(兆) 단위로 저장합니다.
- **비율 단위**: ROE, 영업이익률, 각종 성장률은 `* 100`을 해서 퍼센트 값으로 저장합니다.
