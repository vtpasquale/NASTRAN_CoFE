---
hide:
  - toc
---
# CROD
Defines a tension-compression-torsion element.

## Format
| 1        | 2        | 3        | 4        | 5        | 6        | 7        | 8        | 9        | 10       | 
| -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | 
| CROD     | EID      | PID      | G1       | G2       |          |          |          |          |          | 

## Fields
| Field      | Contents |
| ---------- | -------- |
| EID | Element identification number. ( Integer > 0)
| PID | Property identification number of a PROD entry. (Integer > 0)
| G1, G2 | Grid point identification numbers of connection points. (Integer > 0; G1 ≠ G2 )

## Remark
1. Element identification numbers should be unique with respect to all other element identification numbers.
