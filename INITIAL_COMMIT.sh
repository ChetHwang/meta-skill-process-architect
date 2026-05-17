#!/usr/bin/env bash
# CLEAN RELEASE v1.2.4 — 深度脱敏 + 远端 tag 清理
#
# 本脚本会：
# 1. 自检通过后，删 .git 重 init（清空 v1.1.1/v1.2.2/v1.2.3 历史）
# 2. 单 commit + tag v1.2.4
# 3. **自动删除远端旧 tag**（v1.1.1 / v1.2.2 / v1.2.3）
# 4. force push 新 main + 新 tag

set -e
cd "$(dirname "$0")"

echo "=== Step 1: meta-self-check 验证 v1.2.4 一致性 ==="
python3 cli/meta-skill-process-architect.py meta-self-check || {
  echo "❌ meta-self-check failed."
  exit 1
}

echo ""
echo "⚠️  即将 DESTRUCTIVELY 清空本地 git 历史并重建。"
echo "    会丢失：所有旧 commit 与 tag（v1.1.1/v1.2.2/v1.2.3）的本地历史"
echo "    保留：当前 working dir（v1.2.4 全量脱敏版）"
echo ""
read -p "确认执行？输入 'yes' 继续: " confirm
if [ "$confirm" != "yes" ]; then
  echo "已取消。"
  exit 0
fi

# 记下远端 URL（如果已设置过）
REMOTE_URL=$(git remote get-url origin 2>/dev/null || true)

# 删旧 .git 重 init
echo ""
echo "=== Step 2: 删除旧 git 历史 + 重新 init ==="
rm -rf .git
git init
git config user.email "hy12315@gmail.com"
git config user.name "Chet"

git add -A

git commit -m "release: v1.2.4 — Phase 1-4 + production hardening + G10/G11/G12 automation + full sanitization

Phase 1-4 implementation:
- L0-L6 framework, 14 recipes, 4 input modes, lifecycle ops
- 7-role audience model, 10 anti-patterns, Gap Handling Policy
- Cross-process network, Trace Mode, multi-platform agents (5)
- bilingual EN+ZH templates (30 templates)

Production hardening:
- 6 cross-cutting capabilities: C1 Extract / C2 Detect Gaps / C3 Cross-Process / C4 Long-Lived / C5 Cycle Time / C6 Internal Handoff
- Execution Budget, Step 0.5/5.5/6.5/8/8.5 hooks
- Universal Escape Hatch, Retry & Timeout Contract

Self-validation automation (G10/G11/G12):
- CLI meta-self-check: 5-file version + examples sync + archetype requirements
- Pre-commit gate enforced via this script

Sanitization (v1.2.3 → v1.2.4):
- All examples are fictional/anonymized
- Design docs, templates, CHANGELOG, test prompts use generic terms
- Original real-world content kept in ../_private-examples/ (not in git)
"

git tag -a v1.2.4 -m "v1.2.4 — fully sanitized public release"

# 如果之前有 origin，自动加回
if [ -n "$REMOTE_URL" ]; then
  git remote add origin "$REMOTE_URL"
  echo "✓ origin 已恢复: $REMOTE_URL"
fi

echo ""
echo "=== Step 3: 删除远端旧 tag（如果存在 origin）==="
if [ -n "$REMOTE_URL" ]; then
  echo "尝试删除远端 v1.1.1 / v1.2.2 / v1.2.3 tag..."
  git push origin :refs/tags/v1.1.1 2>/dev/null || echo "  (v1.1.1 不存在或已删)"
  git push origin :refs/tags/v1.2.2 2>/dev/null || echo "  (v1.2.2 不存在或已删)"
  git push origin :refs/tags/v1.2.3 2>/dev/null || echo "  (v1.2.3 不存在或已删)"
else
  echo "(尚未配置 origin，跳过；推送后需要手工删除远端旧 tag)"
fi

echo ""
echo "=== Step 4: force push main + 新 tag v1.2.4 ==="
if [ -n "$REMOTE_URL" ]; then
  git push -u origin main --force
  git push origin v1.2.4
  echo ""
  echo "✓ 推送完成。GitHub 现在只有 v1.2.4 一个 tag + 1 个 clean commit。"
else
  echo "尚未配置 origin。手动跑："
  echo "  git remote add origin https://github.com/ChetHwang/meta-skill-process-architect.git"
  echo "  git push -u origin main --tags --force"
  echo "  git push origin :refs/tags/v1.1.1 :refs/tags/v1.2.2 :refs/tags/v1.2.3"
fi

echo ""
echo "=== Step 5: 验证 ==="
echo "在 /tmp 跑："
echo "  cd /tmp && rm -rf check && git clone https://github.com/ChetHwang/meta-skill-process-architect.git check && cd check"
echo "  grep -rE '<your-internal-terms>' . 2>/dev/null  # 期待无输出"
echo "  git tag  # 期待只有 v1.2.4"
echo ""
echo "✓ 完成后删本脚本：rm INITIAL_COMMIT.sh"
