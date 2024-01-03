interface Ray
    exposes [
        Ray,
        at
    ]
    imports [Vec3.{ Vec3 }]


Ray: { origin: Vec3, direction: Vec3 }


at: Ray, F32 -> Vec3
at = \r, t ->
    Vec3.add r.origin (Vec3.scale r.direction t)