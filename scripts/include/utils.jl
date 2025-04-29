using Peaks

function match_to_closest(old_numbering, old_values, new_values)
    new_numbering = collect(1:length(new_values))
    closest_indices = Int[]
    closest_diffs = Float64[]

    if isempty(old_values)
        return new_numbering
    end

    for new_value in new_values
        diffs = abs.(old_values .- new_value)
        closest_diff, closest_index = findmin(diffs)
        push!(closest_indices, closest_index)
        push!(closest_diffs, closest_diff)
    end

    reordering = sortperm(closest_diffs)
    closest_indices = closest_indices[reordering]
    reordered = new_numbering[reordering]

    for (i, do_index) in enumerate(reordered)
        to_index = closest_indices[i]

        is_first = count(x -> x == to_index, closest_indices[1:i]) == 1

        if i <= length(old_numbering)
            if is_first
                new_numbering[do_index] = old_numbering[to_index]
            else
                new_numbering[do_index] = reordered[i]
            end
        else
            new_numbering[do_index] = i
        end
    end

    return new_numbering
end

function estimate_lpc(beta, lambda, period, par_free, num_unstable)
    # Sort beta and reorder associated arrays
    sorted_indices = sortperm(beta)
    beta = beta[sorted_indices]
    par_free = par_free[sorted_indices]
    lambda = lambda[sorted_indices]
    period = period[sorted_indices]
    num_unstable = num_unstable[sorted_indices]

    # Locate peaks and troughs of par_free
    ind_maxs = argmaxima(par_free)
    ind_mins = argminima(par_free)
    ind_1 = sort(vcat(ind_maxs, ind_mins))
    LPCs = beta[ind_1]

    # Determine stability
    ind_2 = vcat(ind_1, length(par_free))
    ind_centers = round.(Int, (ind_2[1:end-1] .+ ind_2[2:end]) ./ 2)
    interval_unst = num_unstable[ind_centers] .> 0

    # Identify stability switches
    only_take_peaks = findall(diff(vcat(num_unstable[1], interval_unst)) .!= 0)

    # Extract LPC values at the identified points
    beta_LPC = LPCs[only_take_peaks]
    lambda_LPC = lambda[ind_1[only_take_peaks]]
    period_LPC = period[ind_1[only_take_peaks]]
    par_free_LPC = par_free[ind_1[only_take_peaks]]

    return lambda_LPC, beta_LPC, period_LPC, par_free_LPC
end
