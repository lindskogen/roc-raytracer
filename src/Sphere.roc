interface Sphere 
    exposes [
        Sphere,
        hit
    ]
    imports [Ray.{ Ray }, Vec3.{ Vec3 }, HitRecord.{ HitTest }]


Sphere: { center: Vec3, radius: F32 }

hit: HitTest Sphere
hit = \{ center, radius }, r, tmin, tmax ->
    oc = Vec3.sub r.origin center
    a = Vec3.lenSquared r.direction
    halfB = Vec3.dotProduct oc r.direction
    c = (Vec3.lenSquared oc) - (radius * radius)
    discriminant = halfB * halfB - a * c

    rootIsInsideRange = \rt ->
        rt >= tmin && rt <= tmax

    findRootInRange = \{} ->
        sqrtd = Num.sqrt discriminant
        r1 = (-halfB - sqrtd) / a
        r2 = (-halfB + sqrtd) / a

        if rootIsInsideRange r1 then
            Root r1
        else if rootIsInsideRange r2 then
            Root r2
        else 
            NoRootWithinRange
        
            

    if discriminant < 0 then
        Miss
    else 
        when findRootInRange {} is
            NoRootWithinRange -> Miss
            Root t ->
                p = Ray.at r t
                outwardNormal = Vec3.sub p center |> Vec3.div radius
                Hit (HitRecord.new { t, p, outwardNormal, rayDirection: r.direction })