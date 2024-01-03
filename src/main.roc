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
        Color.{ Color }
    ]
    provides [main] to pf

imageWidth = 256
imageHeight = 256

getPixels: Num a, Num a -> Color
getPixels = \w, h ->
    { r: 255 * ((Num.toF32 w) / (imageWidth - 1)) |> Num.floor |> Num.toU8,
      g: 255 * ((Num.toF32 h) / (imageHeight - 1)) |> Num.floor |> Num.toU8,
      b: 0u8
    }


main =
    pixels = List.range { start: At 0, end: Before imageHeight } 
        |> List.joinMap \h -> 
            List.range { start: At 0, end: Before imageWidth } 
                |> List.map \w -> getPixels w h

    File.writeBytes (Path.fromStr "out.ppm") (ppm imageWidth imageHeight pixels)
        |> Task.onErr \e -> 
            when e is 
                FileWriteErr _ err -> Stdout.line (File.writeErrToStr err)



