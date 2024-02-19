
@testitem "Aqua.jl" begin
    using Aqua
    Aqua.test_all(EpiAware, ambiguities = false, persistent_tasks = false)
    Aqua.test_ambiguities(EpiAware)
end
