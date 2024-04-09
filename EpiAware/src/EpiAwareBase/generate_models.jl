@doc raw"
Create an epi-aware model using the specified epi_model, latent_model, and observation_model.

# Arguments
- `y_t`: The observed data.
- `time_steps`: The time steps.
- `epi_model`: An abstract epi model.
- `latent_model`: An abstract latent model.
- `observation_model`: An abstract observation model.

# Returns
- `nothing`
"
function generate_epiware(y_t, time_steps; epi_model::AbstractEpiModel,
        latent_model::AbstractLatentModel, observation_model::AbstractObservationModel)
    @info "No concrete implementation for `generate_epiware` is defined."
    return nothing
end

@doc raw"
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
"
function generate_latent_infs(epi_model::AbstractEpiModel, Z_t)
    @warn "No concrete implementation for `generate_latent_infs` is defined."
    return nothing
end

@doc raw"
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
"
function generate_latent(latent_model::AbstractLatentModel, n)
    @info "No concrete implementation for generate_latent is defined."
    return nothing
end

@doc raw"
Constructor function for generating observations based on the given observation model.

The `generate_observations` function implements a model of generating observations based on the given observation model. Which model of generating observations to be implemented is set by the type of `obs_model`. If no implemention is defined for the given `obs_model`, then `EpiAware` will return a warning and return `nothing`.
"
function generate_observations(obs_model::AbstractObservationModel,
        y_t,
        Y_t)
    @info "No concrete implementation for generate_observations is defined."
    return nothing
end
