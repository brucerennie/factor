USING: gitignore kernel sequences system tools.test ;

! XXX: temporarily disable on windows
os windows? [

{
    { t t f f f t t t }
} [
    {
        "a/b"
        "a/b/c"
        "b"
        "c"
        "d"
        "d/e"
        "d/e/f"
        "d/e/f/g"
    }

    "
    # comment
    **/b
    !c
    e/
    d/e
    " parse-gitignore '[ _ gitignored? ] map
] unit-test

] unless
