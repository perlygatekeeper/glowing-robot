import numpy as np
import matplotlib.pyplot as plt

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
    return x * 100, y * 100  # Scale for visibility

def rose_curve(k, num_points=3000):
    """Generate Rose curve points."""
    theta = np.linspace(0, 2 * np.pi, num_points)
    r = np.cos(k * theta)
    x = r * np.cos(theta) * 100
    y = r * np.sin(theta) * 100
    return x, y

# Generate points for each shape
R, r, d = 100, 49, 60
x_spiro, y_spiro = spirograph(R, r, d)
x_lissajous, y_lissajous = lissajous(3, 2, np.pi / 2)
x_rose, y_rose = rose_curve(13)

# Create a static plot
plt.figure(figsize=(4, 4))
plt.plot(x_spiro, y_spiro, '#dd00dd', linewidth=0.5, label='Spirograph')
plt.plot(x_lissajous, y_lissajous, 'r', linewidth=1, label='Lissajous')
plt.plot(x_rose, y_rose, 'g', linewidth=0.5, label='Rose Curve')

plt.title("Static Spirograph, Lissajous, and Rose Curves")
plt.axis("equal")
plt.legend()
plt.show()
