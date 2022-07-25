---
hide:
  - toc
---
# CMASS1
Defines a scalar mass element.

## Format
| 1        | 2        | 3        | 4        | 5        | 6        | 7        | 8        | 9        | 10       | 
| -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | 
| CMASS1   | EID      | PID      | G1       | C1       | G2       | C2       |          |          |          |

## Fields
| Field      | Contents |
| ---------- | -------- |
| EID | Unique element identification number. (0 < Integer)
| PID | Property identification number of a PMASS entry. (Integer > 0)
| G1  | Geometric grid or scalar point identification number. (Integer > 0)
| C1  | Component number. (1 ≤ Integer ≤ 6)
| G2  | Must be blank.
| C2  | Not used.
