interface Range
    exposes [
        Range,
        empty,
        universe,
        contains,
        surrounds,
        clamp,
        unit,
    ]
    imports []

Range : { min : F32, max : F32 }

contains : Range, F32 -> Bool
contains = \{ min, max }, x ->
    min <= x && x <= max

surrounds : Range, F32 -> Bool
surrounds = \{ min, max }, x ->
    min < x && x < max

clamp : F32, Range -> F32
clamp = \x, { min, max } ->
    if x < min then
        min
    else if x > max then
        max
    else
        x

unit : Range
unit = { min: 0.0, max: 1.0 }

empty : Range
empty = { min: Num.maxF32, max: Num.minF32 }

universe : Range
universe = { min: Num.minF32, max: Num.maxF32 }
