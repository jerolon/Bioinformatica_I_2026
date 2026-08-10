"""
Fig. ncbi_edirect_pipeline (§ Sacar los datos) — esquema.

Cuatro comandos de EDirect en fila, unidos por el símbolo de tubería `|`:
esearch → elink → efetch → xtract, con una línea de qué hace cada uno. A un
lado, el History server (WebEnv + query_key), que guarda el estado y se pasa
entre esearch/elink/efetch (no lo usa xtract, que sólo formatea el XML local).

Regenerar:  python figuras/ncbi_edirect_pipeline.py
"""
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch

import estilo

CMDS = [
    ("esearch", "busca en una base"),
    ("elink", "sigue enlaces"),
    ("efetch", "descarga los registros"),
    ("xtract", "arma la tabla"),
]
BW, GAP, H = 2.3, 0.9, 0.9   # ancho, separación, alto de caja


def construir():
    estilo.configurar()
    fig, ax = plt.subplots(figsize=(9.6, 3.6))

    centros = []
    for i, (cmd, desc) in enumerate(CMDS):
        x = i * (BW + GAP)
        cx = x + BW / 2
        centros.append(cx)
        ax.add_patch(FancyBboxPatch((x, -H / 2), BW, H,
                                    boxstyle="round,pad=0.02,rounding_size=0.12",
                                    facecolor=estilo.FONDO_CELDA, edgecolor=estilo.TEAL,
                                    lw=1.8, zorder=3))
        ax.text(cx, 0, cmd, ha="center", va="center", fontfamily="monospace",
                fontsize=13, fontweight="bold", color=estilo.TEAL, zorder=4)
        ax.text(cx, -H / 2 - 0.28, desc, ha="center", va="top", fontsize=9,
                color=estilo.TEXTO)
        if i < len(CMDS) - 1:                       # el pipe |
            ax.text(x + BW + GAP / 2, 0, "|", ha="center", va="center",
                    fontfamily="monospace", fontsize=20, fontweight="bold",
                    color=estilo.GRIS, zorder=4)

    # History server: guarda el estado y lo pasan esearch/elink/efetch.
    hx0, hx1 = -0.2, centros[2] + BW / 2 + 0.2
    hy = H / 2 + 1.15
    ax.add_patch(FancyBboxPatch((hx0, hy - 0.35), hx1 - hx0, 0.7,
                                boxstyle="round,pad=0.02,rounding_size=0.1",
                                facecolor="none", edgecolor=estilo.AMBAR, lw=1.4,
                                linestyle="--", zorder=3))
    ax.text((hx0 + hx1) / 2, hy, "History server  (WebEnv + query_key)", ha="center",
            va="center", fontsize=9.5, color=estilo.AMBAR, fontweight="bold")
    for cx in centros[:3]:
        ax.add_patch(FancyArrowPatch((cx, hy - 0.35), (cx, H / 2 + 0.02),
                                     arrowstyle="-", color=estilo.AMBAR, lw=1,
                                     linestyle=(0, (3, 3)), zorder=2))
    ax.text((hx0 + hx1) / 2, hy + 0.5, "el estado se pasa entre pasos", ha="center",
            va="bottom", fontsize=8.4, style="italic", color=estilo.GRIS)

    ax.set_xlim(-0.5, (BW + GAP) * 3 + BW + 0.5)
    ax.set_ylim(-1.5, hy + 0.95)
    ax.axis("off")
    fig.tight_layout()
    return fig


if __name__ == "__main__":
    estilo.guardar(construir(), "edirect_pipeline", subdir="ncbi", transparent=True)
