# define functions for sheep dynamics
function grazing!(agent, model)
    pos = CartesianIndex(agent.pos)
    il = model.inf_larva_number[pos]
    ul = model.uninf_larva_number[pos]
    sh = model.sward_height[pos]
    if il>0
        consumed_inf = floor(Int, il/sh)
    model.inf_larva_number[pos] -= consumed_inf
        agent.imm_par_load += floor(Int, model.inf_prob * consumed_inf)
        agent.immunity_level += consumed_inf
    end
    if ul>0
        consumed_uninf = floor(Int, ul/sh)
    model.uninf_larva_number[pos] -= consumed_uninf
    end
    
    agent.stomach_content += 1
    model.sward_height[pos] -= 1
end

function grazing_propensity(agent, model)
    pos = CartesianIndex(agent.pos)
    return model.beta * (model.sward_height[pos] - model.min_sward_height) * exp(-model.mu_k * model.feces_number[pos] * (agent.imm_par_load + agent.mat_par_load) ^ model.Lambda)
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
    agent.mat_par_load += 1
    agent.imm_par_load -= 1
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
    agent.immunity_level -= 1
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
    prop = floor(s0 / agent.stomach_content * agent.egg_number)
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
    move_agent!(agent, agent.dest, model)
end

function move_propensity(agent, model)
    neighbors = collect(nearby_positions(agent, model))
    wts = [model.sward_height[CartesianIndex(n)] for n in neighbors]
    idx = wsample(wts)
    hj = wts[idx]
    agent.dest = neighbors[idx]
    return model.nu*hj/length(wts)
end


function save_state(outobj, model::AgentBasedModel, freq::Float64=360.0)
    # check if time has advanced by freq minutes and is a new minute
    _, v = first(abmqueue(model))
    nxt = floor(v)
    ct = floor(abmtime(model))
    if (nxt%freq == 0) && (nxt>ct)
        props = abmproperties(model)
        agentprops = [(id=a.id, imm_par_load=a.imm_par_load, mat_par_load=a.mat_par_load,
            immunity_level=a.immunity_level, egg_number=a.egg_number,
            stomach_content=a.stomach_content) for a in allagents(model)]
        sh = copy(props.sward_height)
        ul = copy(props.uninf_larva_number)
        il = copy(props.inf_larva_number)
        fn = copy(props.feces_number)
        push!(outobj.t, nxt)
        push!(outobj.sward_height, sh)
        push!(outobj.uninf_larva_number, ul)
        push!(outobj.inf_larva_number, il)
        push!(outobj.feces_number, fn)    
        push!(outobj.agent_properties, agentprops)
    end
end

# Function to run the simulation loop
# step function that updates space properties and advances the model
function run_sim!(model::AgentBasedModel, t::Float64=1440.0, sfreq::Float64=360.0)
    # create output object
    outobj = (
        t = Vector{Int64}(),
        sward_height = Vector{Matrix{Int64}}(),
        uninf_larva_number = Vector{Matrix{Int64}}(),
        inf_larva_number = Vector{Matrix{Int64}}(),
        feces_number = Vector{Matrix{Int64}}(),
        agent_properties = Vector{Vector{NamedTuple}}()
    )
    step!(model)  # initial step
    while abmtime(model)<t
        update_space_properties!(model)
        step!(model) 
        # save data at specified intervals
        save_state(outobj, model, sfreq)
    end
    return outobj
end

