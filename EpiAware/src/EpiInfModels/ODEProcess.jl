@doc raw"""
A structure representing an infection process modeled by an Ordinary Differential Equation (ODE).
At a high level, an `ODEProcess` struct object combines:

- An `AbstractTuringParamModel` which defines the ODE model in terms of `OrdinaryDiffEq` types,
     the parameters of the ODE model and a method to generate the parameters.
- A technique for solving and interpreting the ODE model using the `SciML` ecosystem. This includes
    the solver used in the ODE solution, keyword arguments to send to the solver and a function
    to map the `ODESolution` solution object to latent infections.

# Constructors
- `ODEProcess(prob::ODEProblem; ts, solver, sol2infs)`: Create an `ODEProcess`
object with the ODE problem `prob`, time points `ts`, solver `solver`, and function `sol2infs`.

# Predefined ODE models
Two basic ODE models are provided in the `EpiAware` package: `SIRParams` and `SEIRParams`.
In both cases these are defined in terms of the proportions of the population in each compartment
of the SIR and SEIR models respectively.

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

# Usage example with `ODEProcess` and predefined SIR model

In this example we define an `ODEProcess` object using the predefined `SIRParams` model from
above. We then generate latent infections using the `generate_latent_infs` function, and refit
the model using a `Turing` model.

We assume that the latent infections are observed with a Poisson likelihood around their
ODE model prediction. The population size is `N = 1000`, which we put into the `sol2infs` function,
which maps the ODE solution to the number of infections. Recall that the `EpiAware` default SIR
implementation assumes the model is in density/proportion form. Also, note that since the `sol2infs`
function is a link function that maps the ODE solution to the expected number of infections we also
apply the `LogExpFunctions.logaddexp` function to ensure that the expected number of infections is non-negative.
The `logaddexp` function generalises the `softplus` function, `logaddexp(1, x) == softplus(x)`.

First, we define the `ODEProcess` object which combines the SIR model with the `sol2infs` link
function and the solver options.

```julia
using Turing, LogExpFunctions
N = 1000.0

sir_process = ODEProcess(
    params = sirparams,
    sol2infs = sol -> N .* logaddexp.(0.001, sol[2, :]),
    solver_options = Dict(:verbose => false, :saveat => 1.0)
)
```

Next, we create a `Turing` model for the infection generating process using the `generate_latent_infs` function.
This function remakes the ODE problem with the provided initial conditions and parameters, solves it using the
specified solver, and then transforms the solution into latent infections using the `sol2infs`
function.

NB: The `nothing` argument is a dummy latent process, e.g. a log-Rt time series, that is not
used in the SIR model, but might be used in other models.

```julia
sir_infections_mdl = generate_latent_infs(sir_process, nothing)
```

We can generate some test data from the model by sampling from the model and then calling the model

```julia
# Sampled parameters
θ = rand(sir_infections_mdl)
expected_infections = (sir_infections_mdl | θ)()
test_data = expected_infections .|> λ -> rand(Poisson(λ))
```

Now, we can refit the model using a `PoissonError` observation model

```julia
pois_obs = PoissonError()

@model function fit_sir_model(data)
    @submodel I_t = generate_latent_infs(sir_process, nothing)
    @submodel _ = generate_observations(pois_obs, data, I_t)

    return nothing
end

inference_mdl = fit_sir_model(test_data)
chn = sample(inference_mdl, NUTS(), 2_000)
summarize(chn)
```

We can compare the summarized chain to the sampled parameters to see that the model is fitting
the data well.

# Custom ODE models

To define a custom ODE model, you need to define:

- Some `CustomParams <: AbstractTuringParamModel` struct (the name doesn't need to be `CustomParams`!)
    that contains the ODE problem as a field called `prob`, as well as sufficient fields to
    define or sample the parameters of the ODE model.
- A method for `EpiAwareBase.generate_parameters(params::CustomParams, Z_t)` that generates the
    initial condition and parameters of the ODE model, potentially conditional on a sample from a latent process `Z_t`.
    This method must return a `Tuple` `(u0, p)` where `u0` is the initial condition and `p` is the parameters.

Here is an example of a simple custom ODE model for _specified_ exponential growth:

```julia
using EpiAware, OrdinaryDiffEq
# Define a simple exponential growth model for testing
function expgrowth(du, u, p, t)
    du[1] = p[1] * u[1]
end

r = log(2) / 7 # Growth rate corresponding to 7 day doubling time

# Define the ODE problem using SciML
prob = ODEProblem(expgrowth, [1.0], (0.0, 10.0), [r])

# Define the custom parameters struct
struct CustomParams <: AbstractTuringParamModel
    prob::ODEProblem
    r::Float64
    u0::Float64
end
params = CustomParams(prob, r, 1.0)

# Define the custom generate_parameters function
@model function EpiAwareBase.generate_parameters(params::CustomParams, Z_t)
    return ([params.u0], [params.r])
end
```

This model is not random! But we can still use it to generate latent infections.

```julia
# Define the ODEProcess
expgrowth_model = ODEProcess(
    params = params,
    sol2infs = sol -> sol[1, :]
)
infs = generate_latent_infs(expgrowth_model, nothing)()
```
"""
@kwdef struct ODEProcess{
    P <: AbstractTuringParamModel, S, F <: Function, D <:
                                                     Union{Dict, NamedTuple}} <:
              EpiAwareBase.AbstractTuringEpiModel
    "The ODE problem instance, where `P` is a subtype of `ODEProblem`."
    params::P
    "The solver used for the ODE problem. Default is `AutoVern7(Rodas5())`, which is an auto
    switching solver aimed at medium/low tolerances."
    solver::S = AutoVern7(Rodas5())
    "A function that maps the solution object of the ODE to infection counts."
    sol2infs::F
    "The extra solver options for the ODE problem. Can be either a `Dict` or a `NamedTuple`
    containing the solver options."
    solver_options::D = Dict(:verbose => false, :saveat => 1.0)
end

@doc raw"""
Implement the `generate_latent_infs` function for the `ODEProcess` model.

This function remakes the ODE problem with the provided initial conditions and parameters,
    solves it using the specified solver, and then transforms the solution into latent infections
    using the `sol2infs` function.

# Example usage with predefined SIR model

In this example we define an `ODEProcess` object using the predefined `SIRParams` model and
generate an expected infection time series using SIR model parameters sampled from their priors.

```julia
using EpiAware, OrdinaryDiffEq, Distributions, LogExpFunctions

# Create an instance of SIRParams
sirparams = SIRParams(
    tspan = (0.0, 30.0),
    infectiousness = LogNormal(log(0.3), 0.05),
    recovery_rate = LogNormal(log(0.1), 0.05),
    initial_prop_infected = Beta(1, 99)
)
#Population size
N = 1000.0
sir_process = ODEProcess(
    params = sirparams,
    sol2infs = sol -> N .* logaddexp.(0.001, sol[2, :]),
    solver_options = Dict(:verbose => false, :saveat => 1.0)
)

generated_It = generate_latent_infs(sir_process, nothing)()
```

"""
@model function EpiAwareBase.generate_latent_infs(epi_model::ODEProcess, Z_t)
    prob, solver, sol2infs, solver_options = epi_model.params.prob,
    epi_model.solver, epi_model.sol2infs, epi_model.solver_options

    @submodel prefix="params" u0, p=generate_parameters(epi_model.params, Z_t)

    _prob = remake(prob; u0 = u0, p = p)
    sol = solve(_prob, solver; solver_options...)
    I_t = sol2infs(sol)

    return I_t
end
