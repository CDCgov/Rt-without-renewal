@doc raw"
The abstract supertype for all structs that define a model for generating
observation errors.
"
abstract type AbstractTuringObservationErrorModel <: AbstractTuringObservationModel end

@doc raw"
Generates observations from an observation error model. It provides support for missing values in observations (`y_t`), and missing values at the beginning of the expected observations (`Y_t`). It dispatches to the `observation_error` function to generate the observation error distribution which uses priors generated by `generate_observation_error_priors` submodel. For most observation error models specific implementations of `observation_error` and `generate_observation_error_priors` are required but a specific implementation of `generate_observations` is not required.
"
@model function EpiAwareBase.generate_observations(
        obs_model::AbstractTuringObservationErrorModel,
        y_t,
        Y_t)
    @submodel priors = generate_observation_error_priors(obs_model, y_t, Y_t)

    if ismissing(y_t)
        y_t = Vector{Union{Real, Missing}}(missing, length(Y_t))
    end

    for i in findfirst(!ismissing, Y_t):length(Y_t)
        y_t[i] ~ observation_error(obs_model, Y_t[i], priors...)
    end

    return y_t, priors
end

@doc raw"
Generates priors for the observation error model. This should return a named tuple containing the priors required for generating the observation error distribution.
"
@model function generate_observation_error_priors(
        obs_model::AbstractTuringObservationErrorModel, y_t, Y_t)
    return NamedTuple()
end

@doc raw"
The observation error distribution for the observation error model. This function should return the distribution for the observation error given the expected observation value `Y_t` and the priors generated by `generate_observation_error_priors`.
"
function observation_error(obs_model::AbstractTuringObservationErrorModel, Y_t)
    @info "No concrete implementation for `observation_error` is defined."
    return nothing
end
