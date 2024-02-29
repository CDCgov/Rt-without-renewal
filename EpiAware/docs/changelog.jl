# Generate a Documenter-friendly changelog from CHANGELOG.md
using Changelog

Changelog.generate(
    Changelog.Documenter(),
    joinpath(@__DIR__, "..", "CHANGELOG.md"),
    joinpath(@__DIR__, "src", "release-notes.md");
    repo = "JuliaDocs/Documenter.jl"
)
