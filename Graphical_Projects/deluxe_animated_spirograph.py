import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation

def spirograph(R, r, d, num_points=5000):
    """Generate Spirograph points."""
    theta = np.linspace(0, 2 * np.pi * r / np.gcd(R, r), num_points)
    x = (R - r) * np.cos(theta) + d * np.cos(((R - r) / r) * theta)
    y = (R - r) * np.sin(theta) - d * np.sin(((R - r) / r) * theta)
    return x, y

def lissajous(a, b, delta, num_points=1000):
    """Generate Lissajous curve points."""
    t = np.linspace(0, 2 * np.pi, num_points)
    x = np.sin(a * t + delta)
    y = np.sin(b * t)
    return x * 100, y * 100

def rose_curve(k, num_points=1000):
    """Generate Rose curve points."""
    theta = np.linspace(0, 2 * np.pi, num_points)
    r = np.cos(k * theta)
    x = r * np.cos(theta) * 100
    y = r * np.sin(theta) * 100
    return x, y

# Animation setup
fig, ax = plt.subplots(figsize=(8,8))
ax.set_xlim(-200, 200)
ax.set_ylim(-200, 200)
ax.set_aspect("equal")
ax.set_title("Animated Spirograph and Other Shapes")
line_spiro, = ax.plot([], [], '#dd00dd', linewidth=0.5, label='Spirograph')
line_lissajous, = ax.plot([], [], 'r', linewidth=1, label='Lissajous')
line_rose, = ax.plot([], [], 'g', linewidth=1, label='Rose Curve')

# Shape parameters
R, r, d = 100, 23, 50
x_spiro, y_spiro = spirograph(R, r, d)
x_lissajous, y_lissajous = lissajous(3, 2, np.pi / 2)
x_rose, y_rose = rose_curve(5)

def init():
    line_spiro.set_data([], [])
    line_lissajous.set_data([], [])
    line_rose.set_data([], [])
    return line_spiro, line_lissajous, line_rose

def update(frame):
    line_spiro.set_data(x_spiro[:frame], y_spiro[:frame])
    line_lissajous.set_data(x_lissajous[:frame], y_lissajous[:frame])
    line_rose.set_data(x_rose[:frame], y_rose[:frame])
    return line_spiro, line_lissajous, line_rose

ani = animation.FuncAnimation(fig, update, frames=len(x_spiro), init_func=init, blit=True, interval=0)
plt.legend()
plt.show()
