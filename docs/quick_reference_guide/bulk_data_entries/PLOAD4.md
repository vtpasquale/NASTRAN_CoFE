---
hide:
  - toc
---
Defines a pressure load on a CTRIA3 or CQUAD4 element face.

## Format
| 1        | 2        | 3        | 4        | 5        | 6        | 7        | 8        | 9          | 10       | 
| -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | --------   | -------- | 
| PLOAD4   | SID      | EID      | P1       | P2       | P3       | P4       | _G1_     | _G3 or G4_ |          | 


## Fields
| Field      | Contents |
| ---------- | -------- |
| SID   | Load set identification number. (Integer > 0)
| EID   | Element identification number. (Integer > 0)
| P1, P2, P3, P4 | Pressure at the corners of the face of the element. (Real or blank; Default for P2, P3, and P4 is P1.)
| _G1_  | Not used.
| _G3 or G4_  | Not used.