module EpiAware

# Non-submodule imports
using Turing, DocStringExtensions, Reexport, DynamicPPL, MCMCChains

# Submodule imports
include("EpiAwareBase/EpiAwareBase.jl")
@reexport using .EpiAwareBase

include("EpiAwareUtils/EpiAwareUtils.jl")
@reexport using .EpiAwareUtils

include("EpiLatentModels/EpiLatentModels.jl")
@reexport using .EpiLatentModels

include("EpiInfModels/EpiInfModels.jl")
@reexport using .EpiInfModels

include("EpiObsModels/EpiObsModels.jl")
@reexport using .EpiObsModels

include("EpiInference/EpiInference.jl")
@reexport using .EpiInference

include("docstrings.jl")

end
