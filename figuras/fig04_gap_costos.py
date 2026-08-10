"""
Fig. 4 — Curvas de penalización de gap.

Tres modelos de costo γ(k) en función de la longitud del gap k:
  - lineal          γ = k·d
  - afín            γ = a + k·e          (apertura cara, extensión barata)
  - afín de 2 piezas γ = mín(afín1, afín2)  (como minimap2)

La lectura que tiene que saltar: para gaps largos, la lineal cobra de más — un
indel largo suele ser un solo evento, no k eventos.

Regenerar:  python figuras/fig04_gap_costos.py
"""
import numpy as np
import matplotlib.pyplot as plt

import estilo

# Parámetros (anotados en la propia figura).
D = 1.0                    # lineal: costo por residuo
A, E = 3.0, 0.4            # afín: apertura, extensión
A1, E1 = 3.0, 0.4          # afín 2 piezas, tramo corto
A2, E2 = 5.5, 0.12         # afín 2 piezas, tramo largo


def construir():
    estilo.configurar()
    k = np.arange(0, 16)
    lineal = D * k
    afin = np.where(k == 0, 0.0, A + E * k)
    dos = np.where(k == 0, 0.0, np.minimum(A1 + E1 * k, A2 + E2 * k))

    fig, ax = plt.subplots(figsize=(7.2, 4.5))
    ax.plot(k, lineal, color=estilo.TEAL, lw=2.6, marker="o", ms=4,
            label="lineal:  γ = k·d   (d = 1)")
    ax.plot(k[1:], afin[1:], color=estilo.AMBAR, lw=2.6, marker="o", ms=4,
            label="afín:  γ = a + k·e   (a = 3, e = 0.4)")
    ax.plot(k[1:], dos[1:], color=estilo.VERDE, lw=2.6, marker="o", ms=4,
            label="afín 2 piezas:  mín(3 + 0.4k,  5.5 + 0.12k)")

    # La brecha en gaps largos: la lineal cobra de más.
    kx = 14
    yl, ya = D * kx, A + E * kx
    ax.annotate("", xy=(kx, yl), xytext=(kx, ya),
                arrowprops=dict(arrowstyle="<->", color=estilo.GRIS, lw=1.3))
    ax.text(kx - 0.4, (yl + ya) / 2, "la lineal\ncobra de más", ha="right",
            va="center", fontsize=9.5, color=estilo.GRIS, style="italic")

    ax.set_xlabel("longitud del gap  $k$", fontsize=11)
    ax.set_ylabel("costo  γ($k$)", fontsize=11)
    ax.set_xlim(-0.4, 15.6)
    ax.set_ylim(-0.5, 16)
    ax.set_xticks(range(0, 16, 2))
    ax.grid(True, color=estilo.GRIS, alpha=0.18, lw=0.7)
    for lado in ("top", "right"):
        ax.spines[lado].set_visible(False)
    ax.legend(loc="upper left", fontsize=9.5, frameon=False)
    fig.tight_layout()
    return fig


if __name__ == "__main__":
    estilo.guardar(construir(), "fig04_gap_costos")
