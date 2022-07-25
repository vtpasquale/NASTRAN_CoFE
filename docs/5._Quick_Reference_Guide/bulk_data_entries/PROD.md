---
hide:
  - toc
---
Defines the properties of a CROD element.

## Format
| 1        | 2        | 3        | 4        | 5        | 6        | 7        | 8        | 9        | 10       | 
| -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | 
| PROD     | PID      | MID      | A        | J        | C        | NSM      |          |          |          |

## Fields
| Field      | Contents |
| ---------- | -------- |
| PID    | Property identification number. (Integer > 0)
| MID    | Material identification number. (Integer > 0)
| A      | Area of the rod. (Real)
| J      | Torsional constant. (Real)
| C      | Coefficient to determine torsional stress. (Real; Default = 0.0)
| NSM    | Nonstructural mass per unit length. (Real; Default = 0.0)