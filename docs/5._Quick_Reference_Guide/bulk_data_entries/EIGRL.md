---
hide:
  - toc
---
# EIGRL
Defines data needed to perform real eigenvalue (vibration or buckling) analysis.

## Format
| 1        | 2        | 3        | 4        | 5        | 6        | 7        | 8        | 9        | 10       | 
| -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | 
| EIGRL    | SID      | _V1_     | _V2_     | ND       | _MSGLVL_ | _MAXSET_ | _SHFSCL_ | _NORM_   |          |

## Fields
| Field    | Contents |
| -------- | -------- |
| SID | Set identification number. (Unique Integer > 0) |
| _V1, V2_ | Not used. |
| ND | Number of roots desired. (Integer > 0) |
| _MSGLVL_ | Not used. |
| _MAXSET_ | Not used. |
| _SHFSCL_ | Not used. |
| _NORM_   | Not used. |

## Remark
1. CoFE always mass normalizes vibration eigenvectors.
