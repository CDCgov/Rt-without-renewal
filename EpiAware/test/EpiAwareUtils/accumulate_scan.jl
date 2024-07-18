@testitem "Test that accumulate_scan works as expected" begin
    struct TestStep <: AbstractAccumulationStep
        a::Float64
    end

    function (step::TestStep)(state, ϵ)
        new_state = step.a * ϵ
        return new_state
    end
    acc_step = TestStep(0.5)
    initial_state = zeros(3)
    @test accumulate_scan(acc_step, initial_state, [1.0, 2.0, 3.0]) ==
          [0.0, 0.0, 0.0, 0.5, 1.0, 1.5]
end

@testitem "Test that get_state works as expected" begin
    struct TestStep <: AbstractAccumulationStep
        a::Float64
    end

    function (step::TestStep)(state, ϵ)
        new_state = step.a * ϵ
        return new_state
    end

    function get_state(acc_step::TestStep, initial_state, state)
        return state
    end

    acc_step = TestStep(0.5)
    initial_state = zeros(3)
    result = accumulate(acc_step, [1.0, 2.0, 3.0], init = initial_state)
    @test get_state(acc_step, initial_state, result) == [0.5, 1.0, 1.5]
end
