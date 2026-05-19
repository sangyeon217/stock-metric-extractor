# 조건부 서식 임계값 기준

`main.py`가 이 파일을 읽어 출력 엑셀(`_output_YYYYMMDD.xlsx`)에 조건부 서식을
적용합니다. 기준을 바꾸려면 아래 규칙을 수정하면 됩니다.

## 작성 규칙

- `##` 제목 = 출력 엑셀의 **열 이름과 정확히 동일**해야 합니다.
- 각 규칙은 `- 조건 -> 색` 형식의 한 줄입니다.
  - 변수는 `value`(해당 셀 값), 색은 `green` 또는 `red` 만 사용합니다.
  - 단일 비교: `value < 0`, `value <= 0`, `value >= 30`, `value > 200`
  - 범위: `0 <= value < 10` (두 비교를 동시에 만족)
- 값이 비어 있는(숫자가 아닌) 셀은 색이 칠해지지 않습니다.
- `##`, `-` 로 시작하지 않는 줄은 모두 설명으로 간주해 무시합니다.

## 잉여현금흐름(조)

- value < 0 -> red

## PER(Trailing)

- 0 <= value < 10 -> green
- value < 0 -> red
- value >= 30 -> red

## PER(Forward)

- 0 <= value < 10 -> green
- value < 0 -> red
- value >= 30 -> red

## PBR

- value < 1 -> green

## ROE(%)

- value >= 15 -> green
- value <= 0 -> red

## 부채비율(%)

- value > 200 -> red

## 유동비율

- value < 1 -> red

## 순이익성장률(YoY %)

- value >= 100 -> green
- value < 0 -> red

## 매출성장률(YoY %)

- value >= 100 -> green
- value < 0 -> red

## 이익성장률(YoY %)

- value >= 100 -> green
- value < 0 -> red

## PEG(Trailing)

- value < 1 -> green
