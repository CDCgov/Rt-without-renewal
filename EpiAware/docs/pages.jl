getting_started_pages = Any[
    "Installation" => "getting-started/installation.md",
    "Quickstart" => "getting-started/quickstart.md",
    "Frequently asked questions" => "getting-started/faq.md",
    "Tutorials" => [
        "Working with Julia" => "getting-started/tutorials/julia.md",
        "Introduction to EpiAware" => "getting-started/tutorials/intro.md",
        "Modelling infections" => "getting-started/tutorials/modelling-infections.md",
        "Inference" => "getting-started/tutorials/inference.md",
        "Latent models" => "getting-started/tutorials/latent-models.md",
        "Observation models" => "getting-started/tutorials/observation-models.md"
    ]
]

showcase_pages = [
    "Replication" => [
    "On the derivation of the renewal equation from an age-dependent branching process: an epidemic modelling perspective" => "showcase/replications/mishra-2020/index.md"
]
]

what_is_pages = [
    "Overview" => "overview.md"
]

module_pages = Any[
    "EpiAwareBase" => "lib/EpiAwareBase/index.md",
    "EpiAwareUtils" => "lib/EpiAwareUtils/index.md",
    "EpiInference" => "lib/EpiInference/index.md",
    "EpiInfModels" => "lib/EpiInfModels/index.md",
    "EpiLatentModels" => "lib/EpiLatentModels/index.md",
    "EpiObsModels" => "lib/EpiObsModels/index.md",
    "EpiAware" => [
        "Public API" => "lib/public.md",
        "Internal API" => "lib/internals.md"
    ]
]

developer_pages = [
    "Contributing" => "developer/contributing.md",
    "Release checklist" => "developer/checklist.md"
]

pages = [
    "EpiAware.jl: Real-time infectious disease monitoring" => "index.md",
    "Getting started" => getting_started_pages,
    "Showcase" => showcase_pages,
    "What is EpiAware?" => what_is_pages,
    "Modules" => module_pages,
    "Developers" => developer_pages,
    "release-notes.md"
]
