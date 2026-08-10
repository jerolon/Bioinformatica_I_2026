"""
Fig. 7 — Las tres matrices de Gotoh (deseable).

El gap afín rompe la recurrencia de tres términos: el costo depende de si venimos
de un gap ya abierto. Gotoh lo resuelve con TRES matrices. Cada celda (i,j) de
cada matriz lee un vecino distinto, y las tres se consultan entre sí:

  M(i,j)  = máx{ M, Ix, Iy }(i-1,j-1) + s(a_i,b_j)      (diagonal, lee las tres)
  Ix(i,j) = máx{ M(i-1,j) − apertura, Ix(i-1,j) − extensión }   (de arriba)
  Iy(i,j) = máx{ M(i,j-1) − apertura, Iy(i,j-1) − extensión }   (de la izquierda)

Orden de los paneles Ix · M · Iy: así toda dependencia cruzada es entre paneles
vecinos y ninguna flecha cruza por encima de otro panel.

Regenerar:  python figuras/fig07_gotoh.py
"""
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch, Rectangle

import estilo

LADO = 4           # celdas 0..3
GAP = 2.6
TI, TJ = 2, 2      # celda objetivo (i, j)
OX = {"Ix": 0.0, "M": LADO + GAP, "Iy": 2 * (LADO + GAP)}
COLOR = {"M": estilo.TEAL, "Ix": estilo.AMBAR, "Iy": estilo.VERDE}


def c(cap, i, j):
    """Centro de la celda (i,j) del panel `cap`, en coordenadas globales."""
    return (OX[cap] + j, -i)


def _rect(ax, cap, i, j, relleno, borde, lw, z=2):
    x, y = c(cap, i, j)
    ax.add_patch(Rectangle((x - 0.5, y - 0.5), 1, 1, facecolor=relleno,
                           edgecolor=borde, lw=lw, zorder=z))


def _grid(ax, cap):
    for i in range(LADO):
        for j in range(LADO):
            _rect(ax, cap, i, j, "white", estilo.GRIS, 0.8)
    # objetivo
    _rect(ax, cap, TI, TJ, "white", COLOR[cap], 2.4, z=3)
    x, y = c(cap, TI, TJ)
    ax.text(x, y, cap, ha="center", va="center", fontsize=10,
            fontweight="bold", color=COLOR[cap], zorder=4)
    # etiqueta del panel
    ax.text(OX[cap] + (LADO - 1) / 2, 0.95, cap, ha="center", va="center",
            fontsize=14, fontweight="bold", color=COLOR[cap])


def _flecha(ax, p0, p1, color, rad=0.0, lw=1.8, z=5):
    ax.add_patch(FancyArrowPatch(p0, p1, arrowstyle="-|>", mutation_scale=13,
                                 color=color, lw=lw, zorder=z,
                                 connectionstyle=f"arc3,rad={rad}",
                                 shrinkA=6, shrinkB=6))


def construir():
    estilo.configurar()
    fig, ax = plt.subplots(figsize=(10.6, 5.0))
    for cap in ("Ix", "M", "Iy"):
        _grid(ax, cap)

    tM, tIx, tIy = c("M", TI, TJ), c("Ix", TI, TJ), c("Iy", TI, TJ)

    # Into M(i,j): diagonal (i-1,j-1) de las tres matrices.
    _flecha(ax, c("M", TI - 1, TJ - 1), tM, estilo.TEAL, rad=0.0)          # M interno
    _flecha(ax, c("Ix", TI - 1, TJ - 1), tM, estilo.TEAL, rad=-0.28)       # cruzada Ix->M
    _flecha(ax, c("Iy", TI - 1, TJ - 1), tM, estilo.TEAL, rad=0.28)        # cruzada Iy->M

    # Into Ix(i,j): arriba (i-1,j) de M y de Ix.
    _flecha(ax, c("Ix", TI - 1, TJ), tIx, estilo.AMBAR, rad=0.0)           # Ix interno
    _flecha(ax, c("M", TI - 1, TJ), tIx, estilo.AMBAR, rad=0.28)           # cruzada M->Ix

    # Into Iy(i,j): izquierda (i,j-1) de M y de Iy.
    _flecha(ax, c("Iy", TI, TJ - 1), tIy, estilo.VERDE, rad=0.0)          # Iy interno
    _flecha(ax, c("M", TI, TJ - 1), tIy, estilo.VERDE, rad=-0.28)         # cruzada M->Iy

    # Marcar las celdas fuente con un punto de su color.
    fuentes = [("M", TI - 1, TJ - 1, estilo.TEAL), ("Ix", TI - 1, TJ - 1, estilo.TEAL),
               ("Iy", TI - 1, TJ - 1, estilo.TEAL), ("Ix", TI - 1, TJ, estilo.AMBAR),
               ("M", TI - 1, TJ, estilo.AMBAR), ("Iy", TI, TJ - 1, estilo.VERDE),
               ("M", TI, TJ - 1, estilo.VERDE)]
    for cap, i, j, col in fuentes:
        x, y = c(cap, i, j)
        ax.add_patch(plt.Circle((x, y), 0.12, color=col, zorder=4))

    # Recurrencias, bajo cada panel.
    recs = {
        "Ix": "Ix(i,j) = máx{ M(i−1,j) − a,  Ix(i−1,j) − e }",
        "M":  "M(i,j) = máx{ M, Ix, Iy }(i−1,j−1) + s(aᵢ,bⱼ)",
        "Iy": "Iy(i,j) = máx{ M(i,j−1) − a,  Iy(i,j−1) − e }",
    }
    for cap in ("Ix", "M", "Iy"):
        ax.text(OX[cap] + (LADO - 1) / 2, -LADO - 0.2, recs[cap], ha="center",
                va="top", fontsize=8.6, color=COLOR[cap])
    ax.text(OX["M"] + (LADO - 1) / 2, -LADO - 0.95,
            "a = apertura del gap    ·    e = extensión", ha="center", va="top",
            fontsize=8.6, color=estilo.GRIS, style="italic")

    ax.text((OX["M"] + LADO / 2 - 0.5), 2.0,
            "Cada celda lee un vecino distinto, y las tres se consultan entre sí",
            ha="center", va="center", fontsize=11, color=estilo.TEXTO)

    ax.set_aspect("equal")
    ax.axis("off")
    ax.set_xlim(-1.2, 2 * (LADO + GAP) + LADO - 0.3)
    ax.set_ylim(-LADO - 1.4, 2.6)
    fig.tight_layout()
    return fig


if __name__ == "__main__":
    estilo.guardar(construir(), "fig07_gotoh")
