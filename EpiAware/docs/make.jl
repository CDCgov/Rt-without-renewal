using Documenter
using EpiAware

include("pages.jl")

# Generate a Documenter-friendly changelog from CHANGELOG.md
Changelog.generate(
    Changelog.Documenter(),
    joinpath(@__DIR__, "..", "CHANGELOG.md"),
    joinpath(@__DIR__, "src", "release-notes.md");
    repo = "JuliaDocs/Documenter.jl"
)

makedocs(; sitename = "EpiAware.jl",
    authors = "Samuel Brand, Zachary Susswein, Sam Abbott, and contributors",
    clean = true, doctest = true, linkcheck = true,
    warnonly = [:docs_block, :missing_docs],
    modules = [EpiAware],
    pages = pages)
