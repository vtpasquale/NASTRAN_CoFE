---
hide:
  - toc
---
# MOMENT
Defines a static moment vector at a grid point.

## Format
| 1        | 2        | 3        | 4        | 5        | 6        | 7        | 8        | 9        | 10       | 
| -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | 
| MOMENT   | SID      | G        | CID      | M        | N1       | N2       | N3       |          |          |

## Fields
| Field      | Contents |
| ---------- | -------- |
| SID | Load set identification number. (Integer > 0) |
| G   | Grid point identification number. (Integer > 0) |
| CID | Coordinate system identification number. (Integer ≥ 0; Default = 0)  |
| M   | Scale factor. (Real)  |
| Ni  | Components of the vector measured in coordinate system defined by CID. (Real; at least one Ni ≠ 0.0.)  |
