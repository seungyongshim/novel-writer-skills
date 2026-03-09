#!/bin/bash

echo "🚀 추적 시스템 초기화 중..."

# 선행 조건 확인
story_exists=false
outline_exists=false

# specification 파일 찾기
if ls stories/*/specification.md 1> /dev/null 2>&1; then
    story_exists=true
    story_file=$(ls stories/*/specification.md | head -1)
fi

# outline 파일 찾기
if ls stories/*/outline.md 1> /dev/null 2>&1; then
    outline_exists=true
    outline_file=$(ls stories/*/outline.md | head -1)
fi

if [ "$story_exists" = false ] || [ "$outline_exists" = false ]; then
    echo "❌ 먼저 /specify와 /plan 명령을 완료하세요"
    echo "   누락: ${story_exists:+}${story_exists:-specification.md} ${outline_exists:+}${outline_exists:-outline.md}"
    exit 1
fi

# 추적 디렉토리 생성
mkdir -p spec/tracking

# 스토리 이름 가져오기
story_dir=$(dirname "$story_file")
story_name=$(basename "$story_dir")

echo "📖 《${story_name}》 추적 시스템 초기화 중..."

# plot-tracker.json 초기화
if [ ! -f "spec/tracking/plot-tracker.json" ]; then
    echo "📝 plot-tracker.json 생성 중..."
    cat > spec/tracking/plot-tracker.json <<EOF
{
  "novel": "${story_name}",
  "lastUpdated": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "currentState": {
    "chapter": 0,
    "volume": 1,
    "mainPlotStage": "준비 단계",
    "location": "미정",
    "timepoint": "이야기 시작 전"
  },
  "plotlines": {
    "main": {
      "name": "메인 플롯",
      "description": "개요에서 추출 예정",
      "status": "시작 전",
      "currentNode": "시작점",
      "completedNodes": [],
      "upcomingNodes": [],
      "plannedClimax": {
        "chapter": null,
        "description": "계획 예정"
      }
    },
    "subplots": []
  },
  "foreshadowing": [],
  "conflicts": {
    "active": [],
    "resolved": [],
    "upcoming": []
  },
  "checkpoints": {
    "volumeEnd": [],
    "majorEvents": []
  },
  "notes": {
    "plotHoles": [],
    "inconsistencies": [],
    "reminders": ["실제 이야기 내용에 따라 추적 데이터를 업데이트하세요"]
  }
}
EOF
fi

# timeline.json 초기화
if [ ! -f "spec/tracking/timeline.json" ]; then
    echo "⏰ timeline.json 생성 중..."
    cat > spec/tracking/timeline.json <<EOF
{
  "novel": "${story_name}",
  "lastUpdated": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "storyTimeUnit": "일",
  "realWorldReference": null,
  "timeline": [
    {
      "chapter": 0,
      "storyTime": "0일차",
      "description": "이야기 시작 전",
      "events": ["추가 예정"],
      "location": "미정"
    }
  ],
  "parallelEvents": [],
  "timeSpan": {
    "start": "0일차",
    "current": "0일차",
    "elapsed": "0일"
  }
}
EOF
fi

# relationships.json 초기화
if [ ! -f "spec/tracking/relationships.json" ]; then
    echo "👥 relationships.json 생성 중..."
    cat > spec/tracking/relationships.json <<EOF
{
  "novel": "${story_name}",
  "lastUpdated": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "characters": {
    "주인공": {
      "name": "설정 예정",
      "relationships": {
        "allies": [],
        "enemies": [],
        "romantic": [],
        "neutral": []
      }
    }
  },
  "factions": {},
  "relationshipChanges": [],
  "currentTensions": []
}
EOF
fi

# character-state.json 초기화
if [ ! -f "spec/tracking/character-state.json" ]; then
    echo "📍 character-state.json 생성 중..."
    cat > spec/tracking/character-state.json <<EOF
{
  "novel": "${story_name}",
  "lastUpdated": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "characters": {
    "주인공": {
      "name": "설정 예정",
      "status": "건강",
      "location": "미정",
      "possessions": [],
      "skills": [],
      "lastSeen": {
        "chapter": 0,
        "description": "아직 미등장"
      },
      "development": {
        "physical": 0,
        "mental": 0,
        "emotional": 0,
        "power": 0
      }
    }
  },
  "groupPositions": {},
  "importantItems": {}
}
EOF
fi

echo ""
echo "✅ 추적 시스템 초기화 완료!"
echo ""
echo "📊 다음 추적 파일이 생성되었습니다:"
echo "   • spec/tracking/plot-tracker.json - 플롯 추적"
echo "   • spec/tracking/timeline.json - 타임라인 관리"
echo "   • spec/tracking/relationships.json - 관계 네트워크"
echo "   • spec/tracking/character-state.json - 캐릭터 상태"
echo ""
echo "💡 다음 단계:"
echo "   1. /write를 사용하여 창작 시작 (추적 데이터가 자동 업데이트)"
echo "   2. 정기적으로 /track을 사용하여 종합 보고서 확인"
echo "   3. /plot-check 등 명령으로 일관성 검사"
echo ""
echo "📝 팁: 추적 파일에 기본 구조가 미리 채워져 있으며, 집필 과정에서 자동 업데이트됩니다"
