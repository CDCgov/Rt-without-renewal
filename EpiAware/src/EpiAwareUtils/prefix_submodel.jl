@doc raw"
Generate a submodel with an optional prefix. A lightweight wrapper around the `@submodel` macro from DynamicPPL.jl.

# Arguments

- `model::AbstractModel`: The model to be used.
- `fn::Function`: The Turing @model function to be applied to the model.
- `prefix::String`: The prefix to be used. If the prefix is an empty string, the submodel is created without a prefix.

# Returns

- `submodel`: The returns from the submodel are passed through.

# Examples

```@example
using EpiAware, DynamicPPL
submodel = prefix_submodel(FixedIntercept(0.1), generate_latent, string(1), 2)
```

We can now draw a sample from the submodel.

```julia
rand(submodel)
```
"
@model function prefix_submodel(
        model::AbstractModel, fn::Function, prefix::String, kwargs...)
    if prefix == ""
        @submodel submodel = fn(model, kwargs...)
    else
        @submodel prefix=eval(prefix) submodel=fn(model, kwargs...)
    end
    return submodel
end
