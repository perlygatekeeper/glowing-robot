import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation

def spirograph(R, r, d, num_points=1000):
    """Generate Spirograph points."""
    theta = np.linspace(0, 2 * np.pi * r / np.gcd(R, r), num_points)
    x = (R - r) * np.cos(theta) + d * np.cos(((R - r) / r) * theta)
    y = (R - r) * np.sin(theta) - d * np.sin(((R - r) / r) * theta)
    return x, y

# Basic Spirograph
R, r, d = 100, 30, 50  # Example parameters
x, y = spirograph(R, r, d)

plt.figure(figsize=(6,6))
plt.plot(x, y, 'b')
plt.axis("equal")
plt.title("Basic Spirograph")
plt.show()
