using PkgBenchmark
benchmarkpkg(
    dirname(@__DIR__),
    BenchmarkConfig(
        env = Dict(
        "JULIA_NUM_THREADS" => "4",
        "OMP_NUM_THREADS" => "4"
    ),
    );
    retune = true
)
