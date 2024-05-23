@doc raw"
Model unobserved/latent infections as a transformation on a sampled latent process.

## Mathematical specification

If ``Z_t`` is a realisation of the latent model, then the unobserved/latent infections are
given by

```math
I_t = g(Z_t).
```

where ``g`` is a transformation function.

`DirectInfections` are constructed by passing a generation time distribution `generation_time` and a transformation function `transformation` for the latent process. The default `generation_time` is `FixedDelay([1.0])` and the default `transformation` is `exp`.

## Constructors

- `DirectInfections(latent_model, generation_time, transformation)`.
- `DirectInfections(; latent_model = Intercept(), generation_time = FixedDelay(), transformation = exp)`.

## Example usage with `generate_infections`

`generate_infections` can be used to construct a `Turing` model for the latent
infections conditional on the sample path of a latent process.

First, we construct a `DirectInfections` struct.

```julia
using Distributions, Turing, EpiAware
gen_time = FixedDelay([0.2, 0.4, 0.4])
latent_model = CombineLatentModel([Intercept(), RandomWalk()])

# Create a DirectInfections model
direct_inf_model = DirectInfections(
    generation_time = gen_time, latent_model = latent_model
)
```

Then, we can use `generate_infections` to construct a Turing model for the
unobserved infection generation model set by the type of `direct_inf_model`.

```julia
latent_inf = generate_infections(direct_inf_model, 10)
```

Now we can use the `Turing` PPL API to sample underlying parameters and
generate the unobserved infections.

```julia
rand(latent_inf)
latent_inf.I_t
```
"
@kwdef struct DirectInfections{M::AbstractTuringLatentModel, D::AbstractTuringDelayModel, F::Function} <: AbstractTuringEpiModel
    "`Epidata` object."
    latent_model::M = Intercept()
    generation_time::D = FixedDelay()
    transformation::F = exp
end

@doc raw"
Implement the `generate_infections` function for the `DirectInfections` model.

# Arguments

- `epi_model::DirectInfections`: A `DirectInfections` model.
- `n::Int`: The number of samples to generate.

# Returns

- `inf`: A `Vector` of unobserved/latent infections.
- `inf_aux`: A `NamedTuple` of auxiliary variables.
```
"
@model function EpiAwareBase.generate_infections(epi_model::DirectInfections, n)
    @submodel untrans_inf, inf_aux = generate_latent(epi_model.latent_model, n)
    inf = epi_model.transformation.(untrans_inf)
    return inf, (; inf_aux)
end
