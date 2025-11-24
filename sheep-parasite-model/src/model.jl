"""
Struct holding model properties and parameters:
- sward_height: Matrix of Int, initial grass height per patch (default 200).
- uninf_larva_number: Matrix of Int, number of uninfective larvae per patch (default 0).
- inf_larva_number: Matrix of Int, number of infective larvae per patch (default 0).
- feces_number: Matrix of Int, number of feces per patch (default 0).
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
function initialize_model(; num_sheep = 5, arena_side = 78, seed = 1234, gamma = .00004, 
    max_sward_height = 400, epsilon = 5e-4, mu_l = 1e-4, 
    mu_L = 1.5e-5, phi = 1.776e-5, beta = 0.1, min_sward_height = 50, 
    mu_k = 0.0, Lambda = 0.0, mu_a = 0.01, mu_A = 2e-5, 
    chi = 3e-5, eta = 0.025, sigma = 1.9e-8, lambda = 2.0, 
    s0 = 2000, fdep = 1.0, nu = 0.015, inf_prob = 0.4)
    Random.seed!(seed)
    # define space
    space = GridSpace((arena_side, arena_side), periodic = false)

    # define space properties and model parameters
    properties = Dict(
        :sward_height => fill(200, spacesize(space)),
        :inf_larva_number => fill(0, spacesize(space)),
        :uninf_larva_number => fill(0, spacesize(space)),
        :feces_number => fill(0, spacesize(space)),
        :gamma => gamma,
        :max_sward_height => max_sward_height,
        :epsilon => epsilon,
        :mu_l => mu_l,
        :mu_L => mu_L,
        :phi => phi,
        :beta => beta,
        :min_sward_height => min_sward_height,
        :mu_k => mu_k,
        :Lambda => Lambda,
        :mu_a => mu_a,
        :mu_A => mu_A,
        :chi => chi,
        :eta => eta,
        :sigma => sigma,
        :lambda => lambda,
        :s0 => s0,
        :fdep => fdep,
        :nu => nu,
        :inf_prob => inf_prob
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
