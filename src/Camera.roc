interface Camera
    exposes [
        render,
        init,
    ]
    imports [Ray.{ Ray }, HittableList.{ HittableList }, Color.{ Color }, Vec3.{ Vec3 }, Output.{ ppm }, Rnd]

InternalCamera : {
    aspectRatio : F32,
    imageWidth : U32,
    samplesPerPixel : U32,
    maxDepth : U32,
    imageHeight : U32,
    center : Vec3,
    pixel00Loc : Vec3,
    pixelDeltaU : Vec3,
    pixelDeltaV : Vec3,
}

Camera := InternalCamera

init : { aspectRatio : F32, imageWidth : U32, samplesPerPixel : U32, maxDepth : U32 } -> Camera
init = \{ aspectRatio, imageWidth, samplesPerPixel, maxDepth } ->
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

    @Camera { aspectRatio, samplesPerPixel, imageHeight, maxDepth, imageWidth, center, pixel00Loc, pixelDeltaU, pixelDeltaV }

pixelSampleSquare : Rnd.State -> (F32, F32, Rnd.State)
pixelSampleSquare = \seed ->
    r1 = Rnd.float seed
    r2 = Rnd.float r1.state
    px = -0.5 + r1.value
    py = -0.5 + r2.value

    (px, py, r2.state)

getRay : InternalCamera, U32, U32, Rnd.State -> (Ray, Rnd.State)
getRay = \{ pixel00Loc, pixelDeltaU, pixelDeltaV, center }, x, y, seed ->
    pixelCenter =
        pixel00Loc
        |> Vec3.add (Vec3.scale pixelDeltaU (Num.toF32 x))
        |> Vec3.add (Vec3.scale pixelDeltaV (Num.toF32 y))

    (px, py, newSeed) = pixelSampleSquare seed
    pixelSample =
        pixelCenter
        |> Vec3.add (Vec3.scale pixelDeltaU px)
        |> Vec3.add (Vec3.scale pixelDeltaV py)
    origin = center
    direction = Vec3.sub pixelSample origin

    ({ origin, direction }, newSeed)

samplePixelColor : InternalCamera, U32, Vec3, U32, U32, Rnd.State, (Ray, Rnd.State -> (Vec3, Rnd.State)) -> (Vec3, Rnd.State)
samplePixelColor = \camera, step, color, x, y, seed, getColor ->
    if step == 0 then
        (color, seed)
    else
        (ray, newSeed) = getRay camera x y seed
        (rayC, newSeed2) = getColor ray newSeed
        newColor = color |> Vec3.add rayC
        samplePixelColor camera (step - 1) newColor x y newSeed2 getColor

render : Camera, HittableList, Rnd.State -> (List U8, Rnd.State)
render = \@Camera camera, world, initialSeed ->
    result =
        List.range { start: At 0, end: Before camera.imageHeight }
        |> List.walk { seed: initialSeed, list: [] } \pstate, h ->
            List.range { start: At 0, end: Before camera.imageWidth }
            |> List.walk pstate \state, w ->
                (color, newSeed) = samplePixelColor camera camera.samplesPerPixel Vec3.zero w h state.seed (\ray, seed -> rayColor ray camera.maxDepth world seed)

                c = color |> Color.fromVec3 camera.samplesPerPixel

                { seed: newSeed, list: List.append state.list c }

    (ppm camera.imageWidth camera.imageHeight result.list, result.seed)

rayColor : Ray, U32, HittableList, Rnd.State -> (Vec3, Rnd.State)
rayColor = \r, depth, list, seed ->
    if depth == 0 then
        (Vec3.zero, seed)
    else
        when HittableList.hit list r { min: 0.001, max: Num.maxF32 } is
            Hit rec ->
                { value, state } = Vec3.randomUnit seed
                direction = Vec3.add rec.normal value
                (v, newSeed) = rayColor { origin: rec.p, direction } (depth - 1) list state

                (v |> Vec3.scale 0.5, newSeed)

            Miss ->
                dir = Vec3.unit r.direction
                a = 0.5 * ((Vec3.getY dir) + 1.0)

                vec = Vec3.scale Vec3.one (1.0 - a) |> Vec3.add (Vec3.scale (Vec3.new 0.5 0.7 1.0) a)

                (vec, seed)
