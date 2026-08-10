"""
Fig. ncbi_escala (§ Las bases) — Escala aproximada de algunas bases del NCBI.

La ÚNICA figura del capítulo con datos. Cifras aproximadas: cada una es una
variable con su fuente y fecha, y la figura lleva una nota al pie pidiendo
verificar. Eje X en log10 (obligatorio: el punto es que abarcan varios órdenes
de magnitud).

Regenerar:  python figuras/ncbi_escala.py
"""
import numpy as np
import matplotlib.pyplot as plt

import estilo

# (nombre, valor aproximado). Fuente/fecha en el comentario.
BASES = [
    ("Taxonomy\n(especies)",             1.9e6),   # ~1.9 M táxones con nombre
    ("PubMed\n(citas)",                  3.7e7),   # >37 M · página de estadísticas de PubMed
    ("SRA\n(registros)",                 4.0e7),   # >40 M · sept. 2025 (Sayers et al. 2026)
    ("Nucleotide / GenBank\n(secuencias)", 4.3e8), # orden de magnitud · GenBank release notes
    ("dbSNP\n(variantes)",               7.0e8),   # verificar en las estadísticas de dbSNP
]


def _etq(v):
    return f"≈{v/1e6:.1f} M" if v < 1e7 else f"≈{v/1e6:.0f} M"


def construir():
    estilo.configurar()
    bases = sorted(BASES, key=lambda b: b[1])          # ascendente
    nombres = [b[0] for b in bases]
    vals = np.array([b[1] for b in bases])
    y = np.arange(len(bases))

    fig, ax = plt.subplots(figsize=(7.8, 4.3))
    ax.set_xscale("log")
    ax.set_xlim(1e6, 3e9)
    ax.barh(y, vals - 1e6, left=1e6, color=estilo.TEAL, height=0.6, zorder=3)
    for yi, v in zip(y, vals):
        ax.text(v * 1.18, yi, _etq(v), va="center", ha="left", fontsize=9.5,
                color=estilo.TEXTO)

    ax.set_yticks(y)
    ax.set_yticklabels(nombres, fontsize=9.5)
    ax.set_xlabel("número de registros (escala logarítmica)", fontsize=10.5)
    ax.set_title("Escala aproximada de algunas bases del NCBI",
                 fontsize=12, color=estilo.TEXTO, pad=10)
    ax.grid(True, axis="x", which="major", color=estilo.GRIS, alpha=0.16, zorder=0)
    ax.tick_params(left=False)
    for s in ("top", "right", "left"):
        ax.spines[s].set_visible(False)
    ax.text(0.0, -0.22, "Cifras aproximadas; verificar en las páginas de estadísticas del NCBI.",
            transform=ax.transAxes, fontsize=8, style="italic", color=estilo.GRIS)
    fig.tight_layout()
    return fig


if __name__ == "__main__":
    print("  órdenes de magnitud abarcados:",
          f"{np.log10(7.0e8) - np.log10(1.9e6):.1f}")
    estilo.guardar(construir(), "ncbi_escala", subdir="ncbi", transparent=True)
