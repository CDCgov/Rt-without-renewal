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
function apply_method(epiproblem::EpiProblem, method::AbstractEpiMethod, data;
        fix_parameters::NamedTuple = NamedTuple(),
        condition_parameters::NamedTuple = NamedTuple(),
        kwargs...)

    # Create the model
    model = make_epi_aware(epiproblem, data)

    # Fix and condition the model
    _model = fix(model, fix_parameters)
    _model = condition(_model, condition_parameters)

    # Run the inference and return observables
    apply_method(_model, method; kwargs...)
end

function apply_method(momdel::DynamicPPL.Model, method::AbstractEpiMethod; kwargs...)
    # Run the inference
    sol = _apply_method(method, mdl, nothing; kwargs...)
    obs = generate_observables(mdl, sol)
    merge(obs, (model = mdl,))
end

"""
Generate observables from a given model and solution including generated quantities.
"""
function generate_observables(
        model::DynamicPPL.Model, solution::Union{MCMCChains.Chains, NamedTuple})
    gens = Turing.generated_quantities(model, solution)
    (samples = solution, gens = gens)
end
