using Documenter, Changelog
using EpiAware

include("changelog.jl")
include("pages.jl")

makedocs(; sitename = "EpiAware.jl",
    authors = "Samuel Brand, Zachary Susswein, Sam Abbott, and contributors",
    clean = true, doctest = true, #linkcheck = true,
    warnonly = [:docs_block, :missing_docs],
    modules = [EpiAware],
    pages = pages,
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true"
    )
)
