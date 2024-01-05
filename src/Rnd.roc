interface Rnd
    exposes [
        initialize,
        float,
        State,
        floatInRange,
    ]
    imports [pf.Utc, pf.Task.{ Task }, rand.Random]

State : Random.State U32

initialize : {} -> Task State *
initialize = \{} ->
    time <- Utc.now |> Task.await

    Random.seed (Num.toU32 (Utc.toMillisSinceEpoch time))
    |> Task.ok

float : State -> { value : F32, state : State }
float = \seed ->
    { value, state } = (Random.u32 0 1000) seed

    { value: (Num.toF32 value) / 1000.0f32, state }

floatInRange : State, F32, F32 -> { value : F32, state : State }
floatInRange = \seed, min, max ->
    { value, state } = float seed

    { value: min + (max - min) * value, state }

