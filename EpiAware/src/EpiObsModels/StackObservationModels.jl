@doc raw"

A stack of observation models that are looped over to generate observations for
each model in the stack. Note that the model names are used to prefix the parameters in each model (so if I have a model named `cases` and a parameter `y_t`, the parameter in the model will be `cases.y_t`). Inside the constructor `PrefixObservationModel` is wrapped around each observation model.

## Constructors

- `StackObservationModels(models::Vector{<:AbstractTuringObservationModel},
    model_names::Vector{<:AbstractString})`: Construct a `StackObservationModels` object with a vector of observation models and a vector of model names.
    - `StackObservationModels(; models::Vector{<:AbstractTuringObservationModel},
    model_names::Vector{<:AbstractString})`: Construct a `StackObservationModels` object with a vector of observation models and a
    vector of model names.
- `StackObservationModels(models::NamedTuple{names, T})`: Construct a
    `StackObservationModels` object with a named tuple of observation models. The model names are automatically generated from the keys of the named tuple.

## Example

```julia
using EpiAware, Turing

obs = StackObservationModels(
    (cases = PoissonError(), deaths = NegativeBinomialError())
)
y_t = (cases = missing, deaths = missing)
obs_model = generate_observations(obs, y_t, fill(10, 10))
rand(obs_model)
samples = sample(obs_model, Prior(), 100; progress = false)

cases_y_t = group(samples, \"cases.y_t\")
cases_y_t

deaths_y_t = group(samples, \"deaths.y_t\")
deaths_y_t
```
"
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
        wrapped_models = [PrefixObservationModel(models[i], model_names[i])
                          for i in eachindex(models)]
        new{AbstractVector{<:AbstractTuringObservationModel}, typeof(model_names)}(
            wrapped_models, model_names)
    end
end

function StackObservationModels(models::NamedTuple{
        names, T}) where {names, T <: Tuple{Vararg{AbstractTuringObservationModel}}}
    model_names = models |>
                  keys .|>
                  string |>
                  collect
    return StackObservationModels(collect(values(models)), model_names)
end

@doc raw"
Generate observations from a stack of observation models. Assumes a 1 to 1 mapping between `y_t` and `Y_t`.

# Arguments
- `obs_model::StackObservationModels`: The stack of observation models.
- `y_t::NamedTuple`: The observed values.
- `Y_t::NamedTuple`: The expected values.
"
@model function EpiAwareBase.generate_observations(
        obs_model::StackObservationModels, y_t::NamedTuple, Y_t::NamedTuple)
    @assert length(obs_model.models)==length(y_t) "The number of models and observations datasets must be equal."
    @assert obs_model.model_names==keys(y_t) .|> string |> collect "The model names must match the keys of the observation datasets."
    @assert keys(y_t)==keys(Y_t) "The keys of the observed and true values must match."

    obs = map(zip(obs_model.models, obs_model.model_names)) do (model, model_name)
        @submodel obs_tmp = generate_observations(
            model, y_t[Symbol(model_name)], Y_t[Symbol(model_name)])
        return obs_tmp
    end
    return obs
end

@doc raw"
Generate observations from a stack of observation models. Maps `Y_t` to a `NamedTuple` of the same length as `y_t` assuming a 1 to many mapping.

# Arguments
- `obs_model::StackObservationModels`: The stack of observation models.
- `y_t::NamedTuple`: The observed values.
- `Y_t::AbstractVector`: The expected values.
"
@model function EpiAwareBase.generate_observations(
        obs_model::StackObservationModels, y_t::NamedTuple, Y_t::AbstractVector)
    tuple_Y_t = NamedTuple{keys(y_t)}(fill(Y_t, length(y_t)))
    @submodel obs = generate_observations(obs_model, y_t, tuple_Y_t)
    return obs
end
