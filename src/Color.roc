interface Color
    exposes [Color, fromVec3]
    imports [Vec3.{ Vec3 }]

Color : { r : U8, g : U8, b : U8 }


scaleToColor = \f ->
    f * 255.999 |> Num.floor


fromVec3: Vec3 -> Color
fromVec3 = \v ->
    { 
        r: Vec3.getX v |> scaleToColor, 
        g: Vec3.getY v |> scaleToColor, 
        b: Vec3.getZ v |> scaleToColor 
    }