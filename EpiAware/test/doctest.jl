@testitem "Run docstring tests" begin
    using Documenter
    doctest(EpiAware; fix = true)
end
