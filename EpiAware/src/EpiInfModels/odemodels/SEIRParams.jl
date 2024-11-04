"""
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

"""
Internal function for the Jacobian of the basic SEIR model written in density/per-capita
form. The function is used to define the ODE problem for the SEIR model. The Jacobian
is used to speed up the solution of the ODE problem when using a stiff solver.
"""
function _seir_jac(J, u, p, t)
    S, E, I, R = u
    β, α, γ = p
    J[1, 1] = -β * I
    J[1, 2] = 0
    J[1, 3] = -β * S
    J[1, 4] = 0
    J[2, 1] = β * I
    J[2, 2] = -α
    J[2, 3] = β * S
    J[2, 4] = 0
    J[3, 1] = 0
    J[3, 2] = α
    J[3, 3] = -γ
    J[3, 4] = 0
    J[4, 1] = 0
    J[4, 2] = 0
    J[4, 3] = γ
    J[4, 4] = 0
    nothing
end

"""
Internal function for the ODE function of the basic SIR model written in density/per-capita
form. The function passes vector field and Jacobian functions to the ODE solver.
"""
const _seir_function = ODEFunction(_seir_vf; jac = _seir_jac)

"""
A structure representing the SIR (Susceptible-Infectious-Recovered) model and priors for the
infectiousness and recovery rate parameters.

# Constructors
- `SEIRParams(; tspan, infectiousness_prior::Distribution, incubation_rate_prior::Distribution,
    recovery_rate_prior::Distribution, initial_prop_infected_prior::Distribution)` :
Construct a `SEIRParams` object with the specified time span for ODE solving, infectiousness
prior, incubation rate prior and recovery rate prior.
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
    return SIRParams{
        typeof(sir_prob), typeof(infectiousness_prior), typeof(incubation_rate_prior),
        typeof(recovery_rate_prior), typeof(initial_prop_infected_prior)}(
        seir_prob, infectiousness_prior, recovery_rate_prior)
end

@model function EpiAwareBase.generate_parameters(params::SIRParams, Z_t)
    β ~ params.infectiousness_prior
    α ~ params.incubation_rate_prior
    γ ~ params.recovery_rate_prior
    I₀ ~ params.initial_prop_infected_prior

    u0 = [1.0 - I₀, I₀ * γ / (α + γ), I₀ * α / (α + γ), 0.0]
    p = [β, α, γ]
    return (u0, p)
end
