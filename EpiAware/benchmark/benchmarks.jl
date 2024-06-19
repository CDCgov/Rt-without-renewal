using BenchmarkTools
SUITE = BenchmarkGroup()
for file in readdir(joinpath(@__DIR__, "bench"))
    if endswith(file, ".jl")
        SUITE[basename(file, ".jl")] = include(joinpath(@__DIR__, "bench", file))
    end
end
