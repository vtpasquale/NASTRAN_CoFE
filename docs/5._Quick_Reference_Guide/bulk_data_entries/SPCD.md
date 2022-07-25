Defines an enforced displacement value.

## Format
| 1        | 2        | 3        | 4        | 5        | 6        | 7        | 8        | 9        | 10       | 
| -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | 
| SPCD | SID | G1 | C1 | D1 | G2 | C2 | D2


## Fields
| Field      | Contents |
| ---------- | -------- |
| SID | Load set identification number. (Integer > 0)
| Gi | Grid or scalar point identification number. (Integer > 0)
| Ci | Component number. (0 ≤ Integer ≤ 6; up to six Unique Integers, 1 through 6, may be placed in the field with no embedded blanks. 0 applies to scalar points and 1 through 6 applies to grid points.)
| Di | Value of enforced motion for all degrees-of-freedom designated by Gi and Ci. (Real)

## Remarks
1. The set ID of the SPCD entry (SID) is selected by the LOAD Case Control command.
2. A global coordinate (Gi and CI) referenced on this entry must also be referenced on a SPC or SPC1 Bulk Data entry and selected by the SPC Case Control command.
3.  Values of Di will override the values specified on an SPC Bulk Data entry, if the SID is selected as indicated above.
4. The LOAD Bulk Data entry will not combine an SPCD load entry.
5. Rotational degrees of freedom are in radians.

