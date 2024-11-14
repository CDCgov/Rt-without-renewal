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
- `SEIRParams(; tspan, infectiousness::Distribution, incubation_rate::Distribution,
    recovery_rate::Distribution, initial_prop_infected::Distribution)` :
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

# Create an instance of SIRParams
seirparams = SEIRParams(
    tspan = (0.0, 30.0),
    infectiousness = LogNormal(log(0.3), 0.05),
    incubation_rate = LogNormal(log(0.1), 0.05),
    recovery_rate = LogNormal(log(0.1), 0.05),
    initial_prop_infected = Beta(1, 99)
)
```
"""
struct SEIRParams{
    P <: ODEProblem, D <: Sampleable, E <: Sampleable, F <: Sampleable, G <: Sampleable} <:
       AbstractTuringLatentModel
    "The ODE problem instance for the SIR model."
    prob::P
    "Prior distribution for the infectiousness parameter."
    infectiousness::D
    "Prior distribution for the incubation rate parameter."
    incubation_rate::E
    "Prior distribution for the recovery rate parameter."
    recovery_rate::F
    "Prior distribution for initial proportion of the population that is infected."
    initial_prop_infected::G
end

function SEIRParams(;
        tspan, infectiousness::Distribution, incubation_rate::Distribution,
        recovery_rate::Distribution, initial_prop_infected::Distribution)
    seir_prob = ODEProblem(_seir_function, [0.99, 0.05, 0.05, 0.0], tspan)
    return SEIRParams{
        typeof(seir_prob), typeof(infectiousness), typeof(incubation_rate),
        typeof(recovery_rate), typeof(initial_prop_infected)}(
        seir_prob, infectiousness, incubation_rate,
        recovery_rate, initial_prop_infected)
end

@doc raw"""
Generates the initial parameters and initial conditions for the basic SEIR model.

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

## Initial conditions

For this version of the SEIR model we sample the initial proportion of the population that is
_infected_ (exposed or infectious). The proportion of the infected group that is exposed is
`α / (α + γ)` and the proportion of the infected group that is infectious is `γ / (α + γ)`. The
reason for this is that these are the equilibrium proportions in a constant incidence environment.

# Example

```julia
using EpiAware, OrdinaryDiffEq, Distributions

# Create an instance of SIRParams
seirparams = SEIRParams(
    tspan = (0.0, 30.0),
    infectiousness = LogNormal(log(0.3), 0.05),
    incubation_rate = LogNormal(log(0.1), 0.05),
    recovery_rate = LogNormal(log(0.1), 0.05),
    initial_prop_infected = Beta(1, 99)
)

seirparam_mdl = generate_latent(seirparams, nothing)

# Sample the parameters of SEIR model
sampled_params = rand(seirparam_mdl)
```

# Returns
  A tuple `(u0, p)` where:
  - `u0`: A vector representing the initial state of the system `[S₀, E₀, I₀, R₀]` where `S₀`
  is the initial proportion of susceptible individuals, `E₀` is the initial proportion of exposed
  individuals,`I₀` is the initial proportion of infected individuals, and `R₀` is the initial
  proportion of recovered individuals.
  - `p`: A vector containing the parameters `[β, α, γ]` where `β` is the infectiousness rate,
  `α` is the incubation rate, and `γ` is the recovery rate.
"""
@model function EpiAwareBase.generate_latent(params::SEIRParams, n)
    β ~ params.infectiousness
    α ~ params.incubation_rate
    γ ~ params.recovery_rate
    initial_infs ~ params.initial_prop_infected

    u0 = [1.0 - initial_infs, initial_infs * γ / (α + γ), initial_infs * α / (α + γ), 0.0]
    p = [β, α, γ]
    return (u0, p)
end
