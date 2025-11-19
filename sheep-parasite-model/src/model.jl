module SheepParasiteModel

using Agents

"""
Struct holding model properties and parameters:
- sward_height: Vector of Int, initial grass height per patch (default 200).
- uninf_larva_number: Vector of Int, number of uninfective larvae per patch (default 0).
- inf_larva_number: Vector of Int, number of infective larvae per patch (default 0).
- feces_number: Vector of Int, number of feces per patch (default 0).
- gamma: Float, sward growth rate.
- max_sward_height: Int, maximum sward height.
- epsilon: Float, larval development rate.
- mu_l: Float, death rate of uninfective larvae.
- mu_L: Float, death rate of infective larvae.
- phi: Float, feces decay rate.
- beta: Float, sheep grazing rate.
- min_sward_height: Int, minimum sward height for grazing.
- mu_k: Float, feces avoidance parameter.
- Lambda: Float, immunity scaling parameter.
- mu_a: Float, death rate of immature parasites.
- mu_A: Float, death rate of mature parasites.
- chi: Float, maturation rate of parasites.
- eta: Float, immunity gain rate.
- sigma: Float, immunity loss rate.
- lambda: Float, egg production rate.
- s0: Int, feces amount per defecation.
- fdep: Float, defecation frequency.
- nu: Float, sheep movement rate.
- inf_prob: Float, probability of infection per infective larva consumed.
"""
struct Properties
    sward_height::Matrix{Int}
    uninf_larva_number::Matrix{Int}
    inf_larva_number::Matrix{Int}
    feces_number::Matrix{Int}
    gamma::Float64
    max_sward_height::Int
    epsilon::Float64
    mu_l::Float64
    mu_L::Float64
    phi::Float64
    beta::Float64
    min_sward_height::Int
    mu_k::Float64
    Lambda::Float64
    mu_a::Float64
    mu_A::Float64
    chi::Float64
    eta::Float64
    sigma::Float64
    lambda::Float64
    s0::Int
    fdep::Float64
    nu::Float64
    inf_prob::Float64
end

# Initialize the model
function initialize_model(num_sheep::Int, arena_side::Int, params::Dict)
    # define space
    space = GridSpace((arena_side, arena_side), periodic = false)

    # define space properties and model parameters

    properties = Properties(
        fill(200, spacesize(space)),
        fill(0, spacesize(space)),
        fill(0, spacesize(space)),
        fill(0, spacesize(space)),
        params["gamma"],
        params["max_sward_height"],
        params["epsilon"],
        params["mu_l"],
        params["mu_L"],
        params["phi"],
        params["beta"],
        params["min_sward_height"],
        params["mu_k"],
        params["Lambda"],
        params["mu_a"],
        params["mu_A"],
        params["chi"],
        params["eta"],
        params["sigma"],
        params["lambda"],
        params["s0"],
        params["fdep"],
        params["nu"],
        params["inf_prob"]
    )

    # define events
    grazing = AgentEvent(; action! = grazing!, propensity = grazing_propensity)
    death_a = AgentEvent(; action! = death_a!, propensity = death_a_propensity)
    death_A = AgentEvent(; action! = death_A!, propensity = death_A_propensity)
    maturation = AgentEvent(; action! = maturation!, propensity = maturation_propensity)
    immunity_gain = AgentEvent(; action! = immunity_gain!, propensity = immunity_gain_propensity)
    immunity_loss = AgentEvent(; action! = immunity_loss!, propensity = immunity_loss_propensity)
    egg_production = AgentEvent(; action! = egg_production!, propensity = egg_production_propensity)
    defecation = AgentEvent(; action! = defecation!, propensity = defecation_propensity)
    movement = AgentEvent(; action! = move!, propensity = move_propensity)
    # create a list of events
    events = (grazing, death_a, death_A, maturation, immunity_gain, 
    immunity_loss, egg_production, defecation, movement)
    
    # initialize the model
    model = EventQueueABM(Sheep, events, space; container = Vector, properties = properties)   
    
    # add agents to the model at random positions
    for _ in 1:num_sheep
        add_agent!(Sheep, model)
    end
    
    # distribute 24000 infective larvae randomly across 20 patches
    num_patches_with_larvae = 20
    total_larvae = 24000
    
    # randomly select 20 patches
    all_patch_indices = collect(1:npositions(model))
    selected_patch_indices = sample(all_patch_indices, num_patches_with_larvae, replace=false)
    
    # randomly distribute larvae among the 20 selected patches
    # Randomly partition total_larvae among selected patches using multinomial
    larvae_distribution = rand(Multinomial(total_larvae, fill(1/num_patches_with_larvae, num_patches_with_larvae)))
    for (idx, larvae_for_patch) in zip(selected_patch_indices, larvae_distribution)
        model.inf_larva_number[idx] = larvae_for_patch
    end
    
    return model
end

# step function that updates space properties and advances the model
function run_sim!(model, t::Float64=24.0)
    while abmtime(model)<t
        update_space_properties!(model)
        step!(model) 
        # save data or visualize at desired intervals
    end
end

end