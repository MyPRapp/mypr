# Prevent R8 from discarding notification icons (or any other resources)
-keep class **.R$drawable {
    *;
}

-keep class **.R$raw {
    *;
}

-keep class **.R$layout {
    *;
}

-keep class **.R$string {
    *;
}

-keep class **.R$color {
    *;
}
