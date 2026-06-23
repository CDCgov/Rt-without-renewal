using Documenter
using EpiAware
using EpiAware.EpiAwareBase
using EpiAware.EpiAwareUtils
using EpiAware.EpiInference
using EpiAware.EpiInfModels
using EpiAware.EpiLatentModels
using EpiAware.EpiObsModels
using Pluto: Configuration.CompilerOptions
using PlutoStaticHTML

include("changelog.jl")
include("pages.jl")
include("build.jl")

const HTML_SIZE_THRESHOLD_WARN = 2000 * 2^10
const HTML_SIZE_THRESHOLD = 6000 * 2^10
const HTML_SIZE_THRESHOLD_IGNORE = [
    # PlutoStaticHTML embeds large figure output for these showcase notebooks.
    "showcase/replications/chatzilena-2019/index.md",
    "showcase/replications/mishra-2020/index.md"
]

build("getting-started")
build("getting-started/tutorials")
build("showcase/replications/chatzilena-2019")
build("showcase/replications/mishra-2020")

DocMeta.setdocmeta!(EpiAware, :DocTestSetup, :(using EpiAware); recursive = true)

makedocs(; sitename = "EpiAware.jl",
    authors = "Samuel Brand, Zachary Susswein, Sam Abbott, and contributors",
    clean = true, doctest = false, linkcheck = true,
    warnonly = [:docs_block, :missing_docs, :linkcheck, :autodocs_block],
    modules = [
        EpiAware, EpiAware.EpiAwareBase, EpiAware.EpiAwareUtils, EpiAware.EpiInference,
        EpiAware.EpiInfModels, EpiAware.EpiLatentModels, EpiAware.EpiObsModels],
    pages = pages,
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true",
        mathengine = Documenter.MathJax3(),
        size_threshold = HTML_SIZE_THRESHOLD,
        size_threshold_warn = HTML_SIZE_THRESHOLD_WARN,
        size_threshold_ignore = HTML_SIZE_THRESHOLD_IGNORE
    )
)

deploydocs(
    repo = "github.com/CDCgov/Rt-without-renewal.git",
    target = "build",
    push_preview = true
)
