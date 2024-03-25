@doc raw"""
Constructor function for unobserved/latent infections based on the type of
`epi_model <: AbstractEpimodel` and a latent process path ``Z_t``.

The `generate_latent_infs` function implements a model of generating unobserved/latent
infections conditional on a latent process. Which model of generating unobserved/latent
infections to be implemented is set by the type of `epi_model`. If no implemention is
defined for the given `epi_model`, then `EpiAware` will return a warning and return
`nothing`.

## Interface to `Turing.jl` probablilistic programming language (PPL)

Apart from the no implementation fallback method, the `generate_latent_infs` implementation
function returns a constructor function for a
    [`DynamicPPL.Model`](https://turinglang.org/DynamicPPL.jl/stable/api/#DynamicPPL.Model)
object where the unobserved/latent infections are a generated quantity. Priors for model
parameters are fields of `epi_model`.
"""
function generate_latent_infs(epi_model::AbstractEpiModel, Z_t)
    @warn "No concrete implementation for `generate_latent_infs` is defined."
    return nothing
end

@doc raw"""
Constructor function for a latent process path ``Z_t`` of length `n`.

The `generate_latent` function implements a model of generating a latent process. Which
model for generating the latent process infections is implemented is set by the type of
`latent_model`. If no implemention is defined for the type of `latent_model`, then
`EpiAware` will pass a warning and return `nothing`.

## Interface to `Turing.jl` probablilistic programming language (PPL)

Apart from the no implementation fallback method, the `generate_latent` implementation
function should return a constructor function for a
    [`DynamicPPL.Model`](https://turinglang.org/DynamicPPL.jl/stable/api/#DynamicPPL.Model)
object. Sample paths of ``Z_t`` are generated quantities of the constructed model. Priors
for model parameters are fields of `epi_model`.
"""
function generate_latent(latent_model::AbstractLatentModel, n)
    @info "No concrete implementation for generate_latent is defined."
    return nothing
end

function generate_observations(obs_model::AbstractObservationModel,
        y_t,
        Y_t)
    @info "No concrete implementation for generate_observations is defined."
    return nothing
end

"""
Apply the inference/generative method `method` to the `DynamicPPL.Model` object `mdl`.

# Arguments
- `method::AbstractEpiMethod`: The epidemiological method to apply.
- `mdl::DynamicPPL.Model`: The model to apply the method to.
- `prev_result`: The previous result of the method.
- `kwargs`: Additional keyword arguments passed to the method.

# Returns
- `nothing`: If no concrete implementation is defined for the given `method`.
"""
function _apply_method(method::AbstractEpiMethod, mdl::DynamicPPL.Model, prev_result;
        kwargs...)
    @info "No concrete implementation for `_apply_method` is defined."
    return nothing
end
