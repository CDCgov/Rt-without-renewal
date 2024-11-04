"""
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

"""
Internal function for the Jacobian of the basic SIR model written in density/per-capita
form. The function is used to define the ODE problem for the SIR model. The Jacobian
is used to speed up the solution of the ODE problem when using a stiff solver.
"""
function _sir_jac(J, u, p, t)
    S, I, R = u
    β, γ = p
    J[1, 1] = -β * I
    J[1, 2] = -β * S
    J[1, 3] = 0
    J[2, 1] = β * I
    J[2, 2] = β * S - γ
    J[2, 3] = 0
    J[3, 1] = 0
    J[3, 2] = γ
    J[3, 3] = 0
    nothing
end

"""
Internal function for the ODE function of the basic SIR model written in density/per-capita
form. The function passes vector field and Jacobian functions to the ODE solver.
"""
const _sir_function = ODEFunction(_sir_vf; jac = _sir_jac)

"""
A structure representing the SIR (Susceptible-Infectious-Recovered) model and priors for the
infectiousness and recovery rate parameters.

# Constructors
- `SIRParams(; tspan,
    infectiousness_prior::Distribution,
    recovery_rate_prior::Distribution,
    initial_prop_infected_prior::Distribution)` :
Construct an `SIRParams` object with the specified time span for ODE solving, infectiousness
prior, and recovery rate prior.
"""
struct SIRParams{P <: ODEProblem, D <: Sampleable, E <: Sampleable, F <: Sampleable} <:
       AbstractTuringParamModel
    "The ODE problem instance for the SIR model."
    prob::P
    "Prior distribution for the infectiousness parameter."
    infectiousness_prior::D
    "Prior distribution for the recovery rate parameter."
    recovery_rate_prior::E
    "Prior distribution for initial proportion of the population that is infected."
    initial_prop_infected_prior::F
end

function SIRParams(;
        tspan, infectiousness_prior::Distribution, recovery_rate_prior::Distribution,
        initial_prop_infected_prior::Distribution)
    sir_prob = ODEProblem(_sir_function, [0.99, 0.01, 0.0], tspan)
    return SIRParams{
        typeof(sir_prob), typeof(infectiousness_prior), typeof(recovery_rate_prior),
        typeof(initial_prop_infected_prior)}(
        sir_prob, infectiousness_prior, recovery_rate_prior)
end

@model function EpiAwareBase.generate_parameters(params::SIRParams, Z_t)
    β ~ params.infectiousness_prior
    γ ~ params.recovery_rate_prior
    I₀ ~ params.initial_prop_infected_prior
    u0 = [1.0 - I₀, I₀, 0.0]
    p = [β, γ]
    return (u0, p)
end
