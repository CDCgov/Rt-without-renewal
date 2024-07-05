getting_started_pages = Any[
    "Overview" => "getting-started/index.md",
    "Installation" => "getting-started/installation.md",
    "Quickstart" => "getting-started/quickstart.md",
    "Frequently asked questions" => "getting-started/faq.md",
    "Explainers" => [
        "Overview" => "getting-started/explainers/index.md",
        "Working with Julia" => "getting-started/explainers/julia.md",
        "Introduction to EpiAware" => "getting-started/explainers/intro.md",
        "Modelling infections" => "getting-started/explainers/modelling-infections.md",
        "Inference" => "getting-started/explainers/inference.md",
        "Latent models" => "getting-started/explainers/latent-models.md",
        "Observation models" => "getting-started/explainers/observation-models.md"
    ],
    "Tutorials" => [
        "Overview" => "getting-started/tutorials/index.md",
        "Simple renewal with delays" => "getting-started/tutorials/simple-renewal-with-delays.md",
        "Nowcasting" => "getting-started/tutorials/nowcasting.md",
        "Multiple observation models" => "getting-started/tutorials/multiple-observation-models.md",
        "Multiple infection processes" => "getting-started/tutorials/multiple-infection-processes.md",
        "Partial pooling" => "getting-started/tutorials/partial-pooling.md"
    ]
]

showcase_pages = Any[
    "Overview" => "showcase/index.md",
    "Replication" => [
        "On the derivation of the renewal equation from an age-dependent branching process: an epidemic modelling perspective" => "showcase/replications/mishra-2020/index.md"
    ]
]

what_is_pages = [
    "Overview" => "overview.md"
]

module_pages = Any[
    "EpiAware" => [
        "Overview" => "lib/index.md",
        "Public API" => "lib/public.md",
        "Internal API" => "lib/internals.md"
    ],
    "EpiAwareBase" => [
        "Overview" => "lib/EpiAwareBase/index.md",
        "Public API" => "lib/EpiAwareBase/public.md",
        "Internal API" => "lib/EpiAwareBase/internals.md"
    ],
    "EpiAwareUtils" => [
        "Overview" => "lib/EpiAwareUtils/index.md",
        "Public API" => "lib/EpiAwareUtils/public.md",
        "Internal API" => "lib/EpiAwareUtils/internals.md"
    ],
    "EpiInference" => [
        "Overview" => "lib/EpiInference/index.md",
        "Public API" => "lib/EpiInference/public.md",
        "Internal API" => "lib/EpiInference/internals.md"
    ],
    "EpiInfModels" => [
        "Overview" => "lib/EpiInfModels/index.md",
        "Public API" => "lib/EpiInfModels/public.md",
        "Internal API" => "lib/EpiInfModels/internals.md"
    ],
    "EpiLatentModels" => [
        "Overview" => "lib/EpiLatentModels/index.md",
        "Public API" => "lib/EpiLatentModels/public.md",
        "Internal API" => "lib/EpiLatentModels/internals.md"
    ],
    "EpiObsModels" => [
        "Overview" => "lib/EpiObsModels/index.md",
        "Public API" => "lib/EpiObsModels/public.md",
        "Internal API" => "lib/EpiObsModels/internals.md"
    ]
]

developer_pages = [
    "Overview" => "developer/index.md",
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
