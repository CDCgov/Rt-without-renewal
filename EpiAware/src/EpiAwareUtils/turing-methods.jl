@doc raw"
Generate an epi-aware model given the observed data and model specifications.

# Arguments
- `y_t`: Observed data.
- `time_steps`: Number of time steps.
- `epi_model`: A Turing Epi model specification.
- `latent_model`: A Turing Latent model specification.
- `observation_model`: A Turing Observation model specification.

# Returns
A `DynamicPPPL.Model` object.
"
@model function EpiAwareBase.generate_epiaware(
        y_t, time_steps, epi_model::AbstractTuringEpiModel;
        latent_model::AbstractTuringLatentModel, observation_model::AbstractTuringObservationModel)
    # Latent process
    @submodel Z_t, latent_model_aux = generate_latent(latent_model, time_steps)

    # Transform into infections
    @submodel I_t = generate_latent_infs(epi_model, Z_t)

    # Predictive distribution of ascertained cases
    @submodel generated_y_t, generated_y_t_aux = generate_observations(
        observation_model, y_t, I_t)

    # Generate quantities
    return (;
        generated_y_t, I_t, Z_t, process_aux = merge(latent_model_aux, generated_y_t_aux))
end

"""
Apply the condition to the model by fixing the specified parameters and conditioning on the others.

# Arguments
- `model::Model`: The model to be conditioned.
- `fix_parameters::NamedTuple`: The parameters to be fixed.
- `condition_parameters::NamedTuple`: The parameters to be conditioned on.

# Returns
- `_model`: The conditioned model.
"""
function EpiAwareBase.condition_model(
        model::Model, fix_parameters::NamedTuple, condition_parameters::NamedTuple)
    _model = fix(model, fix_parameters)
    _model = condition(_model, condition_parameters)
    return _model
end

@doc raw"
Generate observables from a given model and solution including generated quantities.
"
function EpiAwareBase.generated_observables(
        model::Model, solution::Union{Chains, NamedTuple})
    gens = generated_quantities(model, solution)
    (samples = solution, gens = gens, model = model)
end

@doc raw"
Apply steps defined by an `EpiMethod` to a model object.


This function applies the steps defined by an `EpiMethod` object to a `Model` object. It iterates over the pre-sampler steps defined in the `EpiMethod` object and recursively applies them to the model. Finally, it applies the sampler step defined in the `EpiMethod` object to the model. The `prev_result` argument is used to pass the result obtained from applying the previous steps, if any.

# Arguments
- `method::EpiMethod`: The `EpiMethod` object containing the steps to be applied.
- `model::Model`: The model object to which the steps will be applied.
- `prev_result`: The previous result obtained from applying the steps. Defaults to `nothing`.
- `kwargs...`: Additional keyword arguments that can be passed to the steps.

# Returns
- `prev_result`: The result obtained after applying the steps.
"
function EpiAwareBase.apply_method(
        model::Model, method::EpiMethod, prev_result; kwargs...)
    for pre_sampler in method.pre_sampler_steps
        prev_result = apply_method(model, pre_sampler, prev_result; kwargs...)
    end
    apply_method(model, method.sampler, prev_result; kwargs...)
end

function EpiAwareBase.apply_method(
        model::Model, method::EpiMethod; kwargs...)
    apply_method(model, method, nothing; kwargs...)
end

@doc raw"
Apply the inference/generative method `method` to the `Model` object `mdl`.

# Arguments
- `model::AbstractEpiModel`: The model to apply the method to.
- `method::AbstractEpiMethod`: The epidemiological method to apply.
- `prev_result`: The previous result of the method.
- `kwargs`: Additional keyword arguments passed to the method.

# Returns
- `nothing`: If no concrete implementation is defined for the given `method`.
"
function EpiAwareBase.apply_method(model::Model, method::AbstractEpiMethod,
        prev_result = nothing; kwargs...)
    @info "No concrete implementation for `apply_method` is defined."
    return nothing
end
