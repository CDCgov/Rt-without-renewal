@doc raw"""
Internal function for the vector field of a basic SIR model written in density/per-capita
form. The function is used to define the ODE problem for the SIR model.
"""
function _sir_vf(du, u, p, t)
    S, I, R = u
    β, γ = p
    du[1] = -β * S * I
    du[2] = β * S * I - γ * I
    du[3] = γ * I
    return nothing
end

@doc raw"""
Sparse Jacobian matrix prototype for the basic SIR model written in density/per-capita form.
"""
const _sir_jac_prototype = sparse([1.0 1.0 0.0;
                                   1.0 1.0 0.0;
                                   0.0 1.0 0.0])

@doc raw"""
Internal function for the Jacobian of the basic SIR model written in density/per-capita
form. The function is used to define the ODE problem for the SIR model. The Jacobian
is used to speed up the solution of the ODE problem when using a stiff solver.
"""
function _sir_jac(J, u, p, t)
    S, I, R = u
    β, γ = p
    J[1, 1] = -β * I
    J[1, 2] = -β * S
    J[2, 1] = β * I
    J[2, 2] = β * S - γ
    J[3, 2] = γ
    nothing
end

@doc raw"""
Internal function for the ODE function of the basic SIR model written in density/per-capita
form. The function passes vector field and Jacobian functions to the ODE solver.
"""
_sir_function = ODEFunction(_sir_vf; jac = _sir_jac)

@doc raw"""
A structure representing the SIR (Susceptible-Infectious-Recovered) model and priors for the
infectiousness and recovery rate parameters.

# Constructors
- `SIRParams(; tspan,
    infectiousness::Distribution,
    recovery_rate::Distribution,
    initial_prop_infected::Distribution)` :
Construct an `SIRParams` object with the specified time span for ODE solving, infectiousness
prior, and recovery rate prior.

## SIR model

```math
\begin{aligned}
\frac{dS}{dt} &= -\beta SI \\
\frac{dI}{dt} &= \beta SI - \gamma I \\
\frac{dR}{dt} &= \gamma I
\end{aligned}
```
Where `S` is the proportion of the population that is susceptible, `I` is the proportion of the
population that is infected and `R` is the proportion of the population that is recovered. The
parameters are the infectiousness `β` and the recovery rate `γ`.

# Example

```julia
 using EpiAware, OrdinaryDiffEq, Distributions

# Create an instance of SIRParams
sirparams = SIRParams(
    tspan = (0.0, 30.0),
    infectiousness = LogNormal(log(0.3), 0.05),
    recovery_rate = LogNormal(log(0.1), 0.05),
    initial_prop_infected = Beta(1, 99)
)
```
"""
struct SIRParams{P <: ODEProblem, D <: Sampleable, E <: Sampleable, F <: Sampleable} <:
       AbstractTuringLatentModel
    "The ODE problem instance for the SIR model."
    prob::P
    "Prior distribution for the infectiousness parameter."
    infectiousness::D
    "Prior distribution for the recovery rate parameter."
    recovery_rate::E
    "Prior distribution for initial proportion of the population that is infected."
    initial_prop_infected::F
end

function SIRParams(;
        tspan, infectiousness::Distribution, recovery_rate::Distribution,
        initial_prop_infected::Distribution)
    sir_prob = ODEProblem(_sir_function, [0.99, 0.01, 0.0], tspan)
    return SIRParams{typeof(sir_prob), typeof(infectiousness),
        typeof(recovery_rate), typeof(initial_prop_infected)}(
        sir_prob, infectiousness, recovery_rate, initial_prop_infected)
end

@doc raw"""
Generates the initial parameters and initial conditions for the basic SIR model.

## SIR model

```math
\begin{aligned}
\frac{dS}{dt} &= -\beta SI \\
\frac{dI}{dt} &= \beta SI - \gamma I \\
\frac{dR}{dt} &= \gamma I
\end{aligned}
```
Where `S` is the proportion of the population that is susceptible, `I` is the proportion of the
population that is infected and `R` is the proportion of the population that is recovered. The
parameters are the infectiousness `β` and the recovery rate `γ`.

# Example

```julia
using EpiAware, OrdinaryDiffEq, Distributions

# Create an instance of SIRParams
sirparams = SIRParams(
    tspan = (0.0, 30.0),
    infectiousness = LogNormal(log(0.3), 0.05),
    recovery_rate = LogNormal(log(0.1), 0.05),
    initial_prop_infected = Beta(1, 99)
)

sirparam_mdl = generate_latent(sirparams, nothing)

#sample the parameters of SIR model
sampled_params = rand(sirparam_mdl)
```

# Returns
- A tuple `(u0, p)` where:
  - `u0`: A vector representing the initial state of the system `[S₀, I₀, R₀]` where `S₀` is the initial proportion of susceptible individuals, `I₀` is the initial proportion of infected individuals, and `R₀` is the initial proportion of recovered individuals.
  - `p`: A vector containing the parameters `[β, γ]` where `β` is the infectiousness rate and `γ` is the recovery rate.
"""
@model function EpiAwareBase.generate_latent(params::SIRParams, Z_t)
    β ~ params.infectiousness
    γ ~ params.recovery_rate
    I₀ ~ params.initial_prop_infected
    u0 = [1.0 - I₀, I₀, 0.0]
    p = [β, γ]
    return (u0, p)
end
