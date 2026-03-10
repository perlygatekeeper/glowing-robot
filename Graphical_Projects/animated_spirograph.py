import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation

def spirograph(R, r, d, num_points=1000):
    """Generate Spirograph points."""
    theta = np.linspace(0, 2 * np.pi * r / np.gcd(R, r), num_points)
    x = (R - r) * np.cos(theta) + d * np.cos(((R - r) / r) * theta)
    y = (R - r) * np.sin(theta) - d * np.sin(((R - r) / r) * theta)
    return x, y

# Animation setup
fig, ax = plt.subplots(figsize=(6,6))
ax.set_xlim(-120, 120)
ax.set_ylim(-120, 120)
ax.set_aspect("equal")
ax.set_title("Animated Spirograph")
line, = ax.plot([], [], 'b', linewidth=1.5)

# Spirograph parameters
R, r, d = 100, 30, 50
x, y = spirograph(R, r, d)

def init():
    line.set_data([], [])
    return line,

def update(frame):
    line.set_data(x[:frame], y[:frame])
    return line,

ani = animation.FuncAnimation(fig, update, frames=len(x), init_func=init, blit=True, interval=1)
plt.show()
