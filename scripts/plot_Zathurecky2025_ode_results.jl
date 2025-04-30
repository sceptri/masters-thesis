
using MAT, ColorSchemes, LaTeXStrings

function render_ode_results()
	fig = Figure(size=(800, 800))
	μ_threshold = 1.0001
	β_ticks = (0:0.25:1, [L"0", L"\frac{1}{4} T", L"\frac{1}{2} T", L"\frac{3}{4} T", L"T"])

	data = matread("../data/Zathurecky2025/data_IN2_sparse.mat")["data"]

	results = data["results"]
	μs = data["multipliers"]

	LPCs = data["results_LPC"]
	LPC_index, LPC_Ts, LPC_ω₂s, LPC_λs, LPC_βs = eachcol(LPCs)

	λs, Ts, ω₂s, βs = eachcol(results)
	stable = maximum(abs, μs, dims=2) .< μ_threshold

	β_offset = 1.25
	T_offset = 2.67

	λ_lims = (0, maximum(λs))
	ω₂_lims = (0.98, maximum(ω₂s))
	β_lims = (0, 1)
	T_lims = (minimum(Ts), 3)

	in_λ = first(λ_lims) .<= LPC_λs .<= last(λ_lims)
	in_β = first(β_lims) .<= (1 .- LPC_βs) .<= last(β_lims)
	in_ω₂ = first(ω₂_lims) .<= LPC_ω₂s .<= last(ω₂_lims)
	in_T = first(T_lims) .<= LPC_Ts .<= last(T_lims)

	ax = Axis3(fig[1,1], 
		title=L"\text{(A)}", titlealign=:left,
		azimuth = deg2rad(-12), elevation=deg2rad(15),
		aspect=:equal, yticks=β_ticks,
		limits=(λ_lims..., (0, β_offset + 0.001)..., ω₂_lims...),
		xtickformat=v -> latexstring.(round.(v, digits=2)),
		ztickformat=v -> latexstring.(round.(v, digits=2)),
		xlabel=L"\lambda", ylabel=L"\beta", zlabel=L"C_2")

	scatter!(ax, λs[stable], βs[stable], ω₂s[stable], color=first(ColorSchemes.Zissou1), markersize = 1.75)
	scatter!(ax, λs[.!stable], βs[.!stable], ω₂s[.!stable], color=last(ColorSchemes.Zissou1), markersize = 1.75)

	for i = 1:maximum(LPC_index)
		LPCᵢ = (LPC_index .== i) .&& in_λ .&& in_β .&& in_ω₂
		lines!(ax, LPC_λs[LPCᵢ], 1 .- LPC_βs[LPCᵢ], LPC_ω₂s[LPCᵢ], color=:black)
		lines!(ax, LPC_λs[LPCᵢ], β_offset .* ones(sum(LPCᵢ)), LPC_ω₂s[LPCᵢ], color=:gray, overdraw = false)
	end

	ax = Axis3(fig[1,2:3],
		title=L"\text{(B)}", titlealign=:left,
		azimuth=deg2rad(-45), elevation=deg2rad(12),
		aspect=:equal,
		limits=(λ_lims..., ω₂_lims...,  (T_offset - 0.001, 3)...),
		xtickformat=v -> latexstring.(round.(v, digits=2)),
		ytickformat=v -> latexstring.(round.(v, digits=2)),
		ztickformat=v -> latexstring.(round.(v, digits=2)),
		xlabel=L"\lambda", ylabel=L"C_2", zlabel=L"T")

	scatter!(ax, λs[stable], ω₂s[stable], Ts[stable], color=first(ColorSchemes.Zissou1), markersize=1.75)
	scatter!(ax, λs[.!stable], ω₂s[.!stable], Ts[.!stable], color=last(ColorSchemes.Zissou1), markersize=1.75)

	for i = 1:maximum(LPC_index)
		LPCᵢ = (LPC_index .== i) .&& in_λ .&& in_ω₂ .&& in_T
		lines!(ax, LPC_λs[LPCᵢ], LPC_ω₂s[LPCᵢ], LPC_Ts[LPCᵢ], color=:black)
		lines!(ax, LPC_λs[LPCᵢ], LPC_ω₂s[LPCᵢ], T_offset .* ones(sum(LPCᵢ)), color=:gray, overdraw=false)
	end

	data = matread("../data/Zathurecky2025/data_IN2_dense.mat")["data"]

	results = data["results"]
	μs = data["multipliers"]

	LPCs = data["results_LPC"]
	LPC_index, LPC_Ts, LPC_ω₂s, LPC_λs, LPC_βs = eachcol(LPCs)

	λs, Ts, ω₂s, βs = eachcol(results)
	stable = maximum(abs, μs, dims=2) .< μ_threshold

	antiphase = stable .&& (βs .> 1/3) .&& (βs .< 2/3) .&& (λs .> 0.0016)
	inphase = stable .&& ((βs .< 1/3) .|| (βs .> 2/3))

	CyclicZissou = ColorScheme([ColorSchemes.Zissou1.colors..., reverse(ColorSchemes.Zissou1.colors)...])

    ax1 = Axis(fig[2, 1], xlabel=L"C_2", ylabel=L"\lambda",
        title=L"\text{(C)}", titlealign=:left, titlegap=12,
		limits=(ω₂_lims..., λ_lims...),
        xtickformat=v -> latexstring.(round.(v, digits=2)),
        ytickformat=v -> latexstring.(round.(v, digits=3)),
        xautolimitmargin=(0, 0), yautolimitmargin=(0, 0))
    scatter!(ax1, ω₂s[inphase], λs[inphase], color=βs[inphase], 
        colormap=CyclicZissou, colorrange=(0, 1),
		markersize=2.7)

    for i = 3:11
        LPCᵢ = LPC_index .== i
        lines!(ax1, LPC_ω₂s[LPCᵢ], LPC_λs[LPCᵢ], color=:black)
    end
    for i = 1:2
        LPCᵢ = LPC_index .== i
        lines!(ax1, LPC_ω₂s[LPCᵢ], LPC_λs[LPCᵢ], color=:white)
        lines!(ax1, LPC_ω₂s[LPCᵢ], LPC_λs[LPCᵢ], linestyle=:dash, color=:gray)
    end
	
    ax2 = Axis(fig[2, 2], xlabel=L"C_2", ylabel=L"\lambda",
        title=L"\text{(D)}", titlealign=:left, titlegap=12,
        limits=(ω₂_lims..., λ_lims...),
        xtickformat=v -> latexstring.(round.(v, digits=2)),
        ytickformat=v -> latexstring.(round.(v, digits=3)),
        xautolimitmargin=(0, 0), yautolimitmargin=(0, 0))
    sc = scatter!(ax2, ω₂s[antiphase], λs[antiphase], color=βs[antiphase], 
		colormap=CyclicZissou, colorrange=(0, 1),
		markersize=2.7)
    Colorbar(fig[2, 3], sc, label=L"\beta", ticks=β_ticks)

    for i = 1:2
        LPCᵢ = LPC_index .== i
        lines!(ax2, LPC_ω₂s[LPCᵢ], LPC_λs[LPCᵢ], color=:black)
    end
    for i = 3:11
        LPCᵢ = LPC_index .== i
        lines!(ax2, LPC_ω₂s[LPCᵢ], LPC_λs[LPCᵢ], color=:white)
        lines!(ax2, LPC_ω₂s[LPCᵢ], LPC_λs[LPCᵢ], linestyle=:dash, color=:gray)
    end

	linkyaxes!(ax1, ax2)

	return fig
end
