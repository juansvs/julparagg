# src/main.jl

using Agents, Random, Base.Threads, StatsBase
using Distributions: Poisson
using Distributions: Multinomial
include("agents.jl")
include("space.jl")
include("simulation.jl")
include("model.jl")
#include("visualization.jl")

# set simulation parameters
parameters = Dict(
    :num_sheep => 5,
    :arena_side => 78,
    :seed => 10,
    :gamma => 0.00004,
    :max_sward_height => 400,
    :epsilon => 0.00005,
    :mu_l => 0.0001,
    :mu_L => 0.000015,
    :phi => 0.00001776,
    :beta => 0.1,
    :min_sward_height => 50,
    :mu_k => 0.0,
    :Lambda => 0.0,
    :mu_a => 1e-4,
    :mu_A => 2e-5,
    :chi => 0.00003,
    :eta => 0.025,
    :sigma => 1.9e-8,
    :lambda => 2.0,
    :s0 => 2000,
    :fdep => 1,
    :nu => 0.015,
    :inf_prob => 0.4
)

adf, mdf = paramscan(parameters, initialize_model; showprogress = true, 
    n = 60*24*10.0, when = 360.0,
    adata = [:imm_par_load, :mat_par_load, :stomach_content, :immunity_level],
    mdata = [:sward_height, :inf_larva_number, :uninf_larva_number])

function main()
    # Initialize the model
    model = initialize_model(; parameters...)

    # Run the simulation
    simtime = 60*24*15.0  # total simulation time in minutes
    time_series =     run_sim!(model, simtime, 360.0)

    return model, time_series
end

# run the main function and time it
@time endstate, time_series = main()

# write outputs to file
@save "simulation_output.jld2" time_series endstate
