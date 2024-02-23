using Documenter
using EpiAware

include("pages.jl")

makedocs(; sitename = "EpiAware.jl",
    authors = "Samuel Brand, Zachary Susswein, and Sam Abbott",
    clean = true, doctest = true, linkcheck = true,
    warnonly = [:docs_block, :missing_docs],
    modules = [EpiAware],
    pages = pages)
