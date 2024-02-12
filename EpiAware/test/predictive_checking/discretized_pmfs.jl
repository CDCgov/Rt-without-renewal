#=
# Discretized PMFs

## Analytical PMF for the Exponential distribution

For unit testing it is useful to have an analytically solvable example of double interval censoring. Easiest distribution we 
could solve analytically but was also not completely trivial was $X \sim \text{Exp}(1)$ day delay with daily interval censoring. 
W.l.o.g. Primary censored obs time is $t = 0$, and we go from the double-censored interval with uniform on interval primary
approximation as per [here](https://www.medrxiv.org/content/10.1101/2024.01.12.24301247v1).

For above example the secondary censored obs time can be $s = 0, 1, 2,...$ days. The probability mass function is:

```math
P_S(s) = \int_0^1 \int_s^{s+1} f_X(y-x)dy dx.
```

This splits into two cases: $s = 0$ and $s \geq 1$.

**Case 1:** $s=0$

```math
P_S(0) = \int_0^1 \int_x^1 \exp(-(y - x)) dy dx = \exp(-1).
```

_NB: the density is zero for negative values._

**Case 2:** $s \geq 1$

```math
P_S(s) = \int_0^1 \int_s^{s+1} \exp(-(y - x)) dy dx = (1 - \exp(-1)) (\exp(1) - 1) \exp(-s).
```

we can directly check that the above is a discrete prob distribution. First, non-negativity is obvious. Second, 
normalisation to 1 can be directly calculated,

```math
\begin{align}
 \sum_{s \geq 1} P_S(s)&= (1 - \exp(-1)) (\exp(1) - 1) \sum_{s \geq 1}  \exp(-s)  \\
&=  (1 - \exp(-1)) (\exp(1) - 1)  {\exp(-1) \over 1 - \exp(-1)} \\
& = 1 -  \exp(-1).
\end{align}
```
Therefore,

```math
 \sum_{s \geq 0} P_S(s) = 1.
```

## Predictive checking for the `create_discrete_pmf` function

This predictive checking shows the difference between the two methods of the `create_discrete_pmf` function 
for creating a discrete PMF from a continuous distribution with a given discretization interval `Δd` and upper bound `D`.

The default method is double censoring based on censoring intervals of width `Δd`. The basic method is based on the
same but with the assumption that the primary event happens at the edge of the censoring interval. The left edge implies that
the discrete PMF starts at `0`, the right edge implies that the discrete PMF starts at `Δd`. 
=#
using EpiAware
using StatsPlots
using Distributions

# Example distribution is a Gamma distribution with shape 2 and scale 3/2 (mean = 3 days, std = √4.5 days) with an upper bound of 21 days. 

cont_dist = Gamma(2, 3.0 / 2)
D = 21.0

# For daily censoring there is a fairly big difference between the two methods, as well as left/right interval endpointing.

plt1 = let
    Δd = 1
    ts = (0.0:Δd:(D-Δd)) |> collect
    pmf1 = create_discrete_pmf(cont_dist, Val(:single_censored); Δd = Δd, D = D)
    pmf2 = create_discrete_pmf(cont_dist; Δd = Δd, D = D)

    bar(
        ts,
        [pmf1;; pmf2],
        fillalpha = 0.5,
        lw = 0,
        title = "Discrete PMF with Δd = 1 day",
        label = ["Single censoring (midpoint primary)" "Double Censoring"],
        xlabel = "Days",
        ylabel = "Probability",
    )
end
savefig(plt1, joinpath(@__DIR__(), "assets/", "discrete_pmf_daily.png"))

# For hourly censoring the difference is not noticable.

plt2 = let
    Δd = 1/24
    ts = (0.0:Δd:(D-Δd)) |> collect
    pmf1 = create_discrete_pmf(cont_dist, Val(:single_censored); Δd = Δd, D = D)
    pmf2 = create_discrete_pmf(cont_dist; Δd = Δd, D = D)

    bar(
        ts,
        [pmf1;; pmf2],
        fillalpha = 0.5,
        lw = 0,
        title = "Discrete PMF with Δd = 1 hour",
        label = ["Single censoring (midpoint primary)" "Double Censoring"],
        xlabel = "Days",
        ylabel = "Probability",
    )
end
savefig(plt2, joinpath(@__DIR__(), "assets/", "discrete_pmf_hourly.png"))
