@doc raw"
Defines an inference/generative modelling problem for case data.

`EpiProblem` wraps the underlying components of an epidemiological model:
- `epi_model`: An epidemiological model for unobserved infections.
- `latent_model`: A latent model for underlying latent process.
- `observation_model`: An observation model for observed cases.

Along with a `tspan` tuple for the time span of the case data.
"
@kwdef struct EpiProblem{
    E <: AbstractEpiModel, L <: AbstractLatentModel, O <: AbstractObservationModel} <:
              AbstractEpiProblem
    "Epidemiological model for unobserved infections."
    epi_model::E
    "Latent model for underlying latent process."
    latent_model::L
    "Observation model for observed cases."
    observation_model::O
    "Time span for either inference or generative modelling of case time series."
    tspan::Tuple{Int, Int}
end

@doc raw"
Generate an epi-aware model given an `EpiProblem` and data.

# Arguments
- `epiproblem`: Epi problem specification.
- `data`: Observed data.

# Returns
A tuple containing the generated quantities of the epi-aware model.
"
function EpiAwareBase.generate_epiaware(epiproblem::EpiProblem, data)
    y_t = data.y_t
    time_steps = epiproblem.tspan[end] - epiproblem.tspan[1] + 1

    generate_epiaware(y_t, time_steps, epiproblem.epi_model;
        epiproblem.latent_model, epiproblem.observation_model)
end

"""
Run the `EpiAware` algorithm to estimate the parameters of an epidemiological model.

# Arguments
- `epiproblem::EpiProblem`: An `EpiProblem` object specifying the epidemiological problem.
- `method::EpiMethod`: An `EpiMethod` object specifying the inference method.
- `data`: The observed data used for inference.

# Keyword Arguments
- `fix_parameters::NamedTuple`: A `NamedTuple` of fixed parameters for the model.
- `condition_parameters::NamedTuple`: A `NamedTuple` of conditioned parameters for the
    model.
- `kwargs...`: Additional keyword arguments passed to the inference methods.

# Returns
- A `NamedTuple` with a `samples` field which is the output of applying methods and a
    `model` field with the model used. Optionally, a `gens` field with the
        generated quantities from the model if that makes sense with the inference method.
"""
function _apply_method(epiproblem::EpiProblem,
        method::AbstractEpiMethod, data;
        fix_parameters::NamedTuple = NamedTuple(),
        condition_parameters::NamedTuple = NamedTuple(),
        kwargs...)

    # Create the model
    model = generate_epiaware(epiproblem, data)

    cond_model = condition_model(model, fix_parameters, condition_parameters)

    # Run the inference and return observables
    return _apply_method(cond_model, method; kwargs...)
end
