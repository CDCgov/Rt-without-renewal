using Documenter
using EpiAware
using Pluto: Configuration.CompilerOptions
using PlutoStaticHTML

include("changelog.jl")
include("pages.jl")
include("build.jl")

build("examples")

makedocs(; sitename = "EpiAware.jl",
    authors = "Samuel Brand, Zachary Susswein, Sam Abbott, and contributors",
    clean = true, doctest = true, linkcheck = true,
    warnonly = [:docs_block, :missing_docs],
    modules = [EpiAware],
    pages = pages,
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true",
        mathengine = Documenter.MathJax3(),
        size_threshold = 600 * 2^10,
        size_threshold_warn = 200 * 2^10
    )
)

deploydocs(
    repo = "github.com/CDCgov/Rt-without-renewal.git",
    target = "build",
    push_preview = true
)
