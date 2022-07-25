---
hide:
  - toc
---
# GRAV
Defines acceleration vector for gravity or other acceleration loading.

## Format
| 1        | 2        | 3        | 4        | 5        | 6        | 7        | 8        | 9        | 10       | 
| -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | 
| GRAV     | SID      | CID      | A        | N1       | N2       | N3       | _MB_     |          |

## Fields
| Field      | Contents |
| ---------- | -------- |
| SID | Load set identification number. (Integer > 0) |
| G | Grid point identification number. (Integer > 0) |
| CID | Coordinate system identification number. (Integer ≥ 0; Default = 0)  |
| A | Acceleration vector scale factor.  (Real)  |
| Ni | Acceleration vector components measured in coordinate system CID. (Real; at least one Ni ≠ 0.0.)  |
| _MB_ | Not used.  |
