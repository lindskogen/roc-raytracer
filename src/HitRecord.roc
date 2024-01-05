interface HitRecord
    exposes [
        HitRecord,
        HitTest,
        new,
    ]
    imports [Vec3.{ Vec3 }, Range.{ Range }, Ray.{ Ray }, Material.{ Material }]

HitTest a : a, Ray, Range -> [Hit HitRecord, Miss]

HitRecord : { p : Vec3, normal : Vec3, t : F32, facing : [Front, Back], mat : Material }

new : { p : Vec3, outwardNormal : Vec3, t : F32, rayDirection : Vec3, mat : Material } -> HitRecord
new = \{ p, outwardNormal, t, rayDirection, mat } ->

    facing = if (Vec3.dotProduct rayDirection outwardNormal) < 0 then Front else Back
    normal = if facing == Front then outwardNormal else Vec3.neg outwardNormal

    { p, t, normal, facing, mat }

