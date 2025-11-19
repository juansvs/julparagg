module SheepParasiteModel

using Agents

# Define the grid size for the pasture
const GRID_SIZE = 20

# Define the model
mutable struct PastureModel
    sheep::Vector{Sheep}
    parasites::Vector{Parasite}
    grid::Array{Int, 2}  # Represents the pasture grid
end

# Initialize the model
function initialize_model(num_sheep::Int, num_parasites::Int)
    sheep = [Sheep(i, (rand(1:GRID_SIZE), rand(1:GRID_SIZE)), 100.0, 0) for i in 1:num_sheep]
    parasites = [Parasite(1, (rand(1:GRID_SIZE), rand(1:GRID_SIZE))) for _ in 1:num_parasites]
    grid = zeros(Int, GRID_SIZE, GRID_SIZE)
    return PastureModel(sheep, parasites, grid)
end

# Update the model state
function update_model!(model::PastureModel)
    # Logic for updating sheep and parasites goes here
end

end