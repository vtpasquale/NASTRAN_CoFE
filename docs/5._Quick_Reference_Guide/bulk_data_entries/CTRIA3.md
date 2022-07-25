---
hide:
  - toc
---
# CTRIA3
Defines an isoparametric membrane-bending-shear triangular plate element.

## Format
| 1        | 2        | 3        | 4        | 5        | 6        | 7        | 8        | 9        | 10       | 
| -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | 
| CTRIA3   | EID      | PID      | G1       | G2       | G3       | G4       | THETA or MCID | ZOFFS |        | 
|          | TFLAG    | T1       | T2       | T3       |          |          |          |           |         |

## Fields
| Field      | Contents |
| ---------- | -------- |
| EID | Element identification number. (Integer > 0)
| PID | Property identification number of a PSHELL entry. (Integer > 0; Default = EID)
| Gi | Grid point identification numbers of connection points. (Integers > 0, all unique.)
| THETA or MCID | Not used.
| ZOFFS | Not used.
| TFLAG | An integer flag, signifying the meaning of the Ti values. (Integer 0, 1, or blank)
| Ti | Membrane thickness of element at grid points G1 through G3. If "TFLAG" is zero or blank, then Ti are actual user specified thicknesses. See Remark 3. for default. (Real > 0.0 or blank, not all zero.) If "TFLAG" is one, then the Ti are fractions relative to the T value of the PSHELL. (Real > 0.0 or blank, not all zero.)

## Remark
1. The continuation is optional. If it is not supplied, then T1 through T4 will be set equal to the value of T on the PSHELL entry.
