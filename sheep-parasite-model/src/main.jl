# src/main.jl
using Distributed, ClusterManagers
proc_num = parse(Int, ENV["SLURM_NTASKS"])
addprocs(SlurmManager(proc_num))
nworkers()

@everywhere begin
    using Agents, Random, Base.Threads, StatsBase, JLD2
    using Distributions:Poisson
    using Distributions:Multinomial

    include("agents.jl")
    include("space.jl")
    include("simulation.jl")
    include("model.jl")
end

# set simulation parameters
@everywhere params = Dict(
    "Na" => 30,
    "arena_side" => 100,
   "simtime" => 24*60*60.0,
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
    "mu_a" => 0.0001,
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


@everywhere function main(params)
    # Initialize the model
    model = initialize_model(params["Na"], params["arena_side"], params)

    # Run the simulation
    time_series = run_sim!(model, params["simtime"], 720.0)

   return model, time_series
end

# # run the main function and time it
# @time endstate, time_series = main()

# run in parallel
@time c = pmap(_ -> main(params), 1:20)
# write outputs to file
@save "simulation_output.jld2" c
