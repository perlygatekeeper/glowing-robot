import matplotlib.pyplot as plt
from maze import maze

# Create a maze with 510x330 cells
maze = maze(510, 330)

# Generate the maze
maze.generate()

# Save the maze as a high-resolution image
plt.figure(figsize=(8.5, 11), dpi=600)  # Letter-size paper at 600 DPI
maze.plot()
plt.axis('off')  # Turn off axes
plt.savefig("maze.png", bbox_inches='tight', pad_inches=0)
plt.close()
