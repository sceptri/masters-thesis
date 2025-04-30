using MAT, ColorSchemes, LaTeXStrings, LinearAlgebra

include("include/utils.jl")

function render_dde_results()
	fig = Figure(size=(800, 800))
	μ_threshold = 1.0001
	β_ticks = (0:0.25:1, [L"0", L"\frac{1}{4} T", L"\frac{1}{2} T", L"\frac{3}{4} T", L"T"])

	data = matread("../data/Zathurecky2025/data_Interneuron2_a70f6ec203c569331870bbc2f364d81e.mat")["data"]

	results = data["results"]
	unstable_μs = data["num_unstable"]
	λ_values = data["lambda"]

	λs, Ts, ω₂s, βs = eachcol(results)
	stable = unstable_μs .== 0

	β_offset = 1.25
	T_offset = 2.67

	λ_lims = (0, maximum(λs) + 0.0001)
	ω₂_lims = (0.95, 1.05)
	β_lims = (0, 1)
	T_lims = (minimum(Ts), 3)

	shift_max_line_length = 0.08; shift_x_change = 0.075;
	period_max_line_length = 0.02; period_x_change = 0.005;

	# LPC curve
	LPC_index = Int[]
	LPC_Ts = Real[]
	LPC_ω₂s = Real[]
	LPC_λs = Real[]
	LPC_βs = Real[]

	last_LPC_indices = Int[]
	last_LPC_βs = Real[]

	for λ = λ_values
		λᵢ = findall(λs .== λ);
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

	in_λ = first(λ_lims) .<= LPC_λs .<= last(λ_lims)
	in_β = first(β_lims) .<= LPC_βs .<= last(β_lims)
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

	for λ in λ_values
		λᵢ = λs .== λ

		λs_short = λs[λᵢ]
		ω₂s_short = ω₂s[λᵢ]
		βs_short = βs[λᵢ]
		Ts_short = Ts[λᵢ]
		unstable_μs_short = unstable_μs[λᵢ]

		Δβs = diff(βs_short)
		line_segments = diff([[βs[j], ω₂s[j]] for j in eachindex(λs_short)], dims = 1)

		for i in eachindex(λs_short)
			if i == lastindex(λs_short)
				break
			end

			color = unstable_μs_short[i] > 0 ? last(ColorSchemes.Zissou1) : first(ColorSchemes.Zissou1)

			if abs(Δβs[i]) < shift_x_change && norm(line_segments[i]) < shift_max_line_length
				lines!(ax, λs_short[i:i+1], βs_short[i:i+1], ω₂s_short[i:i+1], color=color)
			end
		end
	end

	for i = 1:maximum(LPC_index)
		LPCᵢ = (LPC_index .== i) .&& in_λ .&& in_β .&& in_ω₂
		lines!(ax, LPC_λs[LPCᵢ], LPC_βs[LPCᵢ], LPC_ω₂s[LPCᵢ], color=:black)
		lines!(ax, LPC_λs[LPCᵢ], β_offset .* ones(sum(LPCᵢ)), LPC_ω₂s[LPCᵢ], color=:gray, overdraw=false)
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

	for λ in λ_values
		λᵢ = λs .== λ

		λs_short = λs[λᵢ]
		ω₂s_short = ω₂s[λᵢ]
		βs_short = βs[λᵢ]
		Ts_short = Ts[λᵢ]
		unstable_μs_short = unstable_μs[λᵢ]

		Δω₂s = diff(ω₂s_short)
		line_segments = diff([[ω₂s[j], Ts[j]] for j in eachindex(λs_short)], dims=1)

		for i in eachindex(λs_short)
			if i == lastindex(λs_short)
				break
			end

			color = unstable_μs_short[i] > 0 ? last(ColorSchemes.Zissou1) : first(ColorSchemes.Zissou1)

			if abs(Δω₂s[i]) < period_x_change && norm(line_segments[i]) < period_max_line_length
				lines!(ax, λs_short[i:i+1], ω₂s_short[i:i+1], Ts_short[i:i+1], color=color)
			end
		end
	end
	for i = 1:maximum(LPC_index)
		LPCᵢ = (LPC_index .== i) .&& in_λ .&& in_ω₂ .&& in_T
		lines!(ax, LPC_λs[LPCᵢ], LPC_ω₂s[LPCᵢ], LPC_Ts[LPCᵢ], color=:black)
		lines!(ax, LPC_λs[LPCᵢ], LPC_ω₂s[LPCᵢ], T_offset .* ones(sum(LPCᵢ)), color=:gray, overdraw=false)
	end

	data = matread("../data/Zathurecky2025/data_Interneuron2_e81c98832bc8e641886a02b8dd4516fa.mat")["data"]

	results = data["results"]
	unstable_μs = data["num_unstable"]

	λs, Ts, ω₂s, βs = eachcol(results)
	stable = unstable_μs .== 0

	antiphase = stable .&& (βs .> 0.275) .&& (βs .< 0.725)
	inphase = stable .&& .!antiphase

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
    for i = [1,2,5,6]
        LPCᵢ = LPC_index .== i
        lines!(ax1, LPC_ω₂s[LPCᵢ], LPC_λs[LPCᵢ], color=:black)
    end
    for i = 3:4
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
    for i = 3:4
        LPCᵢ = LPC_index .== i
        lines!(ax2, LPC_ω₂s[LPCᵢ], LPC_λs[LPCᵢ], color=:black)
    end
    for i = [1,2,5,6]
        LPCᵢ = LPC_index .== i
        lines!(ax2, LPC_ω₂s[LPCᵢ], LPC_λs[LPCᵢ], color=:white)
        lines!(ax2, LPC_ω₂s[LPCᵢ], LPC_λs[LPCᵢ], linestyle=:dash, color=:gray)
    end

	linkyaxes!(ax1, ax2)

	return fig
end