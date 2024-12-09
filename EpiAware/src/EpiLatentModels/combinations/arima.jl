@doc raw"""
Define an ARIMA model by wrapping `define_arma` and applying differencing via `DiffLatentModel`.

# Arguments
- `ar_init`: Prior distribution for AR initial conditions.
  A vector of distributions.
- `diff_init`: Prior distribution for differencing initial conditions.
  A vector of distributions.
- `θ`: Prior distribution for MA coefficients.
  A vector of distributions.
- `damp`: Prior distribution for AR damping coefficients.
  A vector of distributions.
- `ϵ_t`: Distribution of the error term.
  Default is `HierarchicalNormal()`.

# Returns
An ARIMA model consisting of AR and MA components with differencing applied.

# Example

```jldoctest ARIMA; output = false
using EpiAware, Distributions

ARIMA = arima()
arima_model = generate_latent(ARIMA, 10)
arima_model()
nothing
# output

```
"""
function arima(;
        ar_init = [Normal()],
        diff_init = [Normal()],
        damp = [truncated(Normal(0.0, 0.05), 0, 1)],
        θ = [truncated(Normal(0.0, 0.05), -1, 1)],
        ϵ_t = HierarchicalNormal()
)
    arma_model = arma(; init = ar_init, damp = damp, θ = θ, ϵ_t = ϵ_t)
    arima_model = DiffLatentModel(; model = arma_model, init_priors = diff_init)
    return arima_model
end
