# A Schelling Simulation

Install the packages in `Project.toml`. Run the `schelling_sim.jl` to produce the gif!

At this moment this is how the algorithm implemented here works:

1. Initialize a matrix of 0s (empty cells), 1s (group 1), and 2s at random.
2. Check how many people are happy according to the `kindshare_thresh` argument in `Game`<sup>1</sup>
3. Move all the unhappy individuals to empty cells
4. If:
- a given threshold of people are happy (by defualt 100% but can change it using `board_happy_thresh` argument in `simulate`) - end the game.
- else go back to step 2.

# End Notes
- <sup>1</sup> Individuals are happy if a certain percentage of their neighbours are of the same group as they are. If the share of squares (including empty ones!) around them exceeds `kindshare_thresh`, they are happy.
