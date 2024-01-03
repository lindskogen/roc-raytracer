interface Output
    exposes [ppm]
    imports [pf.Stdout, pf.Task.{ Task }, Color.{ Color }]

writeHeader = \width, height ->
    Stdout.line "P3\n\(Num.toStr width) \(Num.toStr height)\n255"

ppm : I32, I32, List Color -> Task {} a
ppm = \width, height, data ->
    _ <- writeHeader width height |> Task.await

    Task.loop data \list ->
        when list is
            [] -> Task.ok (Done {})
            [{r, g, b}, .. as rest] ->
                _ <- Stdout.line "\(Num.toStr r) \(Num.toStr g) \(Num.toStr b)" |> Task.await

                Task.ok (Step rest)


