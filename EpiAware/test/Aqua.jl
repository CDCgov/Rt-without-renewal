
@testitem "Aqua.jl" begin
    using Aqua
    Aqua.test_all(EpiAware, ambiguities = false)
    Aqua.test_ambiguities(EpiAware)
end
