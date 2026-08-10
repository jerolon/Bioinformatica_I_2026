"""
Fig. (A10-e) — Alineamiento progresivo y el pecado original.

El alineamiento progresivo sigue un árbol guía: alinea primero los pares más
parecidos y va agregando secuencias. El problema es que un gap introducido
temprano —al alinear las dos secuencias más cercanas— nunca se quita ni se
mueve, sólo se agranda: "once a gap, always a gap". Un error temprano se
propaga a todo el alineamiento.

Esquema sin datos. Regenerar:  python figuras/msa_progresivo.py
"""
import matplotlib.pyplot as plt

import estilo

# Árbol guía caterpillar: ((A,B),C),D. El orden de fusión es 1, 2, 3.
LEAVES = {"A": 3, "B": 2, "C": 1, "D": 0}
COL_GAP = 2   # la columna con el hueco introducido al alinear A y B
FILAS = {
    "A": "MKTAYLG",
    "B": "MK-AYLG",   # gap en la columna 2
    "C": "MKTAYLG",
    "D": "MKTAFLG",
}
X0 = 5.0      # dónde empieza el alineamiento
DX = 0.62


def _linea(ax, x0, y0, x1, y1, **kw):
    ax.plot([x0, x1], [y0, y1], color=estilo.GRIS, lw=1.6, solid_capstyle="round", **kw)


def construir():
    estilo.configurar()
    fig, ax = plt.subplots(figsize=(8.4, 4.2))

    # --- Árbol guía (raíz a la izquierda, hojas a la derecha) ---
    xa, xb, xc = 2.0, 1.3, 0.6      # x de los nodos internos 1, 2, 3
    yA, yB, yC, yD = LEAVES["A"], LEAVES["B"], LEAVES["C"], LEAVES["D"]
    for h, y in LEAVES.items():
        _linea(ax, 3.0, y, {"A": xa, "B": xa, "C": xb, "D": xc}[h], y)
        ax.text(3.15, y, h, ha="left", va="center", fontsize=12, fontweight="bold",
                color=estilo.TEXTO)
    # nodo 1 (A,B)
    _linea(ax, xa, yA, xa, yB); n1 = (xa, (yA + yB) / 2)
    # nodo 2 ((AB),C)
    _linea(ax, xb, n1[1], xb, yC); n2 = (xb, (n1[1] + yC) / 2)
    _linea(ax, xa, n1[1], xb, n1[1])
    # nodo 3 (((AB)C),D)
    _linea(ax, xc, n2[1], xc, yD); n3 = (xc, (n2[1] + yD) / 2)
    _linea(ax, xb, n2[1], xc, n2[1])
    _linea(ax, xc, n3[1], 0.1, n3[1])
    for (x, y), k in ((n1, "1"), (n2, "2"), (n3, "3")):
        ax.add_patch(plt.Circle((x, y), 0.14, color=estilo.TEAL, zorder=4))
        ax.text(x, y, k, ha="center", va="center", fontsize=8.5, color="white",
                fontweight="bold", zorder=5)
    ax.text(1.5, 3.7, "árbol guía", ha="center", fontsize=10, style="italic",
            color=estilo.TEXTO)
    ax.text(1.5, -0.7, "orden de fusión: 1 → 2 → 3", ha="center", fontsize=8.6,
            color=estilo.GRIS)

    # --- Alineamiento resultante, con la columna del gap resaltada ---
    ncols = len(FILAS["A"])
    ax.add_patch(plt.Rectangle((X0 + COL_GAP * DX - DX / 2, -0.5), DX, 4.0,
                               facecolor=estilo.AMBAR_CLARO, edgecolor="none", zorder=0))
    for h, y in LEAVES.items():
        for c, letra in enumerate(FILAS[h]):
            es_gap = letra == "-"
            ax.text(X0 + c * DX, y, letra, ha="center", va="center",
                    fontfamily="monospace", fontsize=13, zorder=2,
                    color=estilo.AMBAR if es_gap else estilo.TEXTO,
                    fontweight="bold" if es_gap else "normal")

    xg = X0 + COL_GAP * DX
    ax.annotate("el hueco se introduce\nal fusionar A y B (paso 1)…",
                xy=(xg, 2), xytext=(xg + 0.2, 4.0), fontsize=9, color=estilo.AMBAR,
                ha="left", arrowprops=dict(arrowstyle="-|>", color=estilo.AMBAR, lw=1.2))
    ax.annotate("…y se queda para siempre:\n«once a gap, always a gap»",
                xy=(xg, -0.3), xytext=(xg + 0.2, -1.25), fontsize=9, color=estilo.AMBAR,
                ha="left", arrowprops=dict(arrowstyle="-|>", color=estilo.AMBAR, lw=1.2))

    ax.set_xlim(-0.1, X0 + ncols * DX + 0.4)
    ax.set_ylim(-1.7, 4.5)
    ax.axis("off")
    fig.tight_layout()
    return fig


if __name__ == "__main__":
    estilo.guardar(construir(), "msa_progresivo")
