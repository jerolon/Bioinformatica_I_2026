"""
Fig. ncbi_genbank_refseq (§ GenBank y RefSeq) — esquema.

Izquierda: GenBank/INSDC, el archivo redundante (varios registros del mismo gen,
en el mismo color). Una flecha de "curación" lleva a la derecha: RefSeq, no
redundante (un registro por molécula). Abajo, el triángulo del INSDC —GenBank,
ENA, DDBJ— que se sincroniza a diario.

Regenerar:  python figuras/ncbi_genbank_refseq.py
"""
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch

import estilo


def _rects(ax, x, ys, w, colores):
    for y, c in zip(ys, colores):
        ax.add_patch(FancyBboxPatch((x, y), w, 0.36,
                                    boxstyle="round,pad=0.01,rounding_size=0.05",
                                    facecolor=c, edgecolor=estilo.GRIS, lw=0.7, zorder=3))


def _vertice(ax, x, y, etq):
    ax.add_patch(FancyBboxPatch((x - 0.85, y - 0.28), 1.7, 0.56,
                                boxstyle="round,pad=0.02,rounding_size=0.1",
                                facecolor=estilo.FONDO_CELDA, edgecolor=estilo.TEAL,
                                lw=1.4, zorder=4))
    ax.text(x, y, etq, ha="center", va="center", fontsize=9.5, fontweight="bold",
            color=estilo.TEAL, zorder=5)


def construir():
    estilo.configurar()
    fig, ax = plt.subplots(figsize=(8.2, 6.2))

    # --- GenBank (izquierda): archivo redundante ---
    ax.add_patch(FancyBboxPatch((-0.15, 1.0), 2.5, 3.15, boxstyle="round,pad=0.02,rounding_size=0.1",
                                facecolor="none", edgecolor=estilo.GRIS, lw=1.2, zorder=1))
    ax.text(1.1, 4.45, "GenBank / INSDC", ha="center", fontsize=11, fontweight="bold",
            color=estilo.TEXTO)
    dup = estilo.TEAL_CLARO
    _rects(ax, 0.15, [3.5, 3.05, 2.6, 1.95, 1.5], 2.05,
           [dup, dup, dup, estilo.AMBAR_CLARO, estilo.VERDE_CLARO])
    ax.annotate("el mismo gen,\n3 depósitos", xy=(2.2, 3.05), xytext=(2.75, 3.5),
                fontsize=8.4, color=estilo.TEXTO, ha="left",
                arrowprops=dict(arrowstyle="-|>", color=estilo.GRIS, lw=1))
    ax.text(1.1, 0.68, "archivo · redundante", ha="center", fontsize=9,
            style="italic", color=estilo.GRIS)

    # --- curación ---
    ax.add_patch(FancyArrowPatch((3.7, 2.6), (5.15, 2.6), arrowstyle="-|>",
                                 mutation_scale=16, color=estilo.TEAL, lw=2.4, zorder=3))
    ax.text(4.4, 2.85, "curación", ha="center", fontsize=9.5, color=estilo.TEAL,
            fontweight="bold")

    # --- RefSeq (derecha): no redundante ---
    ax.add_patch(FancyBboxPatch((5.35, 1.5), 2.2, 2.15, boxstyle="round,pad=0.02,rounding_size=0.1",
                                facecolor="none", edgecolor=estilo.GRIS, lw=1.2, zorder=1))
    ax.text(6.45, 3.95, "RefSeq", ha="center", fontsize=11, fontweight="bold",
            color=estilo.TEXTO)
    _rects(ax, 5.6, [3.0, 2.5, 2.0], 1.75,
           [dup, estilo.AMBAR_CLARO, estilo.VERDE_CLARO])
    ax.text(6.45, 1.18, "curado · una por molécula", ha="center", fontsize=9,
            style="italic", color=estilo.GRIS)

    # --- Triángulo del INSDC ---
    v = {"GenBank": (1.2, -2.7), "ENA (EMBL-EBI)": (6.2, -2.7), "DDBJ": (3.7, -0.9)}
    pares = [("GenBank", "ENA (EMBL-EBI)"), ("ENA (EMBL-EBI)", "DDBJ"), ("DDBJ", "GenBank")]
    for a, b in pares:
        pa, pb = np.array(v[a], float), np.array(v[b], float)
        u = (pb - pa) / np.linalg.norm(pb - pa)
        p0, p1 = pa + u * 0.98, pb - u * 0.98     # dejar los extremos fuera de las cajas
        ax.add_patch(FancyArrowPatch(p0, p1, arrowstyle="<|-|>", mutation_scale=11,
                                     color=estilo.GRIS, lw=1.3, zorder=2))
    for etq, (x, y) in v.items():
        _vertice(ax, x, y, etq)
    ax.text(3.7, -2.15, "se sincronizan a diario\n(INSDC)", ha="center", va="center",
            fontsize=8.8, style="italic", color=estilo.TEXTO)

    ax.set_xlim(-0.6, 8.0)
    ax.set_ylim(-3.4, 4.8)
    ax.set_aspect("equal")
    ax.axis("off")
    fig.tight_layout()
    return fig


if __name__ == "__main__":
    estilo.guardar(construir(), "genbank_refseq", subdir="ncbi", transparent=True)
