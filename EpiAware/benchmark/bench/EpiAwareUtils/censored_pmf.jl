let
    using Distributions
    dist = Exponential(1.0)
    suite["censored_pmf"] = @benchmarkable(censored_pmf($dist, Δd = 1.0, D = 3.0))
end
