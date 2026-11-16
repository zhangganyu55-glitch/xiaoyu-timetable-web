#!/bin/bash
# 用 template.html + 一份课表 JSON（term + sessions）生成完全自包含的单文件版本。
# 用法：bash build-personal.sh [课表 JSON] [输出文件]
#   默认：data/my-schedule.json  →  dist/小雨课程表.html
set -euo pipefail
cd "$(dirname "$0")"

DATA="${1:-data/my-schedule.json}"
OUT="${2:-dist/小雨课程表.html}"
TEMPLATE="${TEMPLATE:-template.html}"

[ -f "$TEMPLATE" ] || { echo "✗ 找不到模板：$TEMPLATE"; exit 1; }
[ -f "$DATA" ] || { echo "✗ 找不到课表数据：$DATA"; exit 1; }
mkdir -p "$(dirname "$OUT")"

python3 - "$TEMPLATE" "$DATA" "$OUT" <<'PY'
import json, sys

template_path, data_path, out_path = sys.argv[1], sys.argv[2], sys.argv[3]
raw = open(data_path, encoding='utf-8').read()
json.loads(raw)                        # 先校验，别把坏 JSON 塞进去
html = open(template_path, encoding='utf-8').read()

marker = '/*__SEED__*/null'
if marker not in html:
    sys.exit(f'✗ {template_path} 里找不到注入点 /*__SEED__*/null')

html = html.replace(marker, '/*__SEED__*/' + raw)
open(out_path, 'w', encoding='utf-8').write(html)
print(f'✓ 生成 {out_path}（{len(json.loads(raw)["sessions"])} 条课）')
PY
