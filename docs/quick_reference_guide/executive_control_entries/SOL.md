---
hide:
  - toc
---
Specifies the solution sequence. 

## Format
`SOL {n,name}`

## Describers
| Describer | Meaning   |  
| --------- | --------- | 
| n         | Solution number. (Integer > 0) | 
| name      | Solution name. (Char) | 

## Solution Types
| Solution Type   | n         | name(s)   | 
| --------------- | --------- | --------- |
| Linear statics  | 101       | STATICS, SESTATIC, SESTATICS |
| Normal Modes    | 103       | MODES, SEMODES               |

## Examples
`SOL 101`

`SOL SESTATICS`