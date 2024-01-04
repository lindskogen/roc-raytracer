app "raytracer"
    packages {
        pf: "https://github.com/roc-lang/basic-cli/releases/download/0.7.0/bkGby8jb0tmZYsy2hg1E_B2QrCgcSTxdUlHtETwm5m4.tar.br",
        rand: "https://github.com/lukewilliamboswell/roc-random/releases/download/0.1.0/OoD8jmqBLc0gyuaadckDMx1jedEa03EdGSR_V4KhH7g.tar.br",
    }
    imports [
        pf.Stdout,
        pf.File,
        pf.Path.{ Path },
        pf.Task,
        pf.Task.{ Task },
        Output.{ ppm },
        Color.{ Color },
        Vec3.{ Vec3 },
        Ray.{ Ray },
    ]
    provides [main] to pf

aspectRatio = 16.0 / 9.0f32
imageWidth = 400

imageHeight =
    Num.floor (imageWidth / aspectRatio)
    |> Num.max 1

focalLength = 1.0
viewportHeight = 2.0
viewportWidth = viewportHeight * ((Num.toF32 imageWidth) / (Num.toF32 imageHeight))
cameraCenter = Vec3.zero

viewportU = Vec3.new viewportWidth 0.0 0.0
viewportV = Vec3.new 0.0 -viewportHeight 0.0

pixelDeltaU = Vec3.div viewportU (Num.toF32 imageWidth)
pixelDeltaV = Vec3.div viewportV (Num.toF32 imageHeight)

viewportUpperLeft =
    cameraCenter
    |> Vec3.sub (Vec3.new 0.0 0.0 focalLength)
    |> Vec3.sub (Vec3.div viewportU 2.0)
    |> Vec3.sub (Vec3.div viewportV 2.0)

pixel00Loc = Vec3.add viewportUpperLeft (Vec3.add pixelDeltaU pixelDeltaV |> Vec3.scale 0.5)

rayColor : Ray -> Color
rayColor = \r ->
    when hitSphere (Vec3.new 0.0 0.0 -1.0) 0.5 r is
        Hit t ->
            n = Vec3.sub (Ray.at r t) (Vec3.new 0.0 0.0 -1.0) |> Vec3.unit
            Vec3.scale (Vec3.new (Vec3.getX n + 1) (Vec3.getY n + 1) (Vec3.getZ n + 1)) 0.5 |> Color.fromVec3

        NoHit ->
            dir = Vec3.unit r.direction
            a = 0.5 * ((Vec3.getY dir) + 1.0)

            Vec3.scale Vec3.one (1.0 - a) |> Vec3.add (Vec3.scale (Vec3.new 0.5 0.7 1.0) a) |> Color.fromVec3

hitSphere : Vec3, F32, Ray -> [NoHit, Hit F32]
hitSphere = \center, radius, r ->
    oc = Vec3.sub r.origin center
    a = Vec3.lenSquared r.direction
    halfB = Vec3.dotProduct oc r.direction
    c = (Vec3.lenSquared oc) - (radius * radius)
    discriminant = halfB * halfB - a * c

    if discriminant < 0 then
        NoHit
    else
        Hit ((-halfB - Num.sqrt discriminant) / a)

main =

    pixels =
        List.range { start: At 0, end: Before imageHeight }
        |> List.joinMap \h ->
            List.range { start: At 0, end: Before imageWidth }
            |> List.map \w ->
                pixelCenter =
                    pixel00Loc
                    |> Vec3.add (Vec3.scale pixelDeltaU (Num.toF32 w))
                    |> Vec3.add (Vec3.scale pixelDeltaV (Num.toF32 h))
                rayDirection = Vec3.sub pixelCenter cameraCenter

                rayColor { origin: cameraCenter, direction: rayDirection }

    File.writeBytes (Path.fromStr "out.ppm") (ppm imageWidth imageHeight pixels)
    |> Task.onErr \e ->
        when e is
            FileWriteErr _ err -> Stdout.line (File.writeErrToStr err)

