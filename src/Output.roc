interface Output
    exposes [ppm]
    imports [pf.Stdout, pf.Task.{ Task }, Color.{ Color }]

header = \width, height ->
    "P3\n\(Num.toStr width) \(Num.toStr height)\n255\n"

ppm : U32, U32, List Color -> List U8
ppm = \width, height, data ->
        (Str.toUtf8 (header width height))
        |> List.concat (List.joinMap data \{r, g, b} -> (Str.toUtf8 "\(Num.toStr r) \(Num.toStr g) \(Num.toStr b)\n"))