pages = [
    "EpiAware.jl: Real-time epidemic monitoring" => "index.md",
    "Manual" => Any[
        "Guide" => "man/guide.md",
        "Examples" => [
            "Getting started" => "man/getting-started.md"
        ]
    ],
    "Reference" => Any[
        "Public API" => "lib/public.md"
    ],
    "Developers" => [
        "contributing.md",
        "checklists.md",
        "Internals" => map(
            s -> "lib/internals/$(s)",
            sort(readdir(joinpath(@__DIR__, "src/lib/internals")))
        )
    ],
    "release-notes.md"
]
