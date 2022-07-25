---
hide:
  - toc
---
# SET
Defines a list of integers.

## Format
`SET n =  {i1, i2 , [i3 THRU i4], i5}`

## Examples
`SET 55=6`

```
SET 11 = 100 THRU 200,202,304 THRU 404,506 THRU 606,708 THRU 808,
910 THRU 1110,1112,1114 THRU 2000, 2116
```

## Describers
| Describer  | Meaning  |
| ---------- | -------- |
| n          | Set identification number. |
| iN         | Numbers in set.            |
| THRU       | All numbers between adjacent values included in set.    |

Remarks
1. A SET entry may be more than one line. A comma at the end of the line signifies a continuation. Commas may not end a set. THRU may not be used for continuation.
