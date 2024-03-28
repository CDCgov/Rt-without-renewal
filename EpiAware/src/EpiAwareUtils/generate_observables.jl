@doc raw"
Generate observables from a given model and solution including generated quantities.
"
function EpiAwareBase.generate_observables(
        model::Model, solution::Union{Chains, NamedTuple})
    gens = generated_quantities(model, solution)
    (samples = solution, gens = gens, model = model)
end
