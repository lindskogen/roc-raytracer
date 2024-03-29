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

        Dielectric { refractionIndex } ->
            refractionRatio =
                when rec.facing is
                    Front -> 1.0 / refractionIndex
                    Back -> refractionIndex

            unitDirection = Vec3.unit ray.direction

            cosTheta = Num.min 1.0 (Vec3.dotProduct (Vec3.neg unitDirection) rec.normal)
            sinTheta = Num.sqrt (1.0 - cosTheta*cosTheta)

            cannotRefract = refractionRatio * sinTheta > 1.0

            { state, value: randomNum } = Rnd.float seed

            direction = if cannotRefract || (reflectance cosTheta refractionRatio) > randomNum then
                    Vec3.reflect unitDirection rec.normal
                else 
                    Vec3.refract unitDirection rec.normal refractionRatio

            scattered = { origin: rec.p, direction }

            (Scattered { attenuation: Vec3.one, scattered }, state)


reflectance: F32, F32 -> F32
reflectance = \cosine, refractionRatio ->
    r0 = (1.0 - refractionRatio) / (1.0 + refractionRatio)
    r00 = r0 * r0
    r00 + (1.0 - r00) * Num.pow (1.0 - cosine) 5