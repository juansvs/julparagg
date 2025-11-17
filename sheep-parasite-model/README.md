# Sheep Parasite Model

This project implements an individual-based model of sheep in a pasture that acquires and deposits parasites. The model simulates the interactions between sheep and parasites, including the movement of sheep, defecation events, and the lifecycle of parasites from eggs to larvae and adults.

## Overview

The model consists of the following components:

- **Agents**: The model includes two main types of agents: sheep and parasites. Sheep move randomly within a grid, acquire larvae from the grass, and deposit eggs through defecation. Parasites develop through various stages, from eggs to larvae and then to adults.

- **Simulation**: The simulation runs over discrete time steps, where random events such as movement and defecation occur based on defined rates. The lifecycle of the parasites is also tracked, including their development stages and reproduction within the sheep hosts.

- **Visualization**: The results of the simulation can be visualized to understand the dynamics of sheep and parasite populations over time.

## Files

- `src/main.jl`: Entry point for the simulation. Initializes the model and runs the simulation.
- `src/agents.jl`: Defines the sheep and parasite agents, including their properties and behaviors.
- `src/model.jl`: Contains the core model logic, managing the pasture grid and agent interactions.
- `src/simulation.jl`: Handles the simulation loop and progression of events.
- `src/visualization.jl`: Visualizes the simulation results and dynamics.

## Data Output

The simulation results are stored in `data/results.csv`, which includes metrics such as the number of sheep, parasite stages, and other relevant statistics over time.

## Instructions

To run the simulation, ensure you have Julia installed along with the required packages specified in `Project.toml`. Execute the `main.jl` file to start the simulation and generate results.

## License

This project is licensed under the MIT License.