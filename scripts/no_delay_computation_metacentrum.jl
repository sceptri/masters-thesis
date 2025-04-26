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
    τ=0,
    tspan=(0, 1500),

    # Period and Shift Search
    period_searcher=GridWalker.optimal_period_among,
    partial_trajectory_period=0.2,
    partial_trajectory_shift=0.1,
    coordinate_distance_weight=0.1,

    # Periodicity Checker
    periodicity_checker=GridWalker.PeakDivergenceChecker(),
    partial_trajectory_check=0.2,
    divergence_threshold=1.2,
    fixed_value_threshold=1e-1,
    divergence_window=100,

    # Starter
    starter=GridWalker.indexed_start,
    u0=[31, 0.2, 0.5, -36, 0.16, 0.5],
    starter_loss=GridWalker.additive_loss,

    # Indexer
    indexer_N=10,
    indexer=GridWalker.diagonal_indexer,

    # Iterator
    enumerator=GridWalker.spiral_enumerator,
    center_function=GridWalker.relative_center,
    fixed_ratio_center=(0.5, 0.9),

    # Saving
    save_every_nth=100,
    save_all_trajectories=false,
    save_oscillations=false,
)

params = parametrize_walker(; args...);

# Actual solve
@time shifts, trajectories, oscillations = walk_grid(params);

using JLD2
jldsave("data/no_delay_computation_metacentrum.jld2"; shifts, λ, C₂)