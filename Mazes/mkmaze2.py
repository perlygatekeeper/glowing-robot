from maze.maze import create_maze, svg_render

# Generate a maze
# maze = create_maze(width=510, height=330, density=0.7, add_a_loop=False)
maze = create_maze(width=15, height=33, density=0.7, add_a_loop=False)


# Save the maze as an SVG file
svg_render(maze, "maze.svg")
