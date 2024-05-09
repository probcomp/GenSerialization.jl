using Documenter, GenSerialization, Gen

makedocs(sitename="GenSerialization.jl",
    modules = [GenSerialization],
    doctest = false,
    clean = true,
    warnonly = true,
    pages = [
        "API" => "index.md",
    ]
)

deploydocs(
    repo = "github.com/probcomp/GenSerialization.jl.git",
    target = "build",
    dirname = "docs",
)