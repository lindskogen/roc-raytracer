interface HittableList
    exposes [
        HittableList,
        hit
    ]
    imports [HitRecord.{ HitTest }, Sphere.{ Sphere }]

HittableList: List Sphere

hit: HitTest HittableList
hit = \list, r, tmin, tmax ->
    List.walk list { closest: tmax, hit: Miss } \state, s ->
            when Sphere.hit s r tmin state.closest is
                Miss -> state
                Hit rec ->
                    { closest: rec.t, hit: Hit rec }
        |> .hit




