interface HitRecord
    exposes [
        HitRecord,
        HitTest,
        new,
    ]
    imports [Vec3.{ Vec3 }, Range.{ Range }, Ray.{ Ray }]

HitTest a: a, Ray, Range -> [Hit HitRecord, Miss]

HitRecord : { p: Vec3, normal: Vec3, t: F32, facing: [Front, Back] }

new: {p: Vec3, outwardNormal: Vec3, t: F32, rayDirection: Vec3} -> HitRecord
new = \{p, outwardNormal, t, rayDirection} ->

    facing = if (Vec3.dotProduct rayDirection outwardNormal) < 0 then Front else Back
    normal = if facing == Front then outwardNormal else Vec3.neg outwardNormal

    { p, t, normal, facing }


