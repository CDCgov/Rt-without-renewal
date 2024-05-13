"""
Compute the default Rt values over time.

## keyword Arguments
- `A`: Amplitude of the sinusoidal variation in Rt. Default is 0.3.
- `P`: Period of the sinusoidal variation in Rt. Default is 30 time steps.

## Returns
- `true_Rt`: Array of default Rt values over time.

"""
function default_Rt(; A = 0.3, P = 30.0)
    ϕ = asin(-0.1 / 0.3) * P / (2 * π)
    N = 160
    true_Rt = vcat(fill(1.1, 2 * 7), fill(2.0, 2 * 7), fill(0.5, 2 * 7),
        fill(1.5, 2 * 7), fill(0.75, 2 * 7), fill(1.1, 6 * 7)) |>
              Rt -> [Rt;
                     [1.0 + A * sin.(2 * π * (t - ϕ) / P) for t in 1:(N - length(Rt))]]
    return true_Rt
end
