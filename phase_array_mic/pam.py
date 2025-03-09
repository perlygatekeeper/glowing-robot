import numpy as np
import matplotlib.pyplot as plt

# Simulation Parameters
fs = 44100  # Sampling rate (Hz)
c = 343  # Speed of sound (m/s)
num_mics = 8  # Number of microphones
d = 0.1  # Microphone spacing (meters)
theta = 30  # Arrival angle of the sound wave (degrees)
duration = 0.01  # Signal duration in seconds
t = np.linspace(0, duration, int(fs * duration), endpoint=False)

# Generate a simulated sound wave
freq = 1000  # Frequency of sound wave (Hz)
source_signal = np.sin(2 * np.pi * freq * t)

# Compute delays for each microphone
delays = [(d * i * np.sin(np.radians(theta))) / c for i in range(num_mics)]
delayed_signals = [np.roll(source_signal, int(delay * fs)) for delay in delays]

# Sum signals (beamforming)
beamformed_signal = np.sum(delayed_signals, axis=0)

# Plot results
plt.figure(figsize=(10, 5))
plt.plot(t[:1000], source_signal[:1000], label="Original Sound Wave")
plt.plot(t[:1000], beamformed_signal[:1000], label="Beamformed Output", linestyle="dashed")
plt.xlabel("Time (s)")
plt.ylabel("Amplitude")
plt.legend()
plt.title("Beamforming Effect on Sound Signal")
plt.show()
