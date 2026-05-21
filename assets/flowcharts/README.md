# Flowchart Starters

Three Mermaid starter templates for generated process Skills. Copy + adapt as needed.

| File | When to use |
|---|---|
| `swimlane-starter.mmd` | Multi-role processes with handoffs between teams. Most common starting point. |
| `decision-tree-starter.mmd` | Nested decision points (L1.5). For 3+ variable decisions, prefer decision_table in process-brief.md instead. |
| `state-machine-starter.mmd` | Workflow state machines (L1.6) with multiple terminal states (success/failed/cancelled). |

## Usage

```bash
# In a generated process Skill, place flowcharts in:
process-{name}/assets/flowcharts/
```

Generated `references/visualization-spec.md` should reference these as `.mmd` source files. Render to SVG/PNG via the Mermaid CLI when publishing.

## Color Semantics (per plan §7.4)

- Red border / fill: exception path (`.E` suffix)
- Yellow fill: decision diamond
- White: standard step
- Dashed arrow: alternative or exception
- Solid arrow: default flow
