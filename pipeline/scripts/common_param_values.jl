@info("""
      Setting common parameter in `Main` module.
      ---------------------------------------------
      Currently active project is: $(projectname())
      Path of active project: $(projectdir())

      """)

using EpiAware
# Common generation interval values
gi_means = [2.0, 10.0, 20.0];
gi_stds = [2.0];

#Common thread count
num_threads = min(10, Threads.nthreads());

#Common inference method
inference_method = EpiMethod(
    pre_sampler_steps = [ManyPathfinder(nruns = 4, maxiters = 100)],
    sampler = NUTSampler(adtype = AutoForwardDiff(),
        ndraws = 2000,
        nchains = num_threads,
        mcmc_parallel = MCMCThreads())
)

#True Rt
A = 0.3
P = 30.0
ϕ = asin(-0.1 / 0.3) * P / (2 * π)
N = 160
true_Rt = vcat(fill(1.1, 2 * 7), fill(2.0, 2 * 7), fill(0.5, 2 * 7),
    fill(1.5, 2 * 7), fill(0.75, 2 * 7), fill(1.1, 6 * 7)) |>
          Rt -> [Rt;
                 [1.0 + A * sin.(2 * π * (t - ϕ) / P) for t in 1:(N - length(Rt))]]

# Common inference tspan: Length of true Rt less three weeks
inference_tspan = (1, N - 21)
