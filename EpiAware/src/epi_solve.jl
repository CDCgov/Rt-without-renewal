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
function epi_solve(epiproblem::EpiProblem, method::AbstractEpiMethod, data;
        fix_parameters::NamedTuple = NamedTuple(),
        condition_parameters::NamedTuple = NamedTuple(),
        kwargs...)

    # Create the model
    mdl = make_epi_aware(epiproblem, data)

    # Fix and condition the model
    _mdl = fix(mdl, fix_parameters)
    _mdl = condition(_mdl, condition_parameters)

    # Run the inference and return observables
    epi_solve(_mdl, method; kwargs...)
end

function epi_solve(mdl::DynamicPPL.Model, method::AbstractEpiMethod; kwargs...)
    # Run the inference
    sol = _apply_method(method, mdl, nothing; kwargs...)
    obs = generate_observables(mdl, sol)
    merge(obs, (model = mdl,))
end

"""
Generate observables from a given model and solution default to just returning the solution.
"""
function generate_observables(mdl::DynamicPPL.Model, sol)
    (samples = sol,)
end

"""
Generate observables from a given model and solution including generated quantities.
"""
function generate_observables(
        mdl::DynamicPPL.Model, sol::Union{MCMCChains.Chains, NamedTuple})
    gens = Turing.generated_quantities(mdl, sol)
    (samples = sol, gens = gens)
end
