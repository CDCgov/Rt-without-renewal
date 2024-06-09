abstract type AbstractTuringObservationErrorModel <: AbstractTuringObservationModel end

@model function EpiAwareBase.generate_observations(
        obs_model::AbstractTuringObservationErrorModel,
        y_t,
        Y_t)
    @submodel priors = generate_observation_error_priors(obs_model, y_t, Y_t)

    if ismissing(y_t)
        y_t = Vector{Int}(undef, length(Y_t))
    end

    Y_y = length(y_t) - length(Y_t)

    for i in eachindex(Y_t)
        y_t[Y_y + i] ~ observation_error(obs_model, Y_t[i], priors...)
    end

    return y_t, priors
end

@model function generate_observation_error_priors(
        obs_model::AbstractTuringObservationErrorModel, y_t, Y_t)
    return NamedTuple()
end

function observation_error(obs_model::AbstractTuringObservationErrorModel, Y_t)
    @info "No concrete implementation for `observation_error` is defined."
    return nothing
end
