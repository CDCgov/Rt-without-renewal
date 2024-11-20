@doc raw"
A null model struct. This struct is used to indicate that no latent variables are to be generated.
"
struct Null <: AbstractTuringLatentModel end

@doc raw"
Generates `nothing` as latent variables for the given `latent_model` of type `Null`.

# Example
```jldoctest
using EpiAware
null = Null()
null_mdl = generate_latent(null, 10)
isnothing(null_mdl())

# Output

true

```
"
@model function EpiAwareBase.generate_latent(latent_model::Null, n)
    return nothing
end
