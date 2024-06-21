using BenchmarkTools
SUITE = BenchmarkGroup()
for folder in readdir(joinpath(@__DIR__, "bench"))
    if isdir(joinpath(@__DIR__, "bench", folder))
        suite_name = basename(folder)
        suite_file = joinpath(@__DIR__, "bench", folder, "$suite_name.jl")
        if isfile(suite_file)
            SUITE[suite_name] = include(suite_file)
        end
    end
end
