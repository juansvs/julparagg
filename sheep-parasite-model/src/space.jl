module SpaceDynamics

# define functions for patch dynamics
function sward_growth!(pos, model, n)
    model.sward_height[pos] += n
end

function growth_propensity(pos, model)
    return model.gamma * model.sward_height[pos] * (1 - model.sward_height[pos] / model.max_sward_height)
end

function larval_dev!(pos, model, n)
    dev_larvae = min(n, model.uninf_larva_number[pos])
    model.uninf_larva_number[pos] -= dev_larvae
    model.inf_larva_number[pos] += dev_larvae
end

function larval_dev_propensity(pos, model)
    return model.epsilon * model.uninf_larva_number[pos]
end

function death_l!(pos, model, n)
    dead_larvae = min(n, model.uninf_larva_number[pos])
    model.uninf_larva_number[pos] -= dead_larvae
end

function death_l_propensity(pos, model)
    return model.mu_l * model.uninf_larva_number[pos]
end

function death_L!(pos, model, n)
    dead_larvae = min(n, model.inf_larva_number[pos])
    model.inf_larva_number[pos] -= dead_larvae
end

function death_L_propensity(pos, model)
    return model.mu_L * model.inf_larva_number[pos]
end

function feces_decay!(pos, model, n)
    decayed_feces = min(n, model.feces_number[pos])
    model.feces_number[pos] -= decayed_feces
end

function feces_decay_propensity(pos, model)
    return model.phi * model.feces_number[pos]
end
# function to update space properties over time
function update_space_properties!(model)
    # compute timestep from the event queue (as before)
    current_time = abmtime(model)
    _, nexttime = first(abmqueue(model))
    dt = nexttime - current_time

    sh = model.sward_height
    ul = model.uninf_larva_number
    il = model.inf_larva_number
    fn = model.feces_number

    N = length(sh)

    # threaded, batched updates: sample numbers of events per cell using Poisson(propensity * dt)
    @threads for pos in 1:N
        # Sward growth
        propensity = growth_propensity(pos, model)
        if propensity > 0.0
            num_events = rand(Poisson(max(propensity * dt, 0.0)))
            if num_events > 0
                sward_growth!(pos, model, num_events)
            end
        end

        # Larval development (uninfective -> infective)
        propensity = larval_dev_propensity(pos, model)
        if propensity > 0.0
            num_events = rand(Poisson(max(propensity * dt, 0.0)))
            if num_events > 0
                larval_dev!(pos, model, num_events)
            end
        end

        # Death of uninfective larvae
        propensity = death_l_propensity(pos, model)
        if propensity > 0.0
            num_events = rand(Poisson(max(propensity * dt, 0.0)))
            if num_events > 0
                death_l!(pos, model, num_events)
            end
        end

        # Death of infective larvae
        propensity = death_L_propensity(pos, model)
        if propensity > 0.0
            num_events = rand(Poisson(max(propensity * dt, 0.0)))
            if num_events > 0
                death_L!(pos, model, num_events)
            end
        end

        # Feces decay
        propensity = feces_decay_propensity(pos, model)
        if propensity > 0.0
            num_events = rand(Poisson(max(propensity * dt, 0.0)))
            if num_events > 0
                feces_decay!(pos, model, num_events)
            end
        end

        # ensure non-negative counts (thread-safe because each idx is distinct)
        sh[pos] = max(sh[pos], 0)
        ul[pos] = max(ul[pos], 0)
        il[pos] = max(il[pos], 0)
        fn[pos] = max(fn[pos], 0)
    end
end

end # module SpaceDynamics