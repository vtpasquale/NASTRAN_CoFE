---
hide:
  - toc
---
Defines an isoparametric membrane-bending-shear quadrilateral plate element.

## Format
| 1        | 2        | 3        | 4        | 5        | 6        | 7        | 8        | 9        | 10       | 
| -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | 
| CQUAD4   | EID      | PID      | G1       | G2       | G3       | G4       |_THETA or MCID_| _ZOFFS_ |        | 
|          | TFLAG    | T1       | T2       | T3       | T4       |          |          |           |         |



## Fields
| Field      | Contents |
| ---------- | -------- |
| EID | Element identification number. (Integer > 0)
| PID | Property identification number of a PSHELL entry. (Integer > 0; Default = EID)
| Gi | Grid point identification numbers of connection points. (Integers > 0, all unique.)
| _THETA or MCID_ | Not used.
| _ZOFFS_ | Not used.
| TFLAG | An integer flag, signifying the meaning of the Ti values. (Integer 0, 1, or blank)
| Ti | Membrane thickness of element at grid points G1 through G4. If "TFLAG" is zero or blank, then Ti are actual user specified thicknesses. See Remark 3. for default. (Real > 0.0 or blank, not all zero.) If "TFLAG" is one, then the Ti are fractions relative to the T value of the PSHELL. (Real > 0.0 or blank, not all zero.)

## Remarks
1. Grid points G1 through G4 must be ordered consecutively around the perimeter of the element.
2. All interior angles must be less than 180 degrees.
3. The continuation is optional. If it is not supplied, then T1 through T4 will be set equal to the value of T on the PSHELL entry.