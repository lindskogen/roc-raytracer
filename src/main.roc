app "raytracer"
    packages {
        pf: "https://github.com/roc-lang/basic-cli/releases/download/0.7.0/bkGby8jb0tmZYsy2hg1E_B2QrCgcSTxdUlHtETwm5m4.tar.br",
        rand: "https://github.com/lukewilliamboswell/roc-random/releases/download/0.1.0/OoD8jmqBLc0gyuaadckDMx1jedEa03EdGSR_V4KhH7g.tar.br",
    }
    imports [
        pf.Stdout,
        pf.Task.{ Task },
    ]
    provides [main] to pf

imageWidth = 256
imageHeight = 256

main =
    _ <- Stdout.line
            "P3\n\(Num.toStr imageWidth) \(Num.toStr imageHeight)\n255"
        |> Task.attempt

    _ <- Task.loop
            0f32
            \height ->
                _ <- Task.loop 0f32 \width ->
                        r = 255 * ((Num.toF32 width) / (imageWidth - 1)) |> Num.floor
                        g = 255 * ((Num.toF32 height) / (imageHeight - 1)) |> Num.floor
                        b = 0

                        _ <- Stdout.line "\(Num.toStr r) \(Num.toStr g) \(Num.toStr b)" |> Task.attempt

                        if width < (imageWidth - 1) then
                            Task.ok (Step (width + 1))
                        else
                            Task.ok (Done width)
                    |> Task.attempt
                if height < (imageHeight - 1) then
                    Task.ok (Step (height + 1))
                else
                    Task.ok (Done height)
        |> Task.attempt

    Task.ok {}

