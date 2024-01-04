interface Range
    exposes [
        Range,
        empty,
        universe,
        contains,
        surrounds
    ]
    imports []


Range: { min: F32, max: F32 }

contains: Range, F32 -> Bool
contains = \{ min, max }, x ->
    min <= x && x <= max

surrounds: Range, F32 -> Bool
surrounds = \{ min, max }, x ->
    min < x && x < max

empty: Range
empty = { min: Num.maxF32, max: Num.minF32 }

universe: Range
universe = { min: Num.minF32, max: Num.maxF32 }