module Agents

using Random

# Define the Sheep agent type
mutable struct Sheep
    id::Int
    position::Tuple{Int, Int}
    health::Float64
    parasite_load::Int
    adult_parasites::Int
    last_defecation::Int
end

# Define Parasite Life Stages
mutable struct ParasiteStage0  # Eggs in feces
    position::Tuple{Int, Int}
    age::Int
    development_time::Int
end

mutable struct ParasiteStage1  # Stage 1 larvae
    position::Tuple{Int, Int}
    age::Int
    development_time::Int
end

mutable struct ParasiteStage2  # Stage 2 larvae (infective)
    position::Tuple{Int, Int}
    age::Int
    development_time::Int
end

# helper: sample a stochastic development duration (timesteps) with mean `mean_dur`
# uses exponential waiting-times scaled to have mean `mean_dur`, rounded to integer >= 1
sample_development_time(mean_dur::Float64) = max(1, round(Int, randexp() * mean_dur))

function move!(sheep::Sheep, grid_size::Tuple{Int, Int})
    # Random movement to adjacent cells
    directions = [(0, 1), (1, 0), (0, -1), (-1, 0), (0, 0)]  # Include no movement
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
        return true  # Indicate that defecation occurred
    end
    return false  # No defecation
end

function check_grass_for_larvae(position::Tuple{Int, Int}, grass::Dict)
    # Check if there are larvae in the current cell
    if haskey(grass, position)
        larvae_count = length(grass[position])
        return larvae_count > 0
    end
    return false
end

function acquire_parasite!(sheep::Sheep, position::Tuple{Int, Int}, grass::Dict, larvae_acquisition_rate::Float64)
    # Only acquire if larvae are present in the current cell
    if check_grass_for_larvae(position, grass) && rand() < larvae_acquisition_rate
        sheep.parasite_load += 1  # Increase parasite load
        return true
    end
    return false
end

# Update parasite lifecycle in the environment (eggs -> L1 -> L2) with stochastic durations.
# grass is Dict{Tuple{Int,Int}, Vector{Any}} holding ParasiteStage0/1/2 objects.
# eggs_to_L1_mean and L1_to_L2_mean are mean durations (timesteps, Float64).
function update_parasite_lifecycle!(grass::Dict{Tuple{Int,Int}, Vector{Any}}, eggs_to_L1_mean::Float64, L1_to_L2_mean::Float64)
    for (pos, items) in pairs(grass)
        updated = Vector{Any}()
        for p in items
            # age the parasite if it has an age field
            if getfield(typeof(p), :age) !== nothing
                p.age += 1
            end

            if p isa ParasiteStage0
                # transition to stage 1 when age reaches this egg's development_time
                if p.age >= p.development_time
                    # sample a stochastic duration for L1 -> L2
                    l1_dev = sample_development_time(L1_to_L2_mean)
                    push!(updated, ParasiteStage1(pos, 0, l1_dev))
                else
                    push!(updated, p)
                end

            elseif p isa ParasiteStage1
                # transition to stage 2 when age reaches this L1's development_time
                if p.age >= p.development_time
                    # Stage2 development_time can represent how long it remains viable on grass;
                    # sample or set to 0 if not used
                    l2_viability = sample_development_time( L1_to_L2_mean )  # reuse mean or provide separate mean if desired
                    push!(updated, ParasiteStage2(pos, 0, l2_viability))
                else
                    push!(updated, p)
                end

            elseif p isa ParasiteStage2
                # keep stage2; if you want them to die after development_time, enforce here
                if p.development_time > 0 && p.age >= p.development_time
                    # drop (do not push) -> parasite expired on pasture
                else
                    push!(updated, p)
                end

            else
                # unknown object, keep as-is
                push!(updated, p)
            end
        end
        grass[pos] = updated
    end
end

end  # module Agents