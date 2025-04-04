import numpy as np
from scipy.integrate import solve_ivp
import matplotlib.pyplot as plt
import matplotlib.animation as animation

# Constants
g = 9.81  # Gravity
L1, L2 = 1.3, 0.7  # Lengths of the rods
m1, m2 = 1.0, 1.0  # Masses

def equations(t, y):
    """Returns the derivatives for the double pendulum system."""
    θ1, z1, θ2, z2 = y  # Unpack variables (θ1, θ1', θ2, θ2')
    
    # Compute accelerations using Lagrangian mechanics
    delta = θ2 - θ1
    den1 = (m1 + m2) * L1 - m2 * L1 * np.cos(delta) ** 2
    den2 = (L2 / L1) * den1
    
    θ1_ddot = ((m2 * L1 * z1 ** 2 * np.sin(delta) * np.cos(delta) +
                m2 * g * np.sin(θ2) * np.cos(delta) +
                m2 * L2 * z2 ** 2 * np.sin(delta) -
                (m1 + m2) * g * np.sin(θ1)) / den1)
    
    θ2_ddot = ((-L2 / L1) * z2 ** 2 * np.sin(delta) * np.cos(delta) +
               (m1 + m2) * g * np.sin(θ1) * np.cos(delta) -
               (m1 + m2) * L1 * z1 ** 2 * np.sin(delta) -
               (m1 + m2) * g * np.sin(θ2)) / den2

    return [z1, θ1_ddot, z2, θ2_ddot]

# Initial conditions (θ1, θ1', θ2, θ2')
y0 = [ 2 * np.pi / 2, 0, 1.95 * np.pi / 2, 0]  # Both pendulums start at 90 degrees

# Time array
t_span = (0, 20)  # 10 seconds
t_eval = np.linspace(0, 20, 1000)  # Time steps

# Solve the differential equations
solution = solve_ivp(equations, t_span, y0, t_eval=t_eval, method='RK45')
θ1_vals, θ2_vals = solution.y[0], solution.y[2]

# Convert angles to x, y positions
x1_vals = L1 * np.sin(θ1_vals)
y1_vals = -L1 * np.cos(θ1_vals)
x2_vals = x1_vals + L2 * np.sin(θ2_vals)
y2_vals = y1_vals - L2 * np.cos(θ2_vals)

# Animation setup
fig, ax = plt.subplots(figsize=(6, 6))
ax.set_xlim(-2, 2)
ax.set_ylim(-2, 2)
ax.set_aspect('equal')
ax.grid()

line, = ax.plot([], [], 'o-', lw=2)  # Pendulum arms
trail_length = 50  # Number of previous positions to keep
trail, = ax.plot([], [], 'r-', alpha=0.5)  # Trail effect

def init():
    line.set_data([], [])
    trail.set_data([], [])
    return line, trail

def update(i):
    # Get current pendulum positions
    x1, y1 = x1_vals[i], y1_vals[i]
    x2, y2 = x2_vals[i], y2_vals[i]

    # Update pendulum arms
    line.set_data([0, x1, x2], [0, y1, y2])

    # Update trail
    start = max(0, i - trail_length)  # Keep last `trail_length` points
    trail.set_data(x2_vals[start:i], y2_vals[start:i])

    return line, trail

ani = animation.FuncAnimation(fig, update, frames=len(t_eval), init_func=init, blit=True, interval=30)

plt.show()
