"""
Sundial Generator
Latitude:  40.03° N
Longitude: -83.05° (Columbus, OH area)

Generates a horizontal sundial with:
  - Hour lines calculated from true solar geometry
  - Longitude correction for your timezone offset
  - Gnomon angle equal to latitude
  - SVG output  (sundial.svg)
  - PNG output  (sundial.png) if Pillow is installed

Usage:
    pip install matplotlib numpy
    python sundial.py
"""

import math
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyArrowPatch
import matplotlib.patheffects as pe

# ── Location ──────────────────────────────────────────────────────────────────
LATITUDE_DEG  =  40.03
LONGITUDE_DEG = -83.05
TIMEZONE_OFFSET = -5          # EST (UTC-5); change to -4 for EDT

# Longitude correction: difference between your meridian and the timezone meridian
STANDARD_MERIDIAN = TIMEZONE_OFFSET * 15          # degrees
LONGITUDE_CORRECTION = LONGITUDE_DEG - STANDARD_MERIDIAN  # minutes offset in degrees
# Each degree = 4 minutes of time

LAT = math.radians(LATITUDE_DEG)


# ── Hour-line angle formula ────────────────────────────────────────────────────
# For a horizontal sundial the angle of each hour line from 12-noon (south) is:
#   tan(θ) = sin(latitude) × tan(hour_angle)
# where hour_angle = (hour - 12) × 15°

def hour_line_angle(hour_float: float) -> float:
    """
    Returns the angle (degrees) of the hour line measured clockwise from
    the 12-noon (south) line on a horizontal sundial.
    """
    hour_angle = math.radians((hour_float - 12.0) * 15.0)
    tan_theta = math.sin(LAT) * math.tan(hour_angle)
    return math.degrees(math.atan(tan_theta))


# ── Build the hour lines ───────────────────────────────────────────────────────
# Typical horizontal sundial shows 5 AM – 7 PM solar time
hours = list(range(5, 20))          # 5 … 19 (solar hours)
# Add half-hours for a finer dial
half_hours = [h + 0.5 for h in range(5, 19)]

# Solar noon correction: shift the noon line by the longitude correction
noon_correction_deg = LONGITUDE_CORRECTION   # positive = east of meridian = earlier

def corrected_angle(solar_hour: float) -> float:
    """Angle after applying longitude correction."""
    # Adjust solar hour by longitude correction (each degree = 1/15 hour)
    adj_hour = solar_hour - (noon_correction_deg / 15.0)
    return hour_line_angle(adj_hour)


# ── Plot ───────────────────────────────────────────────────────────────────────
fig, ax = plt.subplots(figsize=(12, 12), facecolor='#F5F0E8')
ax.set_facecolor('#F5F0E8')
ax.set_aspect('equal')
ax.axis('off')

DIAL_RADIUS = 10.0      # visual radius of the dial plate
GX, GY = 0.0, 0.0      # gnomon base (noon line origin)

# ── Draw the dial plate ───────────────────────────────────────────────────────
dial_circle = plt.Circle((GX, GY), DIAL_RADIUS, color='#E8DFC8',
                          zorder=0, linewidth=2, edgecolor='#8B7355')
ax.add_patch(dial_circle)

# Decorative inner ring
inner_ring = plt.Circle((GX, GY), DIAL_RADIUS * 0.92, color='none',
                         linewidth=1, edgecolor='#8B7355', linestyle='--', zorder=1)
ax.add_patch(inner_ring)

# ── Draw the noon (12:00) line ────────────────────────────────────────────────
ax.annotate('', xy=(GX, GY + DIAL_RADIUS * 0.9),
            xytext=(GX, GY - DIAL_RADIUS * 0.9),
            arrowprops=dict(arrowstyle='-', color='#5C4A2A', lw=1.5),
            zorder=2)

# ── Draw hour lines ───────────────────────────────────────────────────────────
label_offset = DIAL_RADIUS * 0.96

for h in hours:
    ang_deg = corrected_angle(h)
    ang_rad = math.radians(ang_deg)

    # Hour lines go from centre outward; east hours are negative angles (right),
    # west hours positive (left) when measuring clockwise from north.
    # Convention: positive east → right side of dial (AM), west → left (PM)
    # The line is drawn symmetrically through the gnomon base.
    dx = math.sin(ang_rad)
    dy = math.cos(ang_rad)

    x1 =  dx * DIAL_RADIUS * 0.9
    y1 =  dy * DIAL_RADIUS * 0.9
    x2 = -dx * DIAL_RADIUS * 0.9
    y2 = -dy * DIAL_RADIUS * 0.9

    # Only draw the half of the line appropriate for AM/PM
    # Hours < 12  → eastern (positive x) half
    # Hours > 12  → western (negative x) half
    # Hours == 12 → full north-south line (already drawn)
    if h == 12:
        continue
    elif h < 12:
        ex, ey = x1, y1
    else:
        ex, ey = x2, y2

    ax.plot([GX, ex], [GY, ey], color='#5C4A2A', linewidth=1.8, zorder=3)

    # Label
    lx = ex / DIAL_RADIUS * label_offset
    ly = ey / DIAL_RADIUS * label_offset
    hour_label = f"{h}" if h <= 12 else f"{h - 12}"
    am_pm = "AM" if h < 12 else ("PM" if h > 12 else "Noon")
    display = f"{hour_label}\n{am_pm}"
    ax.text(lx, ly, display, ha='center', va='center',
            fontsize=9, fontweight='bold', color='#3B2A0E',
            fontfamily='serif', zorder=5)

# ── Half-hour tick marks ───────────────────────────────────────────────────────
for h in half_hours:
    ang_deg = corrected_angle(h)
    ang_rad = math.radians(ang_deg)
    dx = math.sin(ang_rad)
    dy = math.cos(ang_rad)

    if h < 12:
        ex, ey = dx, dy
    else:
        ex, ey = -dx, -dy

    inner_r = DIAL_RADIUS * 0.80
    outer_r = DIAL_RADIUS * 0.88
    ax.plot([ex * inner_r, ex * outer_r],
            [ey * inner_r, ey * outer_r],
            color='#8B7355', linewidth=1.0, zorder=4)

# ── Quarter-hour tick marks ────────────────────────────────────────────────────
for h in [hh + q for hh in range(5, 19) for q in [0.25, 0.75]]:
    if h >= 19:
        continue
    ang_deg = corrected_angle(h)
    ang_rad = math.radians(ang_deg)
    dx = math.sin(ang_rad)
    dy = math.cos(ang_rad)

    if h < 12:
        ex, ey = dx, dy
    else:
        ex, ey = -dx, -dy

    inner_r = DIAL_RADIUS * 0.83
    outer_r = DIAL_RADIUS * 0.88
    ax.plot([ex * inner_r, ex * outer_r],
            [ey * inner_r, ey * outer_r],
            color='#8B7355', linewidth=0.6, linestyle=':', zorder=4)

# ── Draw the gnomon (pointer) shadow symbol ───────────────────────────────────
# The gnomon is a right triangle; its hypotenuse angle = latitude.
# We represent it as a bold north-pointing arrow with the angle labeled.
gnomon_height = DIAL_RADIUS * 0.5
gnomon_tip_y = GY + gnomon_height

ax.annotate('', xy=(GX, gnomon_tip_y), xytext=(GX, GY),
            arrowprops=dict(arrowstyle='->', color='#8B0000', lw=2.5,
                            mutation_scale=20),
            zorder=6)
ax.text(GX + 0.3, gnomon_tip_y * 0.55,
        f'Gnomon\nangle = {LATITUDE_DEG}°',
        ha='left', va='center', fontsize=8, color='#8B0000',
        fontfamily='serif', style='italic', zorder=7)

# ── Cardinal direction labels ─────────────────────────────────────────────────
for label, x, y in [('N', 0, DIAL_RADIUS * 0.97),
                     ('S', 0, -DIAL_RADIUS * 0.97),
                     ('E', DIAL_RADIUS * 0.97, 0),
                     ('W', -DIAL_RADIUS * 0.97, 0)]:
    ax.text(x, y, label, ha='center', va='center',
            fontsize=13, fontweight='bold', color='#3B2A0E',
            fontfamily='serif', zorder=8)

# ── Center dot ────────────────────────────────────────────────────────────────
ax.plot(GX, GY, 'o', color='#3B2A0E', markersize=6, zorder=9)

# ── Title / info block ────────────────────────────────────────────────────────
title_lines = [
    "Horizontal Sundial",
    f"Latitude {LATITUDE_DEG}° N  ·  Longitude {abs(LONGITUDE_DEG)}° W",
    f"Timezone: UTC{TIMEZONE_OFFSET}  ·  Longitude correction: "
    f"{LONGITUDE_CORRECTION:+.2f}°  ({LONGITUDE_CORRECTION * 4:+.1f} min)",
    "Place with N arrow pointing True North · Gnomon points to celestial pole"
]
fig.text(0.5, 0.02, '\n'.join(title_lines),
         ha='center', va='bottom', fontsize=9.5,
         fontfamily='serif', color='#3B2A0E',
         bbox=dict(boxstyle='round,pad=0.4', fc='#E8DFC8', ec='#8B7355', lw=0.8))

# ── Legend ────────────────────────────────────────────────────────────────────
legend_patches = [
    mpatches.Patch(color='#5C4A2A', label='Hour lines'),
    mpatches.Patch(color='#8B7355', label='Half-hour ticks'),
    mpatches.Patch(color='#8B0000', label='Gnomon direction'),
]
ax.legend(handles=legend_patches, loc='upper right',
          fontsize=8, framealpha=0.7,
          facecolor='#F5F0E8', edgecolor='#8B7355')

ax.set_xlim(-DIAL_RADIUS * 1.1, DIAL_RADIUS * 1.1)
ax.set_ylim(-DIAL_RADIUS * 1.1, DIAL_RADIUS * 1.1)

plt.tight_layout(rect=[0, 0.08, 1, 1])

# ── Save ───────────────────────────────────────────────────────────────────────
out_png = "sundial.png"
out_svg = "sundial.svg"

plt.savefig(out_png, dpi=180, bbox_inches='tight', facecolor=fig.get_facecolor())
plt.savefig(out_svg, bbox_inches='tight', facecolor=fig.get_facecolor())
print(f"Saved: {out_png}  |  {out_svg}")
plt.show()


# ── Print the hour-line table ──────────────────────────────────────────────────
print("\n── Hour-Line Angles (measured clockwise from noon/south line) ──")
print(f"{'Solar Hour':<14}{'Solar Angle°':>14}{'Corrected°':>14}")
print("─" * 44)
for h in hours:
    raw   = hour_line_angle(h)
    corr  = corrected_angle(h)
    label = f"{h}:00 ({'AM' if h < 12 else 'PM' if h > 12 else 'Noon'})"
    print(f"{label:<14}{raw:>14.2f}{corr:>14.2f}")
