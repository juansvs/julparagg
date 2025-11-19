# define functions for sheep dynamics
function grazing!(agent, model)
    pos = CartesianIndex(agent.pos)
    
    consumed_inf = floor(Int, model.inf_larva_number[pos] / model.sward_height[pos])
    consumed_uninf = floor(Int, model.uninf_larva_number[pos] / model.sward_height[pos])
    
    model.inf_larva_number[pos] -= consumed_inf
    model.uninf_larva_number[pos] -= consumed_uninf
    
    agent.imm_par_load += floor(Int, model.inf_prob * consumed_inf)
    agent.stomach_content += 1
    model.sward_height[pos] -= 1
    agent.immunity_level += consumed_inf
end

function grazing_propensity(agent, model)
    pos = CartesianIndex(agent.pos)
    return model.beta * (model.sward_height[pos] - model.min_sward_height) * exp(-model.mu_k * model.feces_number[pos] * (agent.imm_par_load + agent.mat_par_load) / (1 + agent.immunity_level) * model.Lambda)
end

function death_a!(agent, model)
    dead_imm_parasites = min(1, agent.imm_par_load)
    agent.imm_par_load -= dead_imm_parasites
end

function death_a_propensity(agent, model)
    return model.mu_a*agent.imm_par_load
end

function death_A!(agent, model)
    dead_mat_parasites = min(1, agent.mat_par_load)
    agent.mat_par_load -= dead_mat_parasites
end

function death_A_propensity(agent, model)
    return model.mu_A*agent.mat_par_load
end

function maturation!(agent, model)
    maturing_parasites = min(1, agent.imm_par_load)
    agent.mat_par_load += maturing_parasites
    agent.imm_par_load -= maturing_parasites
end

function maturation_propensity(agent, model)
    return model.chi*agent.imm_par_load
end

function immunity_gain!(agent, model)
    agent.immunity_level += 1
end

function immunity_gain_propensity(agent, model)
    return model.eta*(agent.mat_par_load+agent.imm_par_load)
end

function immunity_loss!(agent, model)
    immun_lost = min(1, agent.immunity_level)
    agent.immunity_level -= immun_lost
end

function immunity_loss_propensity(agent, model)
    return model.sigma*agent.immunity_level
end

function egg_production!(agent, model)
    agent.egg_number += 1
end

function egg_production_propensity(agent, model)
    return model.lambda*agent.mat_par_load/2
end

function defecation!(agent, model)
    pos = CartesianIndex(agent.pos)
    s0 = model.s0
    prop = s0 / agent.stomach_content * agent.egg_number
    model.feces_number[pos] += s0
    agent.egg_number -= prop
    model.uninf_larva_number[pos] += prop
    agent.stomach_content -= s0
end

function defecation_propensity(agent, model)
    if agent.stomach_content>model.s0
        return model.fdep*(agent.stomach_content-model.s0)
    else
        return 0.0
    end
end

# movement function
function move!(agent, model)
    randomwalk!(agent, model)
end

function move_propensity(agent, model)
    return model.nu
end

# Function to run the simulation loop
# step function that updates space properties and advances the model
function run_sim!(model, t::Float64=24.0)
    step!(model)  # initial step
    while abmtime(model)<t
        update_space_properties!(model)
        step!(model) 
        # save data or visualize at desired intervals
    end
end

