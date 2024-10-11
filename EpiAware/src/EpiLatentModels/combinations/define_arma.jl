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

```@example
using EpiAware, Distributions

ARMA = define_arma(;
 θ = [truncated(Normal(0.0, 0.02), -1, 1)],
 damp = [truncated(Normal(0.0, 0.02), 0, 1)]
)
arma = generate_latent(ARMA, 10)
arma()
```
"""
function define_arma(;
        init = [Normal()],
        damp = [truncated(Normal(0.0, 0.05), 0, 1)],
        θ = [truncated(Normal(0.0, 0.05), -1, 1)],
        ϵ_t = HierarchicalNormal())
    ma = MA(; θ_priors = θ, ϵ_t = ϵ_t)
    ar = AR(; damp_priors = damp, init_priors = init, ϵ_t = ma)
    return ar
end
