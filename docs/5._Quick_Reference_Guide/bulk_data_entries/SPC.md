---
hide:
  - toc
---
# SPC
Defines a set of single-point constraints.

## Format
| 1        | 2        | 3        | 4        | 5        | 6        | 7        | 8        | 9        | 10       | 
| -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | 
| SPC | SID | G1 | C1 | D1 | G2 | C2 | D2


## Fields
| Field      | Contents |
| ---------- | -------- |
| SID | Constraint set identification number. (Integer > 0)
| Gi | Grid or scalar point identification number. (Integer > 0)
| Ci | Component number. (0 ≤ Integer ≤ 6; up to six Unique Integers, 1 through 6, may be placed in the field with no embedded blanks. 0 applies to scalar points and 1 through 6 applies to grid points.)
| Di | Value of enforced motion for all degrees-of-freedom designated by Gi and Ci. **Must be 0.0. See Remark 1.**

## Remarks
1. Use the SPCD entry to specify nonzero enforced displacement values.
