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

    r = Vec3.getX v |> colorCorrect scale
    g = Vec3.getY v |> colorCorrect scale
    b = Vec3.getZ v |> colorCorrect scale

    { r, g, b }

colorCorrect : F32, F32 -> U8
colorCorrect = \v, scale ->
    v * scale |> linearToGamma |> Range.clamp Range.unit |> scaleToColor

linearToGamma : F32 -> F32
linearToGamma = \x ->
    Num.sqrt x
