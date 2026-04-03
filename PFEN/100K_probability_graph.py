import numpy as np
import matplotlib.pyplot as plt

p = 1 / 230258

k = np.arange(0, 1000000)
F = 1 - (1 - p)**k

plt.plot(k, F)
plt.xlabel("k (numbers tested)")
plt.ylabel("Cumulative probability of finding a prime")
plt.title("Probability of Finding a Prime Within k Steps")
plt.grid()
plt.show()
