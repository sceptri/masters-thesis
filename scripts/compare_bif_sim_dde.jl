using JLD2, MAT, ColorSchemes, LaTeXStrings, LinearAlgebra

include("include/utils.jl")

jldopen("../data/delay_computation_metacentrum.jld2", "r") do simulation
    CairoMakie.activate!(type="png")

    bifurcation = matread("../data/Zathurecky2025/data_Interneuron2_a70f6ec203c569331870bbc2f364d81e.mat")["data"]
    results = bifurcation["results"]
    unstable_μs = bifurcation["num_unstable"]
    λ_values = bifurcation["lambda"]
    λs, Ts, ω₂s, βs = eachcol(results)

    λ_lims = (0, maximum(λs) + 0.0001)
    ω₂_lims = (0.95, 1.05)
    β_lims = (0, 1)
    T_lims = (minimum(Ts), 3)

    # LPC curve
    LPC_index = Int[]
    LPC_Ts = Real[]
    LPC_ω₂s = Real[]
    LPC_λs = Real[]
    LPC_βs = Real[]

    last_LPC_indices = Int[]
    last_LPC_βs = Real[]

    for λ = λ_values
        λᵢ = findall(λs .== λ)
        i_LPC_λs, i_LPC_βs, i_LPC_Ts, i_LPC_ω₂s = estimate_lpc(βs[λᵢ], λs[λᵢ], Ts[λᵢ], ω₂s[λᵢ], unstable_μs[λᵢ])

        push!(LPC_λs, i_LPC_λs...)
        push!(LPC_βs, i_LPC_βs...)
        push!(LPC_Ts, i_LPC_Ts...)
        push!(LPC_ω₂s, i_LPC_ω₂s...)

        LPC_indices = match_to_closest(last_LPC_indices, last_LPC_βs, i_LPC_βs)
        push!(LPC_index, LPC_indices...)

        last_LPC_indices = LPC_indices
        last_LPC_βs = i_LPC_βs
    end

    CyclicZissou = ColorScheme([ColorSchemes.Zissou1.colors..., reverse(ColorSchemes.Zissou1.colors)...])

    fig = Figure(size=(600, 400))
    ax = Axis(fig[1, 1], xlabel=L"C_2", ylabel=L"\lambda",
        limits=(ω₂_lims..., λ_lims...),
        xtickformat=v -> latexstring.(round.(v, digits=2)),
        ytickformat=v -> latexstring.(round.(v, digits=3)),
        xautolimitmargin=(0, 0), yautolimitmargin=(0, 0))

    β_ticks = (0:0.25:1, [L"0", L"\frac{1}{4} T", L"\frac{1}{2} T", L"\frac{3}{4} T", L"T"])

    hmap = heatmap!(ax,
        range(simulation["C₂"]...),
        range(simulation["λ"]...),
        transpose(simulation["shifts"]), colormap=CyclicZissou, colorrange=(0, 1))
    Colorbar(fig[1, 2], hmap; label=L"\beta", ticks=β_ticks)

    for i = 3:4
        LPCᵢ = LPC_index .== i
        lines!(ax, LPC_ω₂s[LPCᵢ], LPC_λs[LPCᵢ], color=:black, linewidth=2)
    end

    fig
end