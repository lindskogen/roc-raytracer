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

matGround = Material.lambertian (Vec3.new 0.5 0.5 0.5)

ground = { center: Vec3.new 0.0 -1000.0 0.0, radius: 1000.0, mat: matGround }

generateWorld = \initialSeed ->
    range = List.range { start: At -11, end: Before 11 }

    List.walk range { seed: initialSeed, objects: [] } \pstate, a ->
        List.walk range pstate \state, b ->
            mat = Rnd.float state.seed
            xcoord = Rnd.float mat.state
            ycoord = Rnd.float xcoord.state

            center = Vec3.new ((Num.toF32 a) + 0.9 * xcoord.value) 0.2 ((Num.toF32 b) + 0.9 * ycoord.value)

            if Vec3.sub center (Vec3.new 4.0 0.2 0.0) |> Vec3.len > 0.9 then
                if mat.value < 0.8 then
                    { value: albedo1, state: colorState } = Vec3.random ycoord.state
                    { value: albedo2, state: colorState2 } = Vec3.random colorState
                    albedo = Vec3.mul albedo1 albedo2

                    object = { center, radius: 0.2, mat: Material.lambertian albedo }
                    { objects: List.append state.objects object, seed: colorState2 }
                else if mat.value < 0.95 then
                    { value: albedo, state: colorState } = Vec3.randomInRange ycoord.state 0.5 1.0
                    { value: fuzz, state: fuzzState } = Rnd.floatInRange colorState 0.0 0.5

                    object = { center, radius: 0.2, mat: Material.metal albedo fuzz }
                    { objects: List.append state.objects object, seed: fuzzState }
                else
                    object = { center, radius: 0.2, mat: Material.dielectric 1.5 }
                    { objects: List.append state.objects object, seed: ycoord.state }
            else
                { state & seed: ycoord.state }

main =
    initialSeed <- Rnd.initialize {} |> Task.await

    dbg "generate"

    { objects, seed } = generateWorld initialSeed

    world = List.concat objects [
        ground,
        { center: Vec3.new 0.0 1.0 0.0, radius: 1.0, mat: Material.dielectric 1.5 },
        { center: Vec3.new -4.0 1.0 0.0, radius: 1.0, mat: Material.lambertian (Vec3.new 0.4 0.2 0.1) },
        { center: Vec3.new 4.0 1.0 0.0, radius: 1.0, mat: Material.metal (Vec3.new 0.7 0.6 0.5) 0.0 },
    ]

    dbg "init"

    camera = Camera.init {
        aspectRatio: (16.0 / 9.0f32),
        imageWidth: 1200,
        samplesPerPixel: 500,
        maxDepth: 50,
        vfov: 20.0,
        lookFrom: Vec3.new 13.0 2.0 3.0,
        lookAt: Vec3.new 0.0 0.0 0.0,
        vup: Vec3.new 0.0 1.0 0.0,
        defocusAngle: 0.6,
        focusDist: 10.0,
    }

    dbg "render"

    (buffer, _) = Camera.render camera world seed

    dbg "file write"

    File.writeBytes (Path.fromStr "out.ppm") buffer
    |> Task.onErr \e ->
        when e is
            FileWriteErr _ err -> Stdout.line (File.writeErrToStr err)

