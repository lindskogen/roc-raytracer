interface Color
    exposes [Color, fromVec3, red, green, blue]
    imports [Vec3.{ Vec3 }]

Color : { r : U8, g : U8, b : U8 }

scaleToColor = \f ->
    f * 255.999 |> Num.floor

red : Color
red = { r: 255, g: 0, b: 0 }

green : Color
green = { r: 0, g: 255, b: 0 }

blue : Color
blue = { r: 0, g: 0, b: 255 }

fromVec3 : Vec3 -> Color
fromVec3 = \v -> {
    r: Vec3.getX v |> scaleToColor,
    g: Vec3.getY v |> scaleToColor,
    b: Vec3.getZ v |> scaleToColor,
}
