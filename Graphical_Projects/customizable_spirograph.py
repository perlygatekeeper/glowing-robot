import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation

def circle(R, num_points=1000, color='#000000', linewidth=0.5):
    """Generate and plot a Circle."""
    theta = np.linspace(0, 2 * np.pi, num_points)
    x = R * np.cos(theta)
    y = R * np.sin(theta)
    plt.plot(x, y, color=color, linewidth=linewidth)
    return x, y


def spirograph(R, r, d, num_points=4000, color='b', linewidth=1.5):
    """Generate and plot a customizable Spirograph."""
    theta = np.linspace(0, 2 * np.pi * r / np.gcd(R, r), num_points)
    x = (R - r) * np.cos(theta) + d * np.cos(((R - r) / r) * theta)
    y = (R - r) * np.sin(theta) - d * np.sin(((R - r) / r) * theta)
    
    plt.plot(x, y, color=color, linewidth=linewidth)
    return x, y

# Customizable Spirograph
plt.figure(figsize=(6,6))
plt.title("Customizable Spirograph")
plt.axis("equal")

circle( 28, color='#444400', linewidth=0.5)
circle( 50, color='#00ee00', linewidth=0.5)

# Example variations, R r and d
circle( 78, color='#ee8800', linewidth=0.5)
spirograph(  80,  10,  43, color='#0033ee', linewidth=0.5)
spirograph(  80,  10,  20, color='#ee0000', linewidth=0.5)

# spirograph( 125,  25,  99, color='#00ee00', linewidth=0.5)
# spirograph( 125,  25,  45, color='#0000ee', linewidth=0.5)

circle( 150, color='#ee0033', linewidth=0.5)
spirograph( 200,  25, 107, color='#dd00dd', linewidth=0.5)
spirograph( 200,  25,  50, color='#000000', linewidth=0.5)

circle( 282, color='#888888', linewidth=0.5)
plt.show()
