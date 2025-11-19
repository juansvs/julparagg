using Agents

# define the agent type
@agent struct Sheep(GridAgent{2})
    imm_par_load::Int = 0
    mat_par_load::Int = 0
    immunity_level::Int = 0
    stomach_content::Int = 0
    egg_number::Int = 0
end
