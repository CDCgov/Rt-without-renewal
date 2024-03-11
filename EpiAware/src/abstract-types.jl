abstract type AbstractModel end

abstract type AbstractEpiModel <: AbstractModel end

abstract type AbstractLatentModel <: AbstractModel end

abstract type AbstractObservationModel <: AbstractModel end

@doc raw"""
Generate latent infections based on the given epidemiological model and a latent process
path ``Z_t``.

# Arguments
- `epi_model::DirectInfections`: The epidemiological model used to generate latent infections.
- `Z_t`: The noise term.

# Returns
- An array of generated latent infections.

# Example
"""
function generate_latent_infs(epi_model::AbstractEpiModel, Z_t)
    @info "No concrete implementation for `generate_latent_infs` is defined."
    return nothing
end

function generate_latent(latent_model::AbstractLatentModel, n)
    @info "No concrete implementation for generate_latent is defined."
    return nothing
end
