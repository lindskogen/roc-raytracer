interface Vec3
    exposes [
        Vec3,
        zero,
        one,
        new,
        neg,
        add,
        sub,
        mul,
        len,
        lenSquared,
        scale,
        div,
        nearZero,
        reflect,
        dotProduct,
        crossProduct,
        unit,
        getX,
        getY,
        getZ,
        randomOnHemisphere,
        randomUnit,
    ]
    imports [Rnd]

Vec3 := { x : F32, y : F32, z : F32 }
    implements [
        Eq { isEq: vecEquality },
    ]

getX : Vec3 -> F32
getX = \@Vec3 v -> v.x

getY : Vec3 -> F32
getY = \@Vec3 v -> v.y

getZ : Vec3 -> F32
getZ = \@Vec3 v -> v.z

floatEq : F32, F32 -> Bool
floatEq = \a, b ->
    (a <= b) && (b >= a)

vecEquality : Vec3, Vec3 -> Bool
vecEquality = \@Vec3 u, @Vec3 v ->
    floatEq u.x v.x
    &&
    floatEq u.y v.y
    &&
    floatEq u.z v.z

zero : Vec3
zero = @Vec3 { x: 0.0, y: 0.0, z: 0.0 }

one : Vec3
one = @Vec3 { x: 1.0, y: 1.0, z: 1.0 }

new : F32, F32, F32 -> Vec3
new = \x, y, z ->
    @Vec3 { x, y, z }

neg : Vec3 -> Vec3
neg = \@Vec3 { x, y, z } -> @Vec3 { x: -x, y: -y, z: -z }

expect neg (new 1.0 2.0 0.0) == (new -1.0 -2.0 0.0)

add : Vec3, Vec3 -> Vec3
add = \@Vec3 u, @Vec3 v ->
    @Vec3 { x: u.x + v.x, y: u.y + v.y, z: u.z + v.z }

expect add (new 1.0 2.0 0.0) (new 4.0 -1.0 0.0) == (new 5.0 1.0 0.0)

sub : Vec3, Vec3 -> Vec3
sub = \@Vec3 u, @Vec3 v ->
    @Vec3 { x: u.x - v.x, y: u.y - v.y, z: u.z - v.z }

expect sub (new 5.0 1.0 0.0) (new 4.0 -1.0 0.0) == (new 1.0 2.0 0.0)
expect sub (new 5.0 1.0 0.0) (new 1.0 2.0 0.0) == (new 4.0 -1.0 0.0)

mul : Vec3, Vec3 -> Vec3
mul = \@Vec3 u, @Vec3 v ->
    @Vec3 { x: u.x * v.x, y: u.y * v.y, z: u.z * v.z }

expect mul (new 2.0 3.0 4.0) (new 5.0 6.0 7.0) == (new 10.0 18.0 28.0)

lenSquared : Vec3 -> F32
lenSquared = \@Vec3 v ->
    v.x * v.x + v.y * v.y + v.z * v.z

expect floatEq (lenSquared (new 3.0 4.0 5.0)) 50

len : Vec3 -> F32
len = \v ->
    Num.sqrt (lenSquared v)

expect
    a = len (new 3.0 4.0 5.0)
    b = 7.071068f32
    floatEq a b

scale : Vec3, F32 -> Vec3
scale = \@Vec3 { x, y, z }, t ->
    @Vec3 { x: x * t, y: y * t, z: z * t }

expect scale (new 2.0 3.0 4.0) 2.0 == (new 4.0 6.0 8.0)

div : Vec3, F32 -> Vec3
div = \v, t ->
    scale v (1 / t)

expect div (new 6.0 8.0 10.0) 2.0 == (new 3.0 4.0 5.0)

nearZero : Vec3 -> Bool
nearZero = \@Vec3 { x, y, z } ->
    s = 1e-8

    Num.abs x < s && Num.abs y < s && Num.abs z < s

expect nearZero (new 1e-9 1e-9 1e-9) == Bool.true

dotProduct : Vec3, Vec3 -> F32
dotProduct = \@Vec3 u, @Vec3 v ->
    u.x * v.x + u.y * v.y + u.z * v.z

expect floatEq (dotProduct (new 2.0 3.0 4.0) (new 5.0 6.0 7.0)) 68.0

crossProduct : Vec3, Vec3 -> Vec3
crossProduct = \@Vec3 u, @Vec3 v ->
    @Vec3 {
        x: u.y * v.z - u.z * v.y,
        y: u.z * v.x - u.x * v.z,
        z: u.x * v.y - u.y * v.x,
    }

expect crossProduct (new 2.0 3.0 4.0) (new 5.0 6.0 7.0) == (new -3.0 6.0 -3.0)

unit : Vec3 -> Vec3
unit = \v ->
    div v (len v)

expect unit (new 3.0 4.0 5.0) == (new 1.0 1.0 1.0)

reflect : Vec3, Vec3 -> Vec3
reflect = \v, n ->
    Vec3.sub v (Vec3.scale n (Vec3.dotProduct v n) |> Vec3.scale 2.0)

random : Rnd.State -> { value : Vec3, state : Rnd.State }
random = \seed ->
    r1 = Rnd.float seed
    r2 = Rnd.float r1.state
    r3 = Rnd.float r2.state

    { value: new r1.value r2.value r3.value, state: r3.state }

randomInRange : Rnd.State, F32, F32 -> { value : Vec3, state : Rnd.State }
randomInRange = \seed, min, max ->
    r1 = Rnd.floatInRange seed min max
    r2 = Rnd.floatInRange r1.state min max
    r3 = Rnd.floatInRange r2.state min max

    { value: new r1.value r2.value r3.value, state: r3.state }

randomInUnitSphere : Rnd.State -> { value : Vec3, state : Rnd.State }
randomInUnitSphere = \seed ->
    recur = \{ value, state } ->
        if lenSquared value < 1 then
            { value, state }
        else
            recur (randomInRange state -1.0 1.0)

    recur (randomInRange seed -1.0 1.0)

randomOnHemisphere : Rnd.State, Vec3 -> { value : Vec3, state : Rnd.State }
randomOnHemisphere = \seed, normal ->
    { state, value } = randomUnit seed

    if dotProduct value normal > 0.0 then
        { value, state }
    else
        { value: neg value, state }

randomUnit : Rnd.State -> { value : Vec3, state : Rnd.State }
randomUnit = \seed ->
    { value, state } = randomInUnitSphere seed

    { value: unit value, state }
