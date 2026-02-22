# 📊 Stock-Metric-Extractor

**Stock-Metric-Extractor**는 엑셀에 정리된 주식 리스트를 읽어와 야후 파이낸스(Yahoo Finance)에서 실시간 재무 지표를 추출하여 엑셀 파일에 자동으로 추가해주는 데이터 분석 도구입니다.

단순한 주가 조회를 넘어 **밸류에이션, 수익성, 성장성** 등 퀀트 투자와 기업 분석에 필수적인 데이터를 한 번의 실행으로 정리할 수 있습니다.

---

## ✨ 주요 기능

* **멀티 시장 지원**: 국내(KOSPI, KOSDAQ) 및 해외(NYSE, NASDAQ 등) 시장의 종목 데이터를 동시에 처리 가능합니다.
    * **국내 주식 PBR 보정** : 야후 파이낸스에서 국내 종목의 PBR 데이터가 누락되어 출력되는 문제를 해결하기 위해, 총부채(Total Debt)와 부채비율(Debt to Equity)을 이용해 자본을 역산하여 PBR을 직접 계산하는 Fallback 로직을 내장하고 있습니다.
* **심층 데이터 수집**:
    * **기본 정보**: 티커, 섹터, 현재가, 시가총액(조 단위)
    * **밸류에이션**: PER(Trailing/Forward), PBR, PEG Ratio
    * **수익성/건전성**: ROE, 영업이익률, 부채비율, 유동비율, 잉여현금흐름(FCF)
    * **성장성 지표**: 전년 대비(YoY) 매출/이익/순이익 성장률
* **자동 결과 생성**: 실행 시점의 날짜가 포함된 새로운 결과 파일(`_output_YYYYMMDD.xlsx`)을 자동으로 생성합니다.

---

## 🛠 설치 및 환경 설정

본 프로젝트는 Python 3.8 이상에서 동작합니다. 아래 명령어를 통해 필요한 라이브러리를 한 번에 설치할 수 있습니다.

```bash
# 1. 레포지토리 클론
git clone [https://github.com/sangyeon217/stock-metric-extractor.git](https://github.com/sangyeon217/stock-metric-extractor.git)
cd stock-metric-extractor

# 2. 필수 라이브러리 설치
pip install -r requirements.txt
```

---

## 🚀 사용 방법
코드 내 `process_stock_file` 함수를 호출하여 파일을 처리합니다.

```python
# 사용 예시: 국내 종목 리스트 처리
process_stock_file(
    file_path="files/domestic/data.xlsx", 
    market_type="국내",    # "국내" 또는 "해외" 선택
    column_name="종목명",   # 엑셀 내 종목명/종목코드 또는 티커가 적힌 열 제목
    has_ticker=False       # 티커 정보가 이미 있다면 True, 종목명/종목코드 정보만 있다면 False
)
```

---

## 📝 데이터 항목 상세
| 카테고리 | 컬럼명 | 설명 | 
|-|-|-|
|기본 정보|티커, 섹터, 현재가, 시가총액(조)|기업 기본 프로필 및 규모|
|밸류에이션|PER(Trailing/Forward), PBR, PEG|주가 가치 평가 지표|
|수익성|ROE(%), 영업이익률(%)|기업의 자산 효율성 및 수익 능력|
|성장성|매출/이익/순이익 성장률(YoY %)|전년 대비 기업의 성장 속도|
|재무 건전성|부채비율(%), 유동비율, 잉여현금흐름|리스크 관리 및 실제 현금 흐름|

---

## ⚠️ 주의 사항
1. 국내 종목 티커: 야후 파이낸스 조회를 위해 국내 종목은 `005930.KS`와 같은 형식을 사용합니다. (내부 함수를 통해 자동 변환을 지원합니다.)
2. API 호출 제한: 서버 과부하 및 차단을 방지하기 위해 각 종목 조회 사이에 `time.sleep(0.5)`이 설정되어 있습니다.
3. 데이터 가용성: 야후 파이낸스 서버 상황이나 상장 상태에 따라 일부 종목의 지표가 None으로 표시될 수 있습니다.

---

## 📄 라이선스
이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자유롭게 수정 및 배포가 가능합니다.
