"""
Fig. blast_velocidad (§7) — El espacio velocidad / sensibilidad.

Esta figura TIENE que verse esquemática (instrucciones §3): el pie dice que las
posiciones son aproximadas, así que no puede aparentar una medición. Por eso:

  - Sin números en los ejes. Sólo dirección: "más sensible →", "más rápido ↑".
  - Sin rejilla, sin marcas de escala, sin barras de error.
  - DIAMOND y MMseqs2 se dibujan como CURVAS DE MODOS (fast → ultra-sensitive),
    no como puntos: no tienen una velocidad, tienen un dial. Eso refuerza el
    párrafo del capítulo sobre citar los números con versión y modo.

En el espíritu de Buchfink et al. 2021 y Steinegger & Söding 2017; no reproduce
sus figuras. Regenerar:  python figuras/blast_velocidad.py
"""
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch

import estilo

# Posiciones cualitativas (x = sensibilidad, y = velocidad ×BLAST). El eje y es
# log SOLO para espaciar por orden de magnitud; no se muestran sus números.
SW = (0.90, 0.22)
BLAST = (0.71, 1.0)
DIAMOND = [(0.46, 1200), (0.57, 200), (0.66, 40), (0.72, 9)]   # fast → ultra
MMSEQS = [(0.52, 2600), (0.62, 380), (0.70, 65), (0.77, 15)]


def _curva(ax, pts, color, nombre, ny):
    xs, ys = zip(*pts)
    ax.plot(xs, ys, color=color, lw=2.2, zorder=3)
    ax.scatter(xs, ys, s=26, color=color, zorder=4, ec="white", lw=0.8)
    ax.text(xs[0] - 0.015, ys[0], "fast", ha="right", va="center", fontsize=8,
            color=color, style="italic")
    ax.text(xs[-1] + 0.012, ys[-1] * 0.7, "ultra-sensitive", ha="left", va="center",
            fontsize=8, color=color, style="italic")
    ax.text(xs[1], ys[1] * ny, nombre, ha="center", va="bottom", fontsize=11,
            color=color, fontweight="bold")


def construir():
    estilo.configurar()
    fig, ax = plt.subplots(figsize=(7.6, 5.2))

    # Nivel de referencia de BLAST (1×), tenue.
    ax.axhline(BLAST[1], color=estilo.TEAL, ls=":", lw=1.1, alpha=0.55, zorder=1)

    _curva(ax, DIAMOND, estilo.AMBAR, "DIAMOND", 2.4)
    _curva(ax, MMSEQS, estilo.VERDE, "MMseqs2", 2.4)

    ax.scatter(*SW, s=150, color=estilo.GRIS, zorder=5, ec="white", lw=1.5)
    ax.text(SW[0], SW[1] * 3.0, "Smith–Waterman", ha="center", va="bottom",
            fontsize=10.5, color=estilo.GRIS, fontweight="bold")
    ax.text(SW[0], SW[1] * 1.7, "referencia de sensibilidad", ha="center", va="bottom",
            fontsize=8.2, color=estilo.GRIS, style="italic")

    ax.scatter(*BLAST, s=150, color=estilo.TEAL, zorder=5, ec="white", lw=1.5)
    ax.text(BLAST[0] - 0.02, BLAST[1], "BLAST · 1×", ha="right", va="center",
            fontsize=10.5, color=estilo.TEAL, fontweight="bold")

    # Ejes como flechas de dirección, sin números.
    ax.set_yscale("log")
    ax.set_xlim(0.35, 1.0)
    ax.set_ylim(0.06, 6000)
    ax.set_xticks([])
    ax.set_yticks([])
    ax.minorticks_off()                     # el log deja ticks menores: fuera
    ax.tick_params(which="both", length=0)  # nada de marcas de escala
    for lado in ("top", "right", "bottom", "left"):
        ax.spines[lado].set_visible(False)
    ax.add_patch(FancyArrowPatch((0.36, 0.06), (0.99, 0.06), arrowstyle="-|>",
                                 mutation_scale=16, color=estilo.TEXTO, lw=1.4,
                                 clip_on=False))
    ax.text(0.98, 0.048, "más sensible →", ha="right", va="top", fontsize=10)
    ax.add_patch(FancyArrowPatch((0.36, 0.07), (0.36, 5500), arrowstyle="-|>",
                                 mutation_scale=16, color=estilo.TEXTO, lw=1.4,
                                 clip_on=False))
    ax.text(0.345, 5000, "más rápido ↑", ha="left", va="top", fontsize=10, rotation=90)

    ax.text(0.99, 700, "en el espíritu de Buchfink et al. 2021\ny Steinegger & Söding 2017",
            ha="right", va="top", fontsize=7.6, color=estilo.GRIS, style="italic")
    fig.tight_layout()
    return fig


if __name__ == "__main__":
    estilo.guardar(construir(), "blast_velocidad")
