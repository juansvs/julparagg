module Agents

using Random

# Define the Sheep agent type
struct Sheep
    id::Int
    position::Tuple{Int, Int}
    health::Float64
    parasite_load::Int
end

function move!(sheep::Sheep, grid_size::Tuple{Int, Int})
    # Random movement to adjacent cells
    directions = [(0, 1), (1, 0), (0, -1), (-1, 0)]
    direction = rand(directions)
    new_position = (sheep.position[1] + direction[1], sheep.position[2] + direction[2])
    
    # Ensure the new position is within grid bounds
    new_position = (max(1, min(new_position[1], grid_size[1])), 
                    max(1, min(new_position[2], grid_size[2])))
    
    sheep.position = new_position
end

function defecate!(sheep::Sheep, defecation_rate::Float64)
    # Defecation occurs based on a random chance
    if rand() < defecation_rate
        # Logic for depositing parasites (e.g., eggs)
        return true  # Indicate that defecation occurred
    end
    return false  # No defecation
end

function acquire_parasite!(sheep::Sheep, larvae_acquisition_rate::Float64)
    # Logic for acquiring larvae from grass
    if rand() < larvae_acquisition_rate
        sheep.parasite_load += 1  # Increase parasite load
    end
end

end  # module Agents