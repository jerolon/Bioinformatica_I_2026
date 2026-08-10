"""
Fig. ncbi_ecosistema (§ El NCBI) — esquema, sin datos.

Entrez al centro; alrededor, las bases del NCBI. Los radios claros indican que
Entrez busca en todas. Unas cuantas líneas gris entre bases sugieren los
cross-links (no todas con todas). Abajo, las tres vías para bajar datos.

Regenerar:  python figuras/ncbi_ecosistema.py
"""
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch

import estilo

CY, R = 1.2, 3.2
# clave: (ángulo, etiqueta)
NODOS = {
    "gene": (112.5, "Gene"),
    "prot": (157.5, "Protein"),
    "nuc":  (67.5,  "Nucleotide\n(GenBank)"),
    "tax":  (22.5,  "Taxonomy"),
    "pub":  (-22.5, "PubMed"),
    "gen":  (-67.5, "Genome /\nAssembly"),
    "sra":  (-112.5, "SRA"),
    "snp":  (-157.5, "dbSNP /\nClinVar"),
}
LINKS = [("gene", "nuc"), ("gene", "prot"), ("gene", "pub"),
         ("nuc", "tax"), ("sra", "gen")]
VIAS = ["Web", "NCBI Datasets", "E-utilities /\nEDirect"]


def _pos(ang):
    a = np.radians(ang)
    return R * np.cos(a), CY + R * np.sin(a)


def _nodo(ax, x, y, etq, w=1.55, h=0.72, fc=estilo.FONDO_CELDA, ec=estilo.TEAL,
          tc=estilo.TEAL, fs=9, ls="-"):
    ax.add_patch(FancyBboxPatch((x - w / 2, y - h / 2), w, h,
                                boxstyle="round,pad=0.02,rounding_size=0.1",
                                facecolor=fc, edgecolor=ec, lw=1.5, linestyle=ls, zorder=4))
    ax.text(x, y, etq, ha="center", va="center", fontsize=fs, color=tc,
            fontweight="bold", zorder=5)


def construir():
    estilo.configurar()
    fig, ax = plt.subplots(figsize=(8.6, 8.8))
    pos = {k: _pos(a) for k, (a, _) in NODOS.items()}

    # radios Entrez -> cada base (claros)
    for x, y in pos.values():
        ax.add_patch(FancyArrowPatch((0, CY), (x, y), arrowstyle="-",
                                     color=estilo.TEAL_CLARO, lw=1.0, alpha=0.45,
                                     shrinkA=24, shrinkB=26, zorder=1))
    # cross-links representativos (gris, curvos)
    for a, b in LINKS:
        ax.add_patch(FancyArrowPatch(pos[a], pos[b], arrowstyle="-", color=estilo.GRIS,
                                     lw=1.1, alpha=0.75, shrinkA=26, shrinkB=26,
                                     connectionstyle="arc3,rad=0.2", zorder=2))
    # bases
    for k, (x, y) in pos.items():
        _nodo(ax, x, y, NODOS[k][1])
    # Entrez al centro
    _nodo(ax, 0, CY, "Entrez", w=1.8, h=0.9, fc=estilo.TEAL, ec=estilo.TEAL,
          tc="white", fs=12)

    # tres vías para bajar datos
    by = -4.5
    ax.text(0, by + 1.0, "tres vías para bajar datos", ha="center", fontsize=9.5,
            style="italic", color=estilo.TEXTO)
    for x, etq in zip([-3.2, 0, 3.2], VIAS):
        _nodo(ax, x, by, etq, w=2.35, h=0.9, fc="none", ec=estilo.AMBAR,
              tc=estilo.AMBAR, fs=9.5)
        ax.add_patch(FancyArrowPatch((0, CY - 0.48), (x, by + 0.48), arrowstyle="-|>",
                                     mutation_scale=12, color=estilo.AMBAR, lw=1.6,
                                     shrinkA=4, shrinkB=2, zorder=3))

    ax.set_xlim(-4.8, 4.8)
    ax.set_ylim(by - 0.8, CY + R + 0.9)
    ax.set_aspect("equal")
    ax.axis("off")
    fig.tight_layout()
    return fig


if __name__ == "__main__":
    estilo.guardar(construir(), "ncbi_ecosistema", subdir="ncbi", transparent=True)
