---
hide:
  - toc
---
# CORD2C
Defines a cylindrical coordinate system using the coordinates of three points.

## Format
| 1        | 2        | 3        | 4        | 5        | 6        | 7        | 8        | 9        | 10       | 
| -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | 
| CORD2C   | CID      | RID      | A1       | A2       | A3       | B1       | B2       | B3       |          |
|          | C1       | C2       | C3       |          |          |          |          |          |          |

## Fields
| Field      | Contents |
| ---------- | -------- |
| CID        | Coordinate system identification number. (Integer > 0) |
| RID        | Identification number of a coordinate system that is defined independently from this coordinate system. (Integer ≥ 0; Default = 0 is the basic coordinate system.) |
| Ai, Bi, Ci | Coordinates of three points in coordinate system defined in field 3. (Real) |

## Definition
![cord2c](https://raw.githubusercontent.com/vtpasquale/web_assets/assets/img/cord2c.svg)
