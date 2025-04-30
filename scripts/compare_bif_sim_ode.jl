using JLD2, MAT, ColorSchemes, LaTeXStrings, LinearAlgebra

jldopen("../data/no_delay_computation_metacentrum.jld2", "r") do simulation
    CairoMakie.activate!(type="png")

    bifurcation = matread("../data/Zathurecky2025/data_IN2_sparse.mat")["data"]
    LPCs = bifurcation["results_LPC"]
    results = bifurcation["results"]
    λs, Ts, ω₂s, βs = eachcol(results)
    LPC_index, LPC_Ts, LPC_ω₂s, LPC_λs, LPC_βs = eachcol(LPCs)

    λ_lims = (0, maximum(λs))
    ω₂_lims = (0.98, maximum(ω₂s))

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

    for i = 1:2
        LPCᵢ = LPC_index .== i
        lines!(ax, LPC_ω₂s[LPCᵢ], LPC_λs[LPCᵢ], color=:black, linewidth=2)
    end

    fig
end