using Test, DrWatson
quickactivate(@__DIR__(), "EpiAwarePipeline")
using EpiAware, EpiAwarePipeline, CairoMakie, Random, Distributions

y_t = rand(1:100, 28)
I_t = randn(28) .+ 50
data = Dict("y_t" => y_t, "I_t" => I_t)
config = Dict("truth_gi_mean" => 1.5)

##
f, path = plot_truth_data(data, config, RtwithoutRenewalPriorPipeline(); saveplot = true)
##
f = Figure(; backgroundcolor = :white)
ax = Axis(f[1, 1],
    title = "Cases and latent infections",
    xlabel = "Time",
    ylabel = "Daily cases"
)

scatter!(ax, data["y_t"], color = :black, label = "Daily cases")
lines!(ax, data["I_t"], label = "True latent infections", color = :red,
    linestyle = :dash)
# Legend(f[1,2], ax)
axislegend(position = :rt, framevisible = false, backgroundcolor = (:white, 0.0))
f
##
plt_cases = scatter(
    data["y_t"], label = "Cases", xlabel = "Time", ylabel = "Daily cases",
    title = "Cases and latent infections", legend = :bottomright)

##
function plot_truth_data(
        data, config, pipeline::AbstractEpiAwarePipeline; plotsname = "truth_data")
    plt_cases = scatter(
        data["y_t"], label = "Cases", xlabel = "Time", ylabel = "Daily cases",
        title = "Cases and latent infections", legend = :bottomright)
    Plots.plot!(plt_cases, data["I_t"], label = "True latent infections")

    if !isdir(plotsdir(plotsname))
        mkdir(plotsdir(plotsname))
    end
    _plotsname = _simulate_prefix(pipeline) * plotsname
    savefig(plt_cases, plotsdir(plotsname, savename(_plotsname, config, "png")))
    return plt_cases
end
##

## Makie tutorial

# seconds = 0:0.1:2
# measurements = [8.2, 8.4, 6.3, 9.5, 9.1, 10.5, 8.6, 8.2, 10.5, 8.5, 7.2,
#     8.8, 9.7, 10.8, 12.5, 11.6, 12.1, 12.1, 15.1, 14.7, 13.1]

# lines(seconds, measurements)

# ##
# plt = scatter(seconds, measurements)
# lines!(seconds, exp.(seconds) .+ 7)
# current_figure()
# ##
# f = Figure()
# ax = Axis(f[1, 1],
#     title = "Experimental data and exponential fit",
#     xlabel = "Time (seconds)",
#     ylabel = "Value"
# )
# scatter!(ax, seconds, measurements, color = :black, label = "Measurements")
# lines!(ax, seconds, exp.(seconds) .+ 7, color = :red,
#     linestyle = :dash, label = "f(x) = exp(x) + 7")
# axislegend(position = :rb)

# f

# ##
# save("first_figure.png", f)
# save("first_figure.svg", f)
# save("first_figure.pdf", f)
# ##
# set_theme!(backgroundcolor = :gray90)

# f = Figure(size = (800, 500))
# ax = Axis(f[1, 1], aspect = 1)
# Colorbar(f[1, 2])
# f

# ##

# f = Figure(size = (800, 500))
# ax = Axis(f[1, 1])
# Colorbar(f[1, 2])
# colsize!(f.layout, 1, Aspect(1, 1.0))
# f

# ##
# resize_to_layout!(f)
# f

# ##
# f = Figure()
# for i in 1:5, j in 1:5
#     Axis(f[i, j], width = 150, height = 150)
# end
# resize_to_layout!(f)

# f

# ##
# using CairoMakie
# using CairoMakie.FileIO

# f = Figure(
#         backgroundcolor = RGBf(0.98, 0.98, 0.98),
#         size = (1000, 700),
#     )

# ##
# ga = f[1, 1] = GridLayout()
# gb = f[2, 1] = GridLayout()
# gcd = f[1:2, 2] = GridLayout()
# gc = gcd[1, 1] = GridLayout()
# gd = gcd[2, 1] = GridLayout()

# ##

# axtop = Axis(ga[1, 1])
# axmain = Axis(ga[2, 1], xlabel = "before", ylabel = "after")
# axright = Axis(ga[2, 2])

# linkyaxes!(axmain, axright)
# linkxaxes!(axmain, axtop)

# labels = ["treatment", "placebo", "control"]
# data = randn(3, 100, 2) .+ [1, 3, 5]

# for (label, col) in zip(labels, eachslice(data, dims = 1))
#     scatter!(axmain, col, label = label)
#     density!(axtop, col[:, 1])
#     density!(axright, col[:, 2], direction = :y)
# end

# f

# ##

# axmain.xticks = 0:3:9
# axtop.xticks = 0:3:9

# f

# ##
# leg = Legend(ga[1, 2], axmain)

# f

# ##
# hidedecorations!(axtop, grid = false)
# hidedecorations!(axright, grid = false)
# leg.tellheight = true
# f

# ##
# colgap!(ga, 10)
# rowgap!(ga, 10)

# f

# ##
# Label(ga[1, 1:2, Top()], "Stimulus ratings", valign = :bottom,
#     font = :bold,
#     padding = (0, 0, 5, 0))

# f
# ##
# xs = LinRange(0.5, 6, 50)
# ys = LinRange(0.5, 6, 50)
# data1 = [sin(x^1.5) * cos(y^0.5) for x in xs, y in ys] .+ 0.1 .* randn.()
# data2 = [sin(x^0.8) * cos(y^1.5) for x in xs, y in ys] .+ 0.1 .* randn.()

# ax1, hm = contourf(gb[1, 1], xs, ys, data1,
#     levels = 6)
# ax1.title = "Histological analysis"
# contour!(ax1, xs, ys, data1, levels = 5, color = :black)
# hidexdecorations!(ax1)

# ax2, hm2 = contourf(gb[2, 1], xs, ys, data2,
#     levels = 6)
# contour!(ax2, xs, ys, data2, levels = 5, color = :black)

# f

# ##
# cb = Colorbar(gb[1:2, 2], hm, label = "cell group")
# low, high = extrema(data1)
# edges = range(low, high, length = 7)
# centers = (edges[1:6] .+ edges[2:7]) .* 0.5
# cb.ticks = (centers, string.(1:6))

# f

# ##

# ##

# # using Test
# # @testset "run prior predictive modelling for random scenario" begin
# #     using DrWatson, EpiAware
# #

# #     using EpiAwarePipeline
# #     pipeline = RtwithoutRenewalPriorPipeline()

# #     tspan = (1, 28)
# #     inference_method = make_inference_method(pipeline)
# #     truth_data_config = make_truth_data_configs(pipeline)[1]
# #     inference_configs = make_inference_configs(pipeline)
# #     inference_config = rand(inference_configs)
# #     truthdata = Dict("y_t" => fill(100, 28), "truth_gi_mean" => 1.5)

# #     inference_results = generate_inference_results(
# #         truthdata, inference_config, pipeline; tspan, inference_method)

# #     @test inference_results["inference_results"] isa EpiAwareObservables
# # end
