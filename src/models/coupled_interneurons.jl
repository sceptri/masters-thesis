module CoupledInterneurons
function model(dx, x, h, p, t)
    V₁, h₁, n₁, V₂, h₂, n₂ = x
    C₁, C₂, I, gL, EL, gNa, ENa, gK, EK, λ, τ = p
    Vh₁, _, _, Vh₂, _, _ = h(p, t - τ)

    dx[1] = 1 / C₁ * (I - gL * (V₁ - EL) - gNa / (1 + exp(-.8e-1 * V₁ - 2.08))^3 * h₁ * (V₁ - ENa) - gK * n₁^4 * (V₁ - EK) - λ * (V₁ - Vh₂))
    dx[2] = 1.666666667 * (1 / (1 + exp(0.13 * V₁ + 4.94)) - h₁) * (1 + exp(-0.12 * V₁ - 8.04))
    dx[3] = (1 / (1 + exp(-.45e-1 * V₁ - 0.450)) - n₁) / (0.5 + 2 / (1 + exp(.45e-1 * V₁ - 2.250)))

    dx[4] = 1 / C₂ * (I - gL * (V₂ - EL) - gNa / (1 + exp(-.8e-1 * V₂ - 2.08))^3 * h₂ * (V₂ - ENa) - gK * n₂^4 * (V₂ - EK) - λ * (V₂ - Vh₁))
    dx[5] = 1.666666667 * (1 / (1 + exp(0.13 * V₂ + 4.94)) - h₂) * (1 + exp(-0.12 * V₂ - 8.04))
    dx[6] = (1 / (1 + exp(-.45e-1 * V₂ - 0.450)) - n₂) / (0.5 + 2 / (1 + exp(.45e-1 * V₂ - 2.250)))
end

params(; λ=0, C₁=1, C₂=1, τ=0.01) =
    (C₁, C₂, 24, 0.1, -60, 30, 45, 20, -80, λ, τ)
end