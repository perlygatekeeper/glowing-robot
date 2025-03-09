import numpy as np
import matplotlib.pyplot as plt

# Simulation Parameters
fs = 44100  # Sampling rate (Hz)
c = 343  # Speed of sound (m/s)
num_mics = 8  # Number of microphones
d = 0.1  # Microphone spacing (meters)
duration = 0.01  # Signal duration in seconds
t = np.linspace(0, duration, int(fs * duration), endpoint=False)

# Define sound sources
sources = [
    {"freq": 1000, "theta": 30},   # First source (1000 Hz, 30°)
    {"freq": 2000, "theta": 120}   # Second source (2000 Hz, 120°)
]

# Generate signals for each source
signals = []
for source in sources:
    wave = np.sin(2 * np.pi * source["freq"] * t)
    delays = [(d * i * np.sin(np.radians(source["theta"]))) / c for i in range(num_mics)]
    delayed_signals = [np.roll(wave, int(delay * fs)) for delay in delays]
    signals.append(delayed_signals)

# Sum both sources at each mic (simulating interference)
mic_signals = [signals[0][i] + signals[1][i] for i in range(num_mics)]

# Apply beamforming (focus on 30° source)
beamforming_theta = 30
beamforming_delays = [(d * i * np.sin(np.radians(beamforming_theta))) / c for i in range(num_mics)]
beamformed_signal = np.sum([np.roll(mic_signals[i], -int(beamforming_delays[i] * fs)) for i in range(num_mics)], axis=0)

# Plot results
plt.figure(figsize=(12, 5))
plt.plot(t[:1000], mic_signals[0][:1000], label="Mixed Signal (Before Beamforming)")
plt.plot(t[:1000], beamformed_signal[:1000], label="Beamformed Output (30° Focus)", linestyle="dashed")
plt.xlabel("Time (s)")
plt.ylabel("Amplitude")
plt.legend()
plt.title("Beamforming Effect: Enhancing 30° Source, Suppressing 120° Source")
plt.show()

