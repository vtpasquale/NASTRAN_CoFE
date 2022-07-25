---
hide:
  - toc
---
# LOAD
Defines a static load as a linear combination of load sets.

## Format
| 1        | 2        | 3        | 4        | 5        | 6        | 7        | 8        | 9        | 10       | 
| -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | 
| LOAD | SID | S | S1 | L1 | S2 | L2 | S3 | L3 |  
|  | S4 | L4 | S5 | L5 | -etc.- |   |   |   |  


## Fields
| Field      | Contents |
| ---------- | -------- |
| SID | Load set identification number. (Integer > 0) |
| S | Overall scale factor. (Real) |
| Si | Scale factor on Li. (Real) |
| Li | Referenced load set identification numbers. (Integer > 0) |

## REMARKS:
1. Load set IDs (Li) must be unique.
2. A LOAD entry may not reference a set identification number defined by another LOAD entry.
