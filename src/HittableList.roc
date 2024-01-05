interface HittableList
    exposes [
        HittableList,
        hit,
    ]
    imports [HitRecord.{ HitTest }, Sphere.{ Sphere }]

HittableList : List Sphere

hit : HitTest HittableList
hit = \list, r, { min, max } ->
    List.walk list { closest: max, hit: Miss } \state, s ->
        when Sphere.hit s r { min, max: state.closest } is
            Miss -> state
            Hit rec ->
                { closest: rec.t, hit: Hit rec }
    |> .hit

