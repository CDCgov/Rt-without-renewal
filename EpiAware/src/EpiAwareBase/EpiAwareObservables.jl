@doc raw"
The `EpiAwareObservables` struct represents the observables used in the EpiAware model.

# Fields
- `model`: The model used for the observables.
- `data`: The data used for the observables.
- `samples`: Samples from the posterior distribution.
- `generated`: The generated observables.
"
struct EpiAwareObservables
    model::Any
    data::Any
    samples::Any
    generated::Any
end

@doc raw"
Generate observables from a given model and solution and return them as a
`EpiAwareObservables` struct.

# Arguments
- `model`: The model used for generating observables.
- `data`: The data used for generating observables.
- `solution`: The solution used for generating observables.

# Returns
An instance of `EpiAwareObservables` struct with the provided model, data,
solution, and the generated observables if specified
"
function generated_observables(model, data, solution)
    return EpiAwareObservables(model, data, solution, missing)
end
