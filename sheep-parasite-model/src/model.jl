export initialize_model
using Random: seed!

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
