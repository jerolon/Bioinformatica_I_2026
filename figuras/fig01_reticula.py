"""
Fig. 1 — La retícula y los tres movimientos.

La entrada del capítulo. Sin números: es sobre estructura, no sobre scores.
  - Panel izquierdo: una celda recibe los tres movimientos posibles, cada flecha
    etiquetada (alinear, gap en A, gap en B).
  - Panel derecho: dos caminos completos de esquina a esquina; cada camino es un
    alineamiento distinto.

Regenerar:  python figuras/fig01_reticula.py
"""
import matplotlib.pyplot as plt

import estilo
from estilo import centro


# A = secuencia horizontal (columnas). B = secuencia vertical (filas).
# Dirección de los gaps, sin trampa (es donde más se confunde la gente):
#   flecha vertical   (viene de arriba)     -> avanza B, hueco en A -> "gap en A"
#   flecha horizontal (viene de la izq.)    -> avanza A, hueco en B -> "gap en B"


def _panel_movimientos(ax):
    for i in range(3):
        for j in range(3):
            estilo.celda(ax, i, j, borde=estilo.GRIS, lw=1.0)

    di, dj = 1, 1
    estilo.celda(ax, di, dj, relleno=estilo.FONDO_CELDA, borde=estilo.TEAL, lw=2.0, z=3)
    for origen, color in (((0, 0), estilo.VERDE),     # diagonal
                          ((0, 1), estilo.AMBAR),     # arriba
                          ((1, 0), estilo.TEAL)):     # izquierda
        estilo.celda(ax, *origen, borde=estilo.GRIS, lw=1.0, z=3)
        estilo.flecha(ax, origen, (di, dj), color=color, lw=2.6, encoge=0.20, z=5)

    xd, yd = centro(di, dj)
    ax.text(xd - 0.30, yd + 0.42, "alinear", color=estilo.VERDE, rotation=-45,
            ha="center", va="center", fontsize=11, fontweight="bold", zorder=6)
    ax.text(xd + 0.14, yd + 0.42, "gap en A", color=estilo.AMBAR,
            ha="left", va="center", fontsize=11, fontweight="bold", zorder=6)
    ax.text(xd - 0.20, yd - 0.44, "gap en B", color=estilo.TEAL,
            ha="center", va="top", fontsize=11, fontweight="bold", zorder=6)

    ax.set_title("Tres movimientos en cada celda", fontsize=11.5, color=estilo.TEXTO, pad=10)
    ax.set_aspect("equal")
    ax.axis("off")
    ax.set_xlim(-0.9, 2.7)
    ax.set_ylim(-2.7, 0.9)


def _camino(ax, pasos, color):
    xs, ys = zip(*[centro(i, j) for i, j in pasos])
    ax.plot(xs, ys, color=color, lw=2.6, alpha=0.9, zorder=4, solid_capstyle="round")
    ax.scatter(xs, ys, s=16, color=color, alpha=0.9, zorder=5)


def _panel_caminos(ax):
    N = 4
    for i in range(N):
        for j in range(N):
            estilo.celda(ax, i, j, borde=estilo.GRIS, lw=1.0)

    # Dos rutas monótonas distintas de (0,0) a (3,3): dos alineamientos.
    _camino(ax, [(0, 0), (1, 1), (2, 2), (3, 3)], estilo.TEAL)
    _camino(ax, [(0, 0), (0, 1), (1, 1), (1, 2), (2, 2), (2, 3), (3, 3)], estilo.AMBAR)

    ax.set_title("Cada camino es un alineamiento", fontsize=11.5, color=estilo.TEXTO, pad=10)
    ax.set_aspect("equal")
    ax.axis("off")
    ax.set_xlim(-0.7, N - 1 + 0.7)
    ax.set_ylim(-(N - 1) - 0.7, 0.7)


def construir():
    estilo.configurar()
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(7.6, 3.9),
                                   gridspec_kw={"width_ratios": [1, 1.15]})
    _panel_movimientos(ax1)
    _panel_caminos(ax2)
    fig.tight_layout(w_pad=2.0)
    return fig


if __name__ == "__main__":
    estilo.guardar(construir(), "fig01_reticula")
