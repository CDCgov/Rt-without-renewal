#=
# Fast approximation for `r` from `R₀`
I use the negative moment generating function (MGF).

Let
```math
G(r) = \sum_{i=1}^{\infty} w_i e^{-r i}.
```
and
```math
f(r, \mathcal{R}_0) = \mathcal{R}_0 G(r) - 1.
```
then the connection between `R₀` and `r` is given by
```math
f(r, \mathcal{R}_0) = 0.
```
Given an estimate of $\mathcal{R}_0$ we implicit solve for $r$ using a root
finder algorithm. In this note, I test a fast approximation for $r$ which
should have good autodifferentiation properties. The idea is to start from the
small $r$ approximation to the solution of $f(r, \mathcal{R}_0) = 0$ and then
apply one step of Newton's method. The small $r$ approximation is given by
```math
r_0 = { \mathcal{R}_0 - 1 \over  \mathcal{R}_0 \langle W \rangle }.
```
where $\langle W \rangle$ is the mean of the generation interval.

To rapidly improve the estimate for `r` we use Newton steps given by
```math
r_{n+1} = r_n - {\mathcal{R}_0 G(r) - 1\over \mathcal{R}_0 G'(r)}.
```

### Test mode

Run this script in Test environment mode. If not, run the following command:

```julia
using TestEnv
TestEnv.activate()
```
=#

using EpiAware
using Distributions
using StatsPlots

# Create a discrete probability mass function (PMF) for a negative binomial distribution
# with left truncation at 1.

w = censored_pmf(NegativeBinomial(2, 0.5), D = 20.0) |>
    p -> p[2:end] ./ sum(p[2:end])

##

jitter = 1e-17
idxs = 0:10
doubling_times = [1.0, 3.5, 7.0, 14.0]

errors = mapreduce(hcat, doubling_times) do T_2
    true_r = log(2) / T_2 # 7 day doubling time
    R0 = EpiAware.r_to_R(true_r, w)

    return map(idxs) do ns
        @time r = EpiAware.R_to_r(R0, w, newton_steps = ns)
        abs(r - true_r) + jitter
    end
end

plot(idxs,
    errors,
    yscale = :log10,
    xlabel = "Newton steps",
    ylabel = "abs. Error",
    title = "Fast approximation for r",
    lab = ["T_2 = 1.0" "T_2 = 3.5" "T_2 = 7.0" "T_2 = 14.0"],
    yticks = [0.0, 1e-15, 1e-10, 1e-5, 1e0] |> x -> (x .+ jitter, string.(x)),
    xticks = 0:2:10)
