#=
# Discretized PMFs

This predictive checking shows the difference between the two methods of the `create_discrete_pmf` function 
for creating a discrete PMF from a continuous distribution with a given discretization interval `Δd` and upper bound `D`.

The default method is double censoring based on censoring intervals of width `Δd`. The basic method is based on the
same but with the assumption that the primary event happens at the edge of the censoring interval. The left edge implies that
the discrete PMF starts at `0`, the right edge implies that the discrete PMF starts at `Δd`. 
=#
using RtWithoutRenewal
using StatsPlots
using Distributions

# Example distribution is a Gamma distribution with shape 2 and scale 3/2 (mean = 3 days, std = √4.5 days) with an upper bound of 21 days. 

cont_dist = Gamma(2, 3.0 / 2)
D = 21.0

# For daily censoring there is a fairly big difference between the two methods, as well as left/right interval endpointing.

plt1 = let
    Δd = 1
    ts = (0.0:Δd:(D-Δd)) |> collect
    pmf1 = create_discrete_pmf(cont_dist, Val(:basic); Δd = Δd, D = D)
    pmf2 = create_discrete_pmf(cont_dist; Δd = Δd, D = D)

    bar(
        ts,
        [pmf1;; [0.0; pmf1[1:(end-1)]];; pmf2],
        fillalpha = 0.5,
        lw = 0,
        title = "Discrete PMF with Δd = 1 day",
        label = ["Basic (left)" "Basic (right)" "Double Censoring"],
        xlabel = "Days",
        ylabel = "Probability",
    )
end
savefig(plt1, joinpath(@__DIR__(), "assets/", "discrete_pmf_daily.png"))

# For hourly censoring the difference is not noticable.

plt2 = let
    Δd = 1/24
    ts = (0.0:Δd:(D-Δd)) |> collect
    pmf1 = create_discrete_pmf(cont_dist, Val(:basic); Δd = Δd, D = D)
    pmf2 = create_discrete_pmf(cont_dist; Δd = Δd, D = D)

    bar(
        ts,
        [pmf1;; [0.0; pmf1[1:(end-1)]];; pmf2],
        fillalpha = 0.5,
        lw = 0,
        title = "Discrete PMF with Δd = 1 hour",
        label = ["Basic (left)" "Basic (right)" "Double Censoring"],
        xlabel = "Days",
        ylabel = "Probability",
    )
end
savefig(plt2, joinpath(@__DIR__(), "assets/", "discrete_pmf_hourly.png"))
