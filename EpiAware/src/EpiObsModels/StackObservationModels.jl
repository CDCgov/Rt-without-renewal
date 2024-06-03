@kwdef struct StackObservationModels{
    M <: AbstractVector{<:AbstractTuringObservationModel},
    N <: AbstractVector{<:AbstractString}} <:
              AbstractTuringObservationModel
    "A vector of observation models."
    models::M
    "A vector of observation model names"
    model_names::N

    function StackObservationModels(models::Vector{<:M},
            model_names::Vector{<:N}) where {
            M <: AbstractTuringObservationModel,
            N <: AbstractString
    }
        @assert length(models)==length(model_names) "The number of models and model names must be equal."
        new{typeof(models), typeof(model_names)}(models, model_names)
    end

    function StackObservationModels(models::Vector{<:M}) where {
            M <: AbstractTuringObservationModel
    }
        model_names = models .|>
                      typeof .|>
                      nameof .|>
                      string
        return StackObservationModels(models, model_names)
    end

    function StackObservationModels(models::NamedTuple{
            names, T}) where {names, T <: Tuple{Vararg{AbstractTuringObservationModel}}}
        model_names = models |>
                      keys .|>
                      string |>
                      collect
        return StackObservationModels(collect(values(models)), model_names)
    end
end

@model function EpiAwareBase.generate_observations(
        obs_model::StackObservationModels, y_t::NamedTuple, Y_t)
    @assert length(obs_model.models)==length(y_t) "The number of models and observations datasets must be equal."
    @assert obs_model.model_names==keys(y_t) .|> string |> collect "The model names must match the keys of the observation datasets."
    obs = ()
    for (model, model_name) in zip(obs_model.models, obs_model.model_names)
        @submodel prefix=eval(model_name) obs_tmp=generate_observations(
            model, y_t[Symbol(model_name)], Y_t)
        obs = obs..., obs_tmp...
    end
    return obs
end
