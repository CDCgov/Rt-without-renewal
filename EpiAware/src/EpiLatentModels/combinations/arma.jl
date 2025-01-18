@doc raw"""
Define an ARMA model using AR and MA components.

# Arguments
- `init`: Prior distribution for AR initial conditions.
  A vector of distributions.
- `θ`: Prior distribution for MA coefficients.
  A vector of distributions.
- `damp`: Prior distribution for AR damping coefficients.
  A vector of distributions.
- `ϵ_t`: Distribution of the error term.
  Default is `HierarchicalNormal()`.

# Returns
An AR model with an MA model as its error term, effectively creating an ARMA model.

# Example

```jldoctest ARMA; output = false
using EpiAware, Distributions

ARMA = arma(;
 θ = [truncated(Normal(0.0, 0.02), -1, 1)],
 damp = [truncated(Normal(0.0, 0.02), 0, 1)]
)
arma_model = generate_latent(ARMA, 10)
arma_model()
nothing
┌ Warning: `@submodel model` and `@submodel prefix=... model` are deprecated; see `to_submodel` for the up-to-date syntax.
│   caller = ip:0x0
└ @ Core :-1
# output
```
"""
function arma(;
        init = [Normal()],
        damp = [truncated(Normal(0.0, 0.05), 0, 1)],
        θ = [truncated(Normal(0.0, 0.05), -1, 1)],
        ϵ_t = HierarchicalNormal())
    ma = MA(; θ_priors = θ, ϵ_t = ϵ_t)
    ar = AR(; damp_priors = damp, init_priors = init, ϵ_t = ma)
    return ar
end
