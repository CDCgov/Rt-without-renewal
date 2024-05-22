@testitem "test unpacking a Chains object" begin
    using Turing, Distributions

    @model function testmodel()
        x ~ MvNormal(2, 1.0)
        y ~ Normal()
    end
    mdl = testmodel()
    chn = sample(mdl, Prior(), MCMCSerial(), 250, 4; progress = false)
    A = get_param_array(chn)

    @test size(A) == (size(chn)[1], size(chn)[3])
    @test eltype(A) <: NamedTuple
end
