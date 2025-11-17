# src/main.jl

using Agents
include("agents.jl")
include("model.jl")
include("simulation.jl")
include("visualization.jl")

function main()
    # Initialize the model
    model = initialize_model()

    # Run the simulation
    run_simulation(model)

    # Visualize the results
    visualize_results(model)
end

main()