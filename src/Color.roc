interface Color
    exposes [Color, fromVec3, red, green, blue]
    imports [Vec3.{ Vec3 }, Range]

Color : { r : U8, g : U8, b : U8 }

scaleToColor = \f ->
    f * 255.999 |> Num.floor

red : Color
red = { r: 255, g: 0, b: 0 }

green : Color
green = { r: 0, g: 255, b: 0 }

blue : Color
blue = { r: 0, g: 0, b: 255 }

fromVec3 : Vec3, U32 -> Color
fromVec3 = \v, samplesPerPixel ->
    scale = 1.0 / (Num.toF32 samplesPerPixel)

    {
        r: (Vec3.getX v * scale) |> Range.clamp Range.unit |> scaleToColor,
        g: (Vec3.getY v * scale) |> Range.clamp Range.unit |> scaleToColor,
        b: (Vec3.getZ v * scale) |> Range.clamp Range.unit |> scaleToColor,
    }
