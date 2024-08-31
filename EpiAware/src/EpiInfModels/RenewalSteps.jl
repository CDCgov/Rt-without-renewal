@doc raw"
Abstract type representing an accumulation iteration/step for a Renewal model with a constant
generation interval.
"
abstract type AbstractConstantRenewalStep <: AbstractAccumulationStep end

@doc raw"
The renewal process iteration/step function struct with constant generation interval.

Note that the generation interval is stored in reverse order.
"
struct ConstantRenewalStep{T} <: AbstractConstantRenewalStep
    rev_gen_int::Vector{T}
end

@doc """
    function (recurrent_step::ConstantRenewalStep)(recent_incidence, Rt)

Implement the `Renewal` model iteration/step function, with constant generation interval.

## Mathematical specification

The new incidence is given by

```math
I_t = R_t \\sum_{i=1}^{n-1} I_{t-i} g_i
```

where `I_t` is the new incidence, `R_t` is the reproduction number, `I_{t-i}` is the recent incidence
and `g_i` is the generation interval.

# Arguments
- `recent_incidence`: Array of recent incidence values order least recent to most recent.
- `Rt`: Reproduction number.

# Returns
- Updated incidence array.
"""
function (recurrent_step::ConstantRenewalStep)(recent_incidence, Rt)
    new_incidence = Rt * dot(recent_incidence, recurrent_step.rev_gen_int)
    return vcat(recent_incidence[2:end], new_incidence)
end

"""
Constructs the initial conditions for a renewal model with `ConstantRenewalStep`
    type of step function.
"""
function renewal_init_state(recurrent_step::ConstantRenewalStep, I₀, r_approx, len_gen_int)
    I₀ * [exp(-r_approx * t) for t in (len_gen_int - 1):-1:0]
end

@doc raw"
Method to get the state of the accumulation for a `ConstantRenewalStep` object.
"
function EpiAwareUtils.get_state(
        acc_step::ConstantRenewalStep, initial_state, state)
    return last.(state)
end

@doc raw"
The renewal process iteration/step function struct with constant generation interval and a fixed
population size.

Note that the generation interval is stored in reverse order.
"
struct ConstantRenewalWithPopulationStep{T} <: AbstractConstantRenewalStep
    rev_gen_int::Vector{T}
    pop_size::T
end

@doc """
    function (recurrent_step::ConstantRenewalWithPopulationStep)(recent_incidence_and_available_sus, Rt)

Callable on a `RenewalWithPopulation` struct for compute new incidence based on
recent incidence, Rt and depletion of susceptibles.

## Mathematical specification

The new incidence is given by

```math
I_t = {S_{t-1} / N} R_t \\sum_{i=1}^{n-1} I_{t-i} g_i
```

where `I_t` is the new incidence, `R_t` is the reproduction number, `I_{t-i}` is the recent incidence
and `g_i` is the generation interval.

# Arguments
- `recent_incidence_and_available_sus`: A tuple with an array of recent incidence
values and the remaining susceptible/available individuals.
- `Rt`: Reproduction number.

# Returns
- Vector containing the updated incidence array and the new `recent_incidence_and_available_sus`
value.
"""
function (recurrent_step::ConstantRenewalWithPopulationStep)(
        recent_incidence_and_available_sus, Rt)
    recent_incidence, S = recent_incidence_and_available_sus
    new_incidence = max(S / recurrent_step.pop_size, 1e-6) * Rt *
                    dot(recent_incidence, recurrent_step.rev_gen_int)
    new_S = S - new_incidence

    new_recent_incidence_and_available_sus = [
        vcat(recent_incidence[2:end], new_incidence), new_S]

    return new_recent_incidence_and_available_sus
end

"""
Constructs the initial conditions for a renewal model with `ConstantRenewalWithPopulationStep`
    type of step function.
"""
function renewal_init_state(
        recurrent_step::ConstantRenewalWithPopulationStep, I₀, r_approx, len_gen_int)
    [I₀ * [exp(-r_approx * t) for t in (len_gen_int - 1):-1:0], recurrent_step.pop_size]
end

@doc raw"
Method to get the state of the accumulation for a `ConstantRenewalWithPopulationStep` object.
"
function EpiAwareUtils.get_state(
        acc_step::ConstantRenewalWithPopulationStep, initial_state, state)
    return state .|> st -> last(st[1])
end
