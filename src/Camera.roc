interface Camera
    exposes [
        render,
        init
    ]
    imports [Ray.{ Ray }, HittableList.{ HittableList }, Color.{ Color }, Vec3.{ Vec3 }, Output.{ ppm }]

Camera := {
    aspectRatio: F32, 
    imageWidth: U32,

    imageHeight: U32,

    center: Vec3,
    pixel00Loc: Vec3,

    pixelDeltaU: Vec3,
    pixelDeltaV: Vec3,
}


init: { aspectRatio: F32, imageWidth: U32 } -> Camera
init = \{ aspectRatio, imageWidth } ->
    imageHeight =
        Num.floor ((Num.toF32 imageWidth) / aspectRatio)
        |> Num.max 1

    focalLength = 1.0
    viewportHeight = 2.0
    viewportWidth = viewportHeight * ((Num.toF32 imageWidth) / (Num.toF32 imageHeight))
    center = Vec3.zero

    viewportU = Vec3.new viewportWidth 0.0 0.0
    viewportV = Vec3.new 0.0 -viewportHeight 0.0

    pixelDeltaU = Vec3.div viewportU (Num.toF32 imageWidth)
    pixelDeltaV = Vec3.div viewportV (Num.toF32 imageHeight)

    viewportUpperLeft =
        center
        |> Vec3.sub (Vec3.new 0.0 0.0 focalLength)
        |> Vec3.sub (Vec3.div viewportU 2.0)
        |> Vec3.sub (Vec3.div viewportV 2.0)

    pixel00Loc = Vec3.add viewportUpperLeft (Vec3.add pixelDeltaU pixelDeltaV |> Vec3.scale 0.5)

    @Camera { aspectRatio, imageHeight, imageWidth, center, pixel00Loc, pixelDeltaU, pixelDeltaV }
    

render: Camera, HittableList -> List U8
render = \@Camera { imageHeight, imageWidth, pixel00Loc, pixelDeltaU, pixelDeltaV, center }, world -> 
    pixels = List.range { start: At 0, end: Before imageHeight }
        |> List.joinMap \h ->
            List.range { start: At 0, end: Before imageWidth }
            |> List.map \w ->
                pixelCenter =
                    pixel00Loc
                    |> Vec3.add (Vec3.scale pixelDeltaU (Num.toF32 w))
                    |> Vec3.add (Vec3.scale pixelDeltaV (Num.toF32 h))
                rayDirection = Vec3.sub pixelCenter center

                rayColor { origin: center, direction: rayDirection } world
    
    ppm imageWidth imageHeight pixels

rayColor : Ray, HittableList -> Color
rayColor = \r, list ->
    when HittableList.hit list r { min: 0.0, max: Num.maxF32 } is
        Hit rec ->
            Vec3.add rec.normal Vec3.one |> Vec3.scale 0.5 |> Color.fromVec3

        Miss ->
            dir = Vec3.unit r.direction
            a = 0.5 * ((Vec3.getY dir) + 1.0)

            Vec3.scale Vec3.one (1.0 - a) |> Vec3.add (Vec3.scale (Vec3.new 0.5 0.7 1.0) a) |> Color.fromVec3