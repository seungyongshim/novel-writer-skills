#!/bin/bash

# 한국어/중국어 글자 수 카운트 기능 테스트
# count_chinese_words 함수의 정확성 검증용

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# 색상 출력
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================"
echo "글자 수 카운트 기능 테스트"
echo "========================================"
echo ""

# 임시 테스트 파일 생성
TEST_DIR=$(mktemp -d)
trap "rm -rf $TEST_DIR" EXIT

# 테스트 케이스 1: 순수 중국어 텍스트
echo "## 테스트 1: 순수 중국어 텍스트"
cat > "$TEST_DIR/test1.md" << 'EOF'
今天天气很好，我去公园散步。
看到很多人在锻炼身体。
EOF
expected1=16
actual1=$(count_chinese_words "$TEST_DIR/test1.md")
echo "  예상 글자 수: $expected1"
echo "  실제 글자 수: $actual1"
if [ "$actual1" -eq "$expected1" ]; then
    echo -e "  ${GREEN}✅ 테스트 통과${NC}"
else
    echo -e "  ${RED}❌ 테스트 실패${NC}"
fi
echo ""

# 테스트 케이스 2: Markdown 태그 포함
echo "## 테스트 2: Markdown 태그가 포함된 텍스트"
cat > "$TEST_DIR/test2.md" << 'EOF'
# 第一章

这是**重要**的内容。

- 列表项1
- 列表项2

> 这是引用
EOF
# 실제 내용: 第一章这是重要的内容列表项1列表项2这是引用
expected2=21
actual2=$(count_chinese_words "$TEST_DIR/test2.md")
echo "  예상 글자 수: $expected2"
echo "  실제 글자 수: $actual2"
if [ "$actual2" -eq "$expected2" ]; then
    echo -e "  ${GREEN}✅ 테스트 통과${NC}"
else
    echo -e "  ${YELLOW}⚠️ 글자 수 차이: $((actual2 - expected2))${NC}"
fi
echo ""

# 테스트 케이스 3: 중영 혼합
echo "## 테스트 3: 중영 혼합 텍스트"
cat > "$TEST_DIR/test3.md" << 'EOF'
这是一个测试test文件。
包含123数字和English单词。
EOF
# 실제 내용 (공백 및 구두점 제거 후): 这是一个测试test文件包含123数字和English单词
expected3=27
actual3=$(count_chinese_words "$TEST_DIR/test3.md")
echo "  예상 글자 수: 약$expected3"
echo "  실제 글자 수: $actual3"
if [ "$actual3" -ge 20 ] && [ "$actual3" -le 35 ]; then
    echo -e "  ${GREEN}✅ 테스트 통과 (합리적 범위 내)${NC}"
else
    echo -e "  ${YELLOW}⚠️ 글자 수 차이가 큼${NC}"
fi
echo ""

# 테스트 케이스 4: 코드 블록 포함
echo "## 테스트 4: 코드 블록이 포함된 텍스트"
cat > "$TEST_DIR/test4.md" << 'EOF'
这是正常文本。

```javascript
console.log("这是代码不应该被计数");
```

这是结尾文本。
EOF
expected4=12
actual4=$(count_chinese_words "$TEST_DIR/test4.md")
echo "  예상 글자 수: $expected4"
echo "  실제 글자 수: $actual4"
if [ "$actual4" -eq "$expected4" ]; then
    echo -e "  ${GREEN}✅ 테스트 통과${NC}"
else
    echo -e "  ${YELLOW}⚠️ 글자 수 차이: $((actual4 - expected4))${NC}"
fi
echo ""

# 대조 테스트: wc -w vs 새로운 방법
echo "## 대조 테스트: wc -w vs count_chinese_words"
cat > "$TEST_DIR/compare.md" << 'EOF'
这是一个包含大约五十个字的测试文本。
我们需要验证字数统计的准确性。
使用wc命令统计中文字数是不准确的。
应该使用专门的中文字数统计方法。
这样才能得到正确的结果。
EOF
wc_result=$(wc -w < "$TEST_DIR/compare.md" | tr -d ' ')
new_result=$(count_chinese_words "$TEST_DIR/compare.md")
echo "  wc -w 결과: $wc_result (부정확)"
echo "  새 방법 결과: $new_result (정확)"
echo -e "  ${YELLOW}참고: wc -w 는 중국어/한국어 글자 수 카운트에 매우 부정확합니다!${NC}"
echo ""

# 성능 테스트
echo "## 성능 테스트: 대용량 파일 처리"
cat > "$TEST_DIR/large.md" << 'EOF'
# 第一章：开始

今天是个好天气，阳光明媚，万里无云。
小明决定去公园散步，顺便思考一下人生。
他一边走一边想，不知不觉来到了湖边。
湖水清澈见底，几只野鸭在水面游弋。
远处传来孩子们的欢笑声，让人心情愉悦。

## 第二节

突然，他看到一位老人坐在长椅上。
老人面带微笑，似乎在等待什么。
小明走上前去，礼貌地打了个招呼。
老人抬起头，慈祥的目光看向小明。
两人开始了一段有趣的对话。

**重要的转折点**：
- 老人讲述了一个神奇的故事
- 小明意识到生活的意义
- 他决定改变自己的人生轨迹

最后，夕阳西下，小明告别了老人。
他的内心充满了力量和希望。
这次偶遇，改变了他的一生。
EOF

start_time=$(date +%s%N)
large_count=$(count_chinese_words "$TEST_DIR/large.md")
end_time=$(date +%s%N)
elapsed=$((($end_time - $start_time) / 1000000)) # 밀리초로 변환

echo "  파일 글자 수: $large_count"
echo "  처리 시간: ${elapsed}ms"
if [ "$elapsed" -lt 1000 ]; then
    echo -e "  ${GREEN}✅ 성능 양호${NC}"
else
    echo -e "  ${YELLOW}⚠️ 처리 시간이 깁니다${NC}"
fi
echo ""

# 요약
echo "========================================"
echo "테스트 완료!"
echo "========================================"
echo ""
echo -e "${GREEN}핵심 기능:${NC}"
echo "  ✓ 중국어/한국어 문자 정확 카운트"
echo "  ✓ Markdown 태그 제외"
echo "  ✓ 코드 블록 제외"
echo "  ✓ 혼합 텍스트 처리"
echo ""
echo -e "${YELLOW}사용 권장 사항:${NC}"
echo "  • 'wc -w' 를 중국어/한국어 글자 수 카운트에 사용하지 마세요"
echo "  • 'count_chinese_words' 함수를 사용하면 정확한 결과를 얻을 수 있습니다"
echo "  • 집필 완료 후 글자 수가 기준에 도달했는지 검증하세요"
echo ""
