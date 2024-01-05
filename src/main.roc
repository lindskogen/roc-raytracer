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
        pf.Utc,
        pf.Task.{ Task },
        Camera,
        Vec3.{ Vec3 },
        HittableList.{ HittableList },
        rand.Random,
        Rnd,
    ]
    provides [main] to pf

world : HittableList
world = [
    { center: Vec3.new 0.0 0.0 -1.0, radius: 0.5 },
    { center: Vec3.new 0.0 -100.5 -1.0, radius: 100.0 },
]

main =
    initialSeed <- Rnd.initialize {} |> Task.await

    camera = Camera.init { aspectRatio: (16.0 / 9.0f32), imageWidth: 400, samplesPerPixel: 100 }

    (buffer, _) = Camera.render camera world initialSeed

    File.writeBytes (Path.fromStr "out.ppm") buffer
    |> Task.onErr \e ->
        when e is
            FileWriteErr _ err -> Stdout.line (File.writeErrToStr err)

