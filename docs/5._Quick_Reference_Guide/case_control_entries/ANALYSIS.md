---
hide:
  - toc
---
Specifies the type of analysis being performed for the current subcase.

## Format
`ANALYSIS=type`

## Examples
`ANALYSIS=STATICS`

`ANALYSIS=MODES`

## Describers
| Type       | Meaning  |
| ---------- | -------- |
| STATICS    | Statics      |
| MODES      | Normal Modes |

## Remarks
1. CoFE can switch analysis types between subcases regardless of the solution sequence For example, there can be an `ANALYSIS=MODES` subcase even if the solution sequence is set to `SOL 101` in the executive control. 
2. The default analysis type is set by the `SOL` executive control entry. The default for `SOL 101` is `ANALYSIS=STATICS` and the default for `SOL 103` is `ANALYSIS=MODES`.