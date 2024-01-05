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
        Material,
        rand.Random,
        Rnd,
    ]
    provides [main] to pf

matGround = Material.lambertian (Vec3.new 0.8 0.8 0.0)
matCenter = Material.lambertian (Vec3.new 0.1 0.2 0.5)
matLeft = Material.dielectric 1.5
matRight = Material.metal (Vec3.new 0.8 0.6 0.2) 0.0

world : HittableList
world = [
    { center: Vec3.new 0.0 -100.5 -1.0, radius: 100.0, mat: matGround },
    { center: Vec3.new 0.0 0.0 -1.0, radius: 0.5, mat: matCenter },
    { center: Vec3.new -1.0 0.0 -1.0, radius: 0.5, mat: matLeft },
    { center: Vec3.new -1.0 0.0 -1.0, radius: -0.4, mat: matLeft },
    { center: Vec3.new 1.0 0.0 -1.0, radius: 0.5, mat: matRight },
]

main =
    initialSeed <- Rnd.initialize {} |> Task.await

    dbg "init"

    camera = Camera.init {
        aspectRatio: (16.0 / 9.0f32),
        imageWidth: 400,
        samplesPerPixel: 100,
        maxDepth: 50,
        vfov: 20.0,
        lookFrom: Vec3.new -2.0 2.0 1.0,
        lookAt: Vec3.new 0.0 0.0 -1.0,
        vup: Vec3.new 0.0 1.0 0.0,
        defocusAngle: 10.0,
        focusDist: 3.4,
    }

    dbg "render"

    (buffer, _) = Camera.render camera world initialSeed

    dbg "file write"

    File.writeBytes (Path.fromStr "out.ppm") buffer
    |> Task.onErr \e ->
        when e is
            FileWriteErr _ err -> Stdout.line (File.writeErrToStr err)

