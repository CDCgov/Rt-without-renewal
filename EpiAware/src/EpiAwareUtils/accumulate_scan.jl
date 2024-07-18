@doc raw"
    Apply the `accumulate` function to the `AbstractAccumulationStep` object.
    This is effectively a optimised version of a for loop that applies the
    `AbstractAccumulationStep` object to the input data in a single pass.

    # Arguments
    - `acc_step::AbstractAccumulationStep: The accumulation step function.
    - `initial_state`: The initial state of the accumulation.
    - `ϵ_t::AbstractVector{<:Real}`: The input data.

    # Returns
    - `state::AbstractVector{<:Real}`: The accumulated state as returned by the
    `get_state` function from the output of the `accumulate` function.

    # Examples
    ```julia
    using EpiAware
    struct TestStep <: AbstractAccumulationStep
        a::Float64
    end

    function (step::TestStep)(state, ϵ)
        new_state = step.a * ϵ
        return new_state
    end

    acc_step = TestStep(0.5)
    initial_state = zeros(3)

    accumulate_scan(acc_step, initial_state, [1.0, 2.0, 3.0])

    function get_state(acc_step::TestStep, initial_state, state)
        return state
    end

    accumulate_scan(acc_step, initial_state, [1.0, 2.0, 3.0])
    ```
"
function accumulate_scan(acc_step::AbstractAccumulationStep, initial_state, ϵ_t)
    result = accumulate(acc_step, ϵ_t, init = initial_state)
    return get_state(acc_step, initial_state, result)
end

@doc raw"
    Processes the output of the `accumulate` function to return the final state.

    # Arguments
    - `acc_step::AbstractAccumulationStep`: The accumulation step function.
    - `initial_state`: The initial state of the accumulation.
    - `state`: The output of the `accumulate` function.

    # Returns
    - `state`: The combination of the initial state and the last element of
      each accumulated state.
"
function get_state(acc_step::AbstractAccumulationStep, initial_state, state)
    return vcat(initial_state, last.(state))
end
