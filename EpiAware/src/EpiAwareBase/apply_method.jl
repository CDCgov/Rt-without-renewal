@doc raw"
Wrap the `_apply_method` function by calling it with the given `model`, `method`, `data`, and optional keyword arguments (`kwargs`).
The resulting solution is then passed to the `generated_observables` function, along with the `model` and input `data`, to compute the generated observables.

# Arguments
- `model`: The model to apply the method to.
- `method`: The method to apply to the model.
- `data`: The data to pass to the `apply_method` function.
- `kwargs`: Optional keyword arguments to pass to the `apply_method` function.

# Returns
The generated observables computed from the solution.
"
function apply_method(model, method, data; kwargs...)
    solution = _apply_method(model, method, data; kwargs...)
    return generated_observables(model, data, solution)
end

@doc raw"
Calls `wrap_apply_method` setting the data argument to `nothing`.
"
function apply_method(model, method; kwargs...)
    solution = _apply_method(model, method, nothing; kwargs...)
    return generated_observables(model, nothing, solution)
end
