# src/main.jl

using Agents, Random, Base.Threads, StatsBase, JLD2, Plots
using Distributions:Poisson
using Distributions:Multinomial

include("agents.jl")
include("space.jl")
include("simulation.jl")
include("model.jl")
include("visualization.jl")

# set simulation parameters
params = Dict(
    "gamma" => 0.00004,
    "max_sward_height" => 400,
    "epsilon" => 0.00005,
    "mu_l" => 0.0001,
    "mu_L" => 0.000015,
    "phi" => 0.00001776,
    "beta" => 0.1,
    "min_sward_height" => 50,
    "mu_k" => 0.0,
    "Lambda" => 1.0,
    "mu_a" => 0.01,
    "mu_A" => 2e-5,
    "chi" => 0.00003,
    "eta" => 0.025,
    "sigma" => 1.9e-8,
    "lambda" => 2.0,
    "s0" => 2000,
    "fdep" => 1,
    "nu" => 0.015,
    "inf_prob" => 0.4
)

function main()
    # Initialize the model
    model = initialize_model(10, 78, params)

    # Run the simulation
    simtime = 60*24*15.0  # total simulation time in hours
    run_sim!(model, simtime)

    # Visualize the results
    # visualize_results(model)
    return model
end

out = main()