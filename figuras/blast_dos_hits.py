"""
Fig. blast_dos_hits (§3) — La heurística de dos hits, en cuatro casos.

Sobre la retícula query × base, la versión de 1997 sólo dispara la extensión
(lo caro) cuando hay DOS word hits no solapados en la MISMA diagonal y cercanos
(distancia ≤ A). Los otros tres casos no disparan nada. El caso 4 es el que le
da sentido al parámetro A.

Geometría exacta (instrucciones §3): dos hits están en la misma diagonal si
i − j es igual. No es decorativo, es la definición.

Regenerar:  python figuras/blast_dos_hits.py
"""
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch

import estilo
from estilo import centro

N = 9      # celdas por lado
A = 4      # umbral de distancia entre hits


def _grid(ax, diag=None):
    """Retícula N×N. Si diag no es None, sombrea la diagonal i − j = diag."""
    for i in range(N):
        for j in range(N):
            rel = estilo.FONDO_CELDA if (diag is not None and i - j == diag) else None
            estilo.celda(ax, i, j, relleno=rel, borde=estilo.GRIS, lw=0.5, z=1)
    ax.set_aspect("equal")
    ax.axis("off")
    ax.set_xlim(-1.0, N)
    ax.set_ylim(-N, 1.9)


def _hit(ax, i, j, color=estilo.TEAL):
    estilo.celda(ax, i, j, relleno=color, borde=color, lw=1.2, z=3)


def _dist(ax, h1, h2, etq):
    p1, p2, off = centro(*h1), centro(*h2), 0.6
    a = (p1[0] + off, p1[1] + off)
    b = (p2[0] + off, p2[1] + off)
    ax.add_patch(FancyArrowPatch(a, b, arrowstyle="<|-|>", mutation_scale=9,
                                 color=estilo.TEXTO, lw=1.1, zorder=4))
    m = ((a[0] + b[0]) / 2, (a[1] + b[1]) / 2)
    ax.text(m[0] + 0.3, m[1] + 0.3, etq, ha="left", va="bottom", fontsize=9.5,
            rotation=-45, color=estilo.TEXTO)


def _titulo(ax, texto, dispara):
    ax.text((N - 1) / 2, 1.55, texto, ha="center", va="bottom", fontsize=9.5,
            color=estilo.TEXTO)
    verd = "→ dispara la extensión" if dispara else "no dispara"
    ax.text((N - 1) / 2, -N + 0.35, verd, ha="center", va="top", fontsize=9.5,
            color=estilo.VERDE if dispara else estilo.GRIS,
            fontweight="bold" if dispara else "normal")


def construir():
    estilo.configurar()
    fig, axes = plt.subplots(2, 2, figsize=(8.2, 8.8))
    (a1, a2), (a3, a4) = axes

    # 1 · dos hits, misma diagonal (i−j=0), distancia ≤ A → dispara
    _grid(a1, diag=0)
    _hit(a1, 2, 2); _hit(a1, 5, 5)
    _dist(a1, (2, 2), (5, 5), "≤ A")
    e0, e1 = centro(0, 0), centro(7, 7)
    a1.add_patch(FancyArrowPatch((e0[0] - 0.3, e0[1] + 0.3), (e1[0] + 0.3, e1[1] - 0.3),
                                 arrowstyle="-|>", mutation_scale=13, color=estilo.VERDE,
                                 lw=2.0, zorder=2, alpha=0.85))
    _titulo(a1, "misma diagonal, distancia ≤ A", True)

    # 2 · un hit solo → no dispara
    _grid(a2)
    _hit(a2, 3, 4, color=estilo.AMBAR)
    _titulo(a2, "un hit solitario", False)

    # 3 · dos hits, distintas diagonales → no dispara
    _grid(a3)
    _hit(a3, 2, 4); _hit(a3, 5, 3)   # i−j = −2 y +2: distintas
    a3.text((N - 1) / 2, -N + 1.35, "i − j distinto", ha="center", va="top",
            fontsize=8.5, style="italic", color=estilo.GRIS)
    _titulo(a3, "distintas diagonales", False)

    # 4 · dos hits, misma diagonal, distancia > A → no dispara
    _grid(a4, diag=0)
    _hit(a4, 1, 1); _hit(a4, 7, 7)
    _dist(a4, (1, 1), (7, 7), "> A")
    _titulo(a4, "misma diagonal, distancia > A", False)

    fig.suptitle("Sólo dos hits cercanos en la misma diagonal disparan la extensión",
                 fontsize=11.5, color=estilo.TEXTO, y=0.98)
    fig.tight_layout(rect=[0, 0, 1, 0.96])
    return fig


if __name__ == "__main__":
    estilo.guardar(construir(), "blast_dos_hits")
