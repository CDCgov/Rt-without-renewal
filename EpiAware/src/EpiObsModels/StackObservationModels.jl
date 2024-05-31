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
        model_names = [typeof(i) for i in 1:length(models)]
        return StackObservationModels(models, model_names)
    end

    function StackObservationsModels(models::NamedTuple)
        # use the keys of the NamedTuple as the model names
        return StackObservationModels(values(models), keys(models))
    end
end
