#!/usr/bin/env bash
# 텍스트 자연스러움 자체 점검 (오프라인): 접속사/빈말 밀도, 문장 길이 통계, 추상어 밀도

set -e

SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR/common.sh"

PROJECT_ROOT=$(get_project_root)

FILE_PATH="$1"
if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
  echo "사용법: scripts/bash/text-audit.sh <file>"
  exit 1
fi

# 설정 선택: 프로젝트 spec/knowledge 우선, 그 다음 .specify/templates/knowledge
CFG_PROJECT="$PROJECT_ROOT/spec/knowledge/audit-config.json"
CFG_TEMPLATE="$PROJECT_ROOT/.specify/templates/knowledge/audit-config.json"
if [ -f "$CFG_PROJECT" ]; then
  CFG="$CFG_PROJECT"
elif [ -f "$CFG_TEMPLATE" ]; then
  CFG="$CFG_TEMPLATE"
else
  CFG=""
fi

python3 - "$FILE_PATH" "$CFG" << 'PY'
import json, re, sys, os, math

path = sys.argv[1]
cfg_path = sys.argv[2] if len(sys.argv) > 2 else ''

text = open(path, 'r', encoding='utf-8', errors='ignore').read()

default_cfg = {
  "connector_phrases": ["우선","다음으로","다시","그런 다음","그러나","총괄하면","종합하면","어느 정도","주지하다시피","현재","~에 따라"],
  "empty_phrases": ["광범위한 관심","화제를 모은","영향이 깊은","중요한 의미를 가진","효과적으로 향상","일정한 지도적 의미","우리의 생각을 가치가 있는"],
  "cliche_pairs": [],
  "sentence_length": {"max_run_long":4, "max_run_short":5, "short_threshold":12, "long_threshold":35},
  "abstract_nouns": ["가치","의미","인식","체계","모델","경로","방법론","추세"],
  "min_concrete_details": 3
}

cfg = default_cfg
if cfg_path and os.path.exists(cfg_path):
  try:
    with open(cfg_path, 'r', encoding='utf-8') as f:
      loaded = json.load(f)
      cfg.update(loaded)
  except Exception:
    pass

def count_occurrences(text, phrases):
  res = {}
  for p in phrases:
    if not p: continue
    res[p] = len(re.findall(re.escape(p), text))
  return res

def split_sentences(t):
  parts = re.split(r'[。！？!?\n]+', t)
  return [s.strip() for s in parts if s.strip()]

def sentence_lengths(sents):
  lens = [len(s) for s in sents]
  if not lens:
    return lens, 0, 0
  avg = sum(lens)/len(lens)
  var = sum((x-avg)**2 for x in lens)/len(lens)
  return lens, avg, math.sqrt(var)

def runs(lens, short_th, long_th):
  run_short = 0; run_long = 0
  max_run_short = 0; max_run_long = 0
  marks = []
  for i, L in enumerate(lens):
    if L <= short_th:
      run_short += 1; max_run_short = max(max_run_short, run_short); run_long = 0
    elif L >= long_th:
      run_long += 1; max_run_long = max(max_run_long, run_long); run_short = 0
    else:
      run_short = 0; run_long = 0
  return max_run_short, max_run_long

def abstract_density(sent, abstract_words):
  cnt = sum(len(re.findall(re.escape(w), sent)) for w in abstract_words)
  return cnt

connectors = count_occurrences(text, cfg["connector_phrases"])
empties = count_occurrences(text, cfg["empty_phrases"])
sents = split_sentences(text)
lens, avg, std = sentence_lengths(sents)
mx_run_short, mx_run_long = runs(lens, cfg["sentence_length"]["short_threshold"], cfg["sentence_length"]["long_threshold"])

abstract_scores = [(i, abstract_density(s, cfg["abstract_nouns"])) for i, s in enumerate(sents)]
abstract_scores.sort(key=lambda x: x[1], reverse=True)
abstract_top = [ (i, sents[i]) for i,score in abstract_scores[:5] if score>=2 ]

total_chars = len(text)
def ratio(count):
  return (count / max(1,total_chars)) * 1000

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("📊 오프라인 텍스트 자연스러움 점검 보고서")
print(f"파일: {os.path.basename(path)}  글자 수: {total_chars}")
print("")
print("접속사 밀도 (천 글자당 출현 횟수)")
total_conn = sum(connectors.values())
print(f"  합계: {total_conn}  | 비율: {ratio(total_conn):.2f}")
for k,v in sorted(connectors.items(), key=lambda x: -x[1])[:10]:
  if v>0: print(f"  - {k}: {v}")

print("")
print("빈말/상투어 카운트")
total_emp = sum(empties.values())
print(f"  합계: {total_emp}  | 비율: {ratio(total_emp):.2f}")
for k,v in sorted(empties.items(), key=lambda x: -x[1])[:10]:
  if v>0: print(f"  - {k}: {v}")

print("")
print("문장 길이 통계")
print(f"  문장 수: {len(lens)}  | 평균: {avg:.1f}  | 표준편차: {std:.1f}")
print(f"  연속 단문 최대: {mx_run_short} (임계값 {cfg['sentence_length']['max_run_short']})")
print(f"  연속 장문 최대: {mx_run_long} (임계값 {cfg['sentence_length']['max_run_long']})")

print("")
print("추상어 과부하 (예시 문장, 추상어 2개 이상)")
if abstract_top:
  for idx, s in abstract_top:
    snippet = s[:80] + ("…" if len(s)>80 else "")
    print(f"  - 제{idx+1}문장: {snippet}")
else:
  print("  뚜렷한 추상어 과부하 문장 없음")

print("")
print("제안")
print("  - 빈말과 추상 명사를 구체적 동작/사물/냄새로 대체")
print("  - 긴 문장을 끊고; 과도한 단문을 합쳐 리듬 변화 만들기")
print("  - 접속사를 삭제하거나 자연스러운 전환으로 바꿀 수 있는지 재검토")
print("  - 쓰기 전에 3개의 생활 디테일을 앵커로 나열")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
PY
