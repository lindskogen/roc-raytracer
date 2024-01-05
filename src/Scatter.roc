interface Scatter
    exposes [scatter]
    imports [Material.{ Material }, Ray.{ Ray }, HitRecord.{ HitRecord }, Vec3.{ Vec3 }, Rnd]

scatter : Material, Ray, HitRecord, Rnd.State -> ([Absorbed, Scattered { scattered : Ray, attenuation : Vec3 }], Rnd.State)
scatter = \mat, ray, rec, seed ->
    when mat is
        Lambertian { albedo } ->
            { value, state } = Vec3.randomUnit seed
            dir = Vec3.add rec.normal value

            direction = if Vec3.nearZero dir then rec.normal else dir

            scattered = { origin: rec.p, direction }

            (Scattered { attenuation: albedo, scattered }, state)

        Metal { albedo, fuzz } ->
            reflected = Vec3.reflect (Vec3.unit ray.direction) rec.normal
            { value: randomUnitVector, state } = Vec3.randomUnit seed
            scattered = { origin: rec.p, direction: Vec3.scale randomUnitVector fuzz |> Vec3.add reflected }

            if Vec3.dotProduct scattered.direction rec.normal > 0 then
                (Scattered { attenuation: albedo, scattered }, state)
            else
                (Absorbed, state)
