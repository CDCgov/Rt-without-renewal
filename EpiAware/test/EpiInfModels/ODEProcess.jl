@testitem "ODEParams Tests" begin
    # Test with vectors
    u0_vec = [1.0, 2.0, 3.0]
    p_vec = [0.1, 0.2, 0.3]
    params_vec = ODEParams(u0 = u0_vec, p = p_vec)

    @test params_vec.u0 == u0_vec
    @test params_vec.p == p_vec
    @test eltype(params_vec.u0) == Float64
    @test eltype(params_vec.p) == Float64

    # Test with matrices
    u0_mat = [1.0 2.0; 3.0 4.0]
    p_mat = [0.1 0.2; 0.3 0.4]
    params_mat = ODEParams(u0 = u0_mat, p = p_mat)

    @test params_mat.u0 == u0_mat
    @test params_mat.p == p_mat
    @test eltype(params_mat.u0) == Float64
    @test eltype(params_mat.p) == Float64

    # Test with mixed types (should promote to common type)
    u0_mixed = [1, 2, 3]
    p_mixed = [0.1, 0.2, 0.3]
    params_mixed = ODEParams(u0 = u0_mixed, p = p_mixed)

    @test params_mixed.u0 == Float64.(u0_mixed)
    @test params_mixed.p == Float64.(p_mixed)
    @test eltype(params_mixed.u0) == Float64
    @test eltype(params_mixed.p) == Float64
end
