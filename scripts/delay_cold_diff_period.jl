using Revise
using GridWalker
using CairoMakie, LaTeXStrings
using LinearAlgebra
using ColorSchemes

# Note: NeuronToolbox is for some (inexplicable) reason slow in this scenario
# Any allocation or runtime dispatch slows down the calculation considerably
# Thus, while NeuronToolbox is fine for most cases, here we use a hand-made coupled interneurons model
include("../src/models/coupled_interneurons.jl")

λ = (start=0.0, stop=0.035, length=75)
C₂ = (start=0.95, stop=1.05, length=75)
τ = 0.025

# All arguments can be found in GridWalker/src/WalkerParameters.jl
args = (
    # Grid
	# x-axis
    min_x_param=C₂.start,
    max_x_param=C₂.stop,
    x_param_density=C₂.length,
    # y-axis
    min_y_param=λ.start,
    max_y_param=λ.stop,
    y_param_density=λ.length,

    # Model
    model_equation=CoupledInterneurons.model,
    model_params=(x, y, τ) -> CoupledInterneurons.params(; C₂=x, λ=y, τ),

    # Delay of the DDE
    τ=τ,
    tspan=(0, 1500),

    # Period and Shift Search
    period_searcher=GridWalker.diff_period,
    partial_trajectory_period=0.2,
    partial_trajectory_shift=0.1,

    # Periodicity Checker
    periodicity_checker=GridWalker.NoChecker(),

    # Starter
    starter=GridWalker.cold_start,
    u0=[31, 0.2, 0.5, -36, 0.16, 0.5],

	# Iterator
	enumerator=GridWalker.line_enumerator,

    # Saving
    save_every_nth=100,
    save_all_trajectories=false,
    save_oscillations=false,
)

params = parametrize_walker(; args...);

# Actual solve
@time shifts, trajectories, oscillations = walk_grid(params);

using JLD2
jldsave("data/delay_cold_diff_no_checker.jld2"; shifts, λ, C₂, τ)

begin
	CyclicZissou = ColorScheme([ColorSchemes.Zissou1.colors..., reverse(ColorSchemes.Zissou1.colors)...]);
	fig = Figure(size=(600, 400))
	ax = CairoMakie.Axis(fig[1, 1];
		xlabel=L"C_2", ylabel=L"\lambda")

	hmap = heatmap!(ax,
		range(C₂...),
		range(λ...),
		transpose(shifts), colormap=CyclicZissou)
	Colorbar(fig[1, 2], hmap; label=L"\beta", width=15, ticksize=15, tickalign=1)

	fig
end