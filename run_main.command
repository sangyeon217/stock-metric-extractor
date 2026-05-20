#!/bin/bash
# stock-metric-extractor 실행 스크립트

cd "$(dirname "$0")"

echo "=== stock-metric-extractor 시작 ==="
echo ""

# Python 명령어 확인
PYTHON=$(which python3 2>/dev/null || which python 2>/dev/null)
if [ -z "$PYTHON" ]; then
    echo "[ERROR] Python을 찾을 수 없습니다."
    read -p "엔터를 눌러 종료..."
    exit 1
fi
echo "[INFO] Python: $PYTHON ($($PYTHON --version 2>&1))"

# 의존성 설치
echo ""
echo "[INFO] 의존성 설치 중..."
$PYTHON -m pip install -r requirements.txt -q 2>&1
if [ $? -ne 0 ]; then
    echo "[WARN] 일부 패키지 설치가 실패했을 수 있습니다. 실행을 계속합니다..."
fi

echo ""
echo "[INFO] main.py 실행 중..."
echo "-------------------------------------------"
$PYTHON main.py 2>&1
EXIT_CODE=$?

echo "-------------------------------------------"
if [ $EXIT_CODE -eq 0 ]; then
    echo "[완료] 스크립트가 정상적으로 종료되었습니다."
    osascript -e 'display notification "출력 파일이 Google Drive에 저장됐습니다." with title "✅ 주식 지표 추출 완료"'
else
    echo "[경고] 스크립트가 종료 코드 $EXIT_CODE 로 종료되었습니다."
    osascript -e 'display notification "오류가 발생했습니다. 로그를 확인하세요." with title "❌ 주식 지표 추출 실패"'
fi

echo ""
read -p "엔터를 눌러 창을 닫으세요..."
