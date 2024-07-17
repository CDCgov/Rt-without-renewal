using PkgBenchmark
benchmarkpkg(
    dirname(@__DIR__),
    BenchmarkConfig(
        env = Dict(
        "JULIA_NUM_THREADS" => "2",
        "OMP_NUM_THREADS" => "2"
    ),
    );
    retune = true
)
