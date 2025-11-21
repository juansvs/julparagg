# Visualization for the sheep-parasite model

@load "simulation_output.jld2" time_series endstate
# visualization
time = map(x->x/1440, time_series.t)  # convert time to days
# Mean larvae
plot(time, map(mean, time_series.inf_larva_number), label="Mean Infective Larvae", color=:blue)
# Mean sward height
plot(time, map(mean, time_series.sward_height), label="Mean Sward Height", color=:blue)

agentprops = time_series.agent_properties
mat_par_load = [[agentprops[t][i][:mat_par_load] for t in 1:length(agentprops)] for i in 1:5]
imm_par_load = [[agentprops[t][i][:imm_par_load] for t in 1:length(agentprops)] for i in 1:5]
stomach_content = [[agentprops[t][i][:stomach_content] for t in 1:length(agentprops)] for i in 1:5]
plot(time, mat_par_load, label="Mature Parasite Load")
plot(time, imm_par_load, label="Immature Parasite Load")
plot(time, stomach_content, label="stomach_content")

# heatmap animation for sward height over time
anim_sh = @animate for t in 1:length(time_series.sward_height)
    heatmap(time_series.sward_height[t], title="Sward Height at Day $(round(time_series.t[t]/1440, digits=2))", clims=(0,400), color=:Greens)

end
gif(anim_sh, "sward_height_animation.gif", fps=10)

anim_il = @animate for t in 1:length(time_series.inf_larva_number)
    heatmap(time_series.inf_larva_number[t], title="Larvae in pasture at Day $(round(time_series.t[t]/1440, digits=2))")
end
gif(anim_il, "inf_larva_animation.gif", fps=10)