"""Vanguard 1's orbit, used by BOTH the Blender animation and the on-screen data,
so what the viewer reads always matches what the satellite is doing.

Orbit from Wikipedia (Vanguard 1): perigee 654 km, apogee 3,969 km.
Everything else is derived here with Kepler's laws."""
import math
MU = 398600.4418          # km^3/s^2, Earth
RE = 6371.0               # km, mean Earth radius
RP = RE + 654.0           # perigee radius
RA = RE + 3969.0          # apogee radius
A = (RP + RA) / 2         # semi-major axis
E = (RA - RP) / (RA + RP) # eccentricity
PERIOD = 2 * math.pi * math.sqrt(A**3 / MU)   # seconds

def state(t_real):
    """Position (km, orbit plane, perigee on +x) and speed (km/s) at real time t."""
    M = 2 * math.pi * ((t_real / PERIOD) % 1.0)
    Ecc = M
    for _ in range(30):                       # Newton on Kepler's equation
        Ecc -= (Ecc - E * math.sin(Ecc) - M) / (1 - E * math.cos(Ecc))
    nu = 2 * math.atan2(math.sqrt(1 + E) * math.sin(Ecc / 2),
                        math.sqrt(1 - E) * math.cos(Ecc / 2))
    r = A * (1 - E * math.cos(Ecc))
    v = math.sqrt(MU * (2 / r - 1 / A))
    return r * math.cos(nu), r * math.sin(nu), r, v

if __name__ == "__main__":
    print(f"a={A:.1f} km  e={E:.4f}  period={PERIOD/60:.2f} min")
    print(f"perigee speed {state(0)[3]:.2f} km/s   apogee speed {state(PERIOD/2)[3]:.2f} km/s")
    print(f"altitude range {RP-RE:.0f}-{RA-RE:.0f} km")
