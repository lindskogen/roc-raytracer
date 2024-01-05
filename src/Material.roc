interface Material
    exposes [Material, metal, lambertian, dielectric]
    imports [Vec3.{ Vec3 }]

Material : [Lambertian { albedo : Vec3 }, Metal { albedo : Vec3, fuzz : F32 }, Dielectric { refractionIndex : F32 }]

metal : Vec3, F32 -> Material
metal = \color, fuzz ->
    Metal { albedo: color, fuzz: if fuzz > 1.0 then 1.0 else fuzz }

lambertian : Vec3 -> Material
lambertian = \color ->
    Lambertian { albedo: color }

dielectric : F32 -> Material
dielectric = \refractionIndex ->
    Dielectric { refractionIndex }

