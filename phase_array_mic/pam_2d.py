import numpy as np
import matplotlib.pyplot as plt

# Simulation Parameters
fs = 44100  # Sampling rate (Hz)
c = 343  # Speed of sound (m/s)
grid_size = (4, 4)  # 4x4 microphone array (2D)
num_mics = grid_size[0] * grid_size[1]  # Total microphones
d = 0.1  # Microphone spacing (meters)
duration = 0.01  # Signal duration in seconds
t = np.linspace(0, duration, int(fs * duration), endpoint=False)

# Define sound sources (frequency and direction)
sources = [
    {"freq": 1000, "theta": 30, "phi": 0},   # Target source (1000 Hz, 30° elevation, 0° azimuth)
    {"freq": 2000, "theta": 120, "phi": 180} # Interfering source (2000 Hz, 120° elevation, 180° azimuth)
]

# Generate 2D microphone positions
mic_positions = [(i * d, j * d) for i in range(grid_size[0]) for j in range(grid_size[1])]

# Function to compute time delays
def compute_delays(source):
    theta_rad = np.radians(source["theta"])
    phi_rad = np.radians(source["phi"])
    delays = [
        (x * np.sin(theta_rad) * np.cos(phi_rad) + y * np.sin(theta_rad) * np.sin(phi_rad)) / c
        for x, y in mic_positions
    ]
    return delays

# Generate signals for each source
signals = []
for source in sources:
    wave = np.sin(2 * np.pi * source["freq"] * t)
    delays = compute_delays(source)
    delayed_signals = [np.roll(wave, int(delay * fs)) for delay in delays]
    signals.append(delayed_signals)

# Simulate microphone array capturing both signals + background noise
background_noise = np.random.normal(0, 0.2, size=(num_mics, len(t)))  # Gaussian noise
mic_signals = [signals[0][i] + signals[1][i] + background_noise[i] for i in range(num_mics)]

# Apply beamforming (focus on 30° source)
beamforming_source = sources[0]  # Targeting the 1000 Hz source
beamforming_delays = compute_delays(beamforming_source)
beamformed_signal = np.sum(
    [np.roll(mic_signals[i], -int(beamforming_delays[i] * fs)) for i in range(num_mics)],
    axis=0
)

# Plot results
plt.figure(figsize=(12, 5))
plt.plot(t[:1000], mic_signals[0][:1000], label="Captured Mixed Signal (With Noise)")
plt.plot(t[:1000], beamformed_signal[:1000], label="Beamformed Output (30° Focus)", linestyle="dashed")
plt.xlabel("Time (s)")
plt.ylabel("Amplitude")
plt.legend()
plt.title("2D Array Beamforming: Enhancing 30° Source, Suppressing 120° Source & Noise")
plt.show()
