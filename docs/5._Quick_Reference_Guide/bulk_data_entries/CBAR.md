---
hide:
  - toc
---
# CBAR
Defines a simple beam element.

## Format
| 1        | 2        | 3        | 4        | 5        | 6        | 7        | 8        | 9        | 10       | 
| -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | 
| CBAR | EID | PID | GA | GB | X1 | X2 | X3 | _OFFT_ |



## Fields
| Field      | Contents |
| ---------- | -------- |
| EID        | Unique element identification number. (0 < Integer)    |
| PID        | Property identification number of PBAR or PBARL entry. (Integer > 0; Default=EID)    |
| GA, GB     | Grid point identification numbers of connection points. (Integer > 0)    | 
| X1, X2, X3 | Components of orientation vector from GA in the nodal displacement reference frame at GA. (Real)    |
| _OFFT_     | Not used. |

## Remarks
1. Element identification numbers should be unique with respect to all other element identification numbers.
2. Continuation lines are not supported.
3. Offsets are not supported.
