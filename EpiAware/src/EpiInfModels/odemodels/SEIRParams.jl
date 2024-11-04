@doc raw"""
Internal function for the vector field of a basic SEIR model written in density/per-capita
form. The function is used to define the ODE problem for the SIR model.
"""
function _seir_vf(du, u, p, t)
    S, E, I, R = u
    β, α, γ = p
    du[1] = -β * S * I
    du[2] = β * S * I - α * E
    du[3] = α * E - γ * I
    du[4] = γ * I
    return nothing
end

@doc raw"""
Sparse Jacobian matrix prototype for the basic SEIR model written in density/per-capita form.
"""
const _seir_jac_prototype = sparse([1.0 0.0 1.0 0.0;
                                    1.0 1.0 1.0 0.0;
                                    0.0 1.0 1.0 0.0;
                                    0.0 0.0 1.0 0.0])

@doc raw"""
Internal function for the Jacobian of the basic SEIR model written in density/per-capita
form. The function is used to define the ODE problem for the SEIR model. The Jacobian
is used to speed up the solution of the ODE problem when using a stiff solver.
"""
function _seir_jac(J, u, p, t)
    S, E, I, R = u
    β, α, γ = p
    J[1, 1] = -β * I
    J[1, 3] = -β * S
    J[2, 1] = β * I
    J[2, 2] = -α
    J[2, 3] = β * S
    J[3, 2] = α
    J[3, 3] = -γ
    J[4, 3] = γ
    nothing
end

@doc raw"""
Internal function for the ODE function of the basic SIR model written in density/per-capita
form. The function passes vector field and Jacobian functions to the ODE solver.
"""
_seir_function = ODEFunction(_seir_vf; jac = _seir_jac)

@doc raw"""
A structure representing the SEIR (Susceptible-Exposed-Infectious-Recovered) model and priors for the
infectiousness and recovery rate parameters.

# Constructors
- `SEIRParams(; tspan, infectiousness_prior::Distribution, incubation_rate_prior::Distribution,
    recovery_rate_prior::Distribution, initial_prop_infected_prior::Distribution)` :
Construct a `SEIRParams` object with the specified time span for ODE solving, infectiousness
prior, incubation rate prior and recovery rate prior.

## SEIR model

```math
\begin{aligned}
\frac{dS}{dt} &= -\beta SI \\
\frac{dE}{dt} &= \beta SI - \alpha E \\
\frac{dI}{dt} &= \alpha E - \gamma I \\
\frac{dR}{dt} &= \gamma I
\end{aligned}
```
Where `S` is the proportion of the population that is susceptible, `E` is the proportion of the
population that is exposed, `I` is the proportion of the population that is infected and `R` is
the proportion of the population that is recovered. The parameters are the infectiousness `β`,
the incubation rate `α` and the recovery rate `γ`.

```julia
using EpiAware, OrdinaryDiffEq, Distributions
# Define the time span for the ODE problem
tspan = (0.0, 30.0)

# Define prior distributions
infectiousness_prior = LogNormal(log(0.3), 0.05)
incubation_rate_prior = LogNormal(log(0.1), 0.05)
recovery_rate_prior = LogNormal(log(0.1), 0.05)
initial_prop_infected_prior = Beta(1, 99)

# Create an instance of SIRParams
seirparams = SEIRParams(
    tspan = tspan,
    infectiousness_prior = infectiousness_prior,
    incubation_rate_prior = incubation_rate_prior,
    recovery_rate_prior = recovery_rate_prior,
    initial_prop_infected_prior = initial_prop_infected_prior
)
```
"""
struct SEIRParams{
    P <: ODEProblem, D <: Sampleable, E <: Sampleable, F <: Sampleable, G <: Sampleable} <:
       AbstractTuringParamModel
    "The ODE problem instance for the SIR model."
    prob::P
    "Prior distribution for the infectiousness parameter."
    infectiousness_prior::D
    "Prior distribution for the incubation rate parameter."
    incubation_rate_prior::E
    "Prior distribution for the recovery rate parameter."
    recovery_rate_prior::F
    "Prior distribution for initial proportion of the population that is infected."
    initial_prop_infected_prior::G
end

function SEIRParams(;
        tspan, infectiousness_prior::Distribution, incubation_rate_prior::Distribution,
        recovery_rate_prior::Distribution, initial_prop_infected_prior::Distribution)
    seir_prob = ODEProblem(_seir_function, [0.99, 0.05, 0.05, 0.0], tspan)
    return SEIRParams{
        typeof(seir_prob), typeof(infectiousness_prior), typeof(incubation_rate_prior),
        typeof(recovery_rate_prior), typeof(initial_prop_infected_prior)}(
        seir_prob, infectiousness_prior, incubation_rate_prior,
        recovery_rate_prior, initial_prop_infected_prior)
end

@model function EpiAwareBase.generate_parameters(params::SEIRParams, Z_t)
    β ~ params.infectiousness_prior
    α ~ params.incubation_rate_prior
    γ ~ params.recovery_rate_prior
    I₀ ~ params.initial_prop_infected_prior

    u0 = [1.0 - I₀, I₀ * γ / (α + γ), I₀ * α / (α + γ), 0.0]
    p = [β, α, γ]
    return (u0, p)
end
