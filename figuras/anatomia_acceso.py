"""
Fig. ncbi_anatomia_acceso (§ Cómo leer un número de acceso) — esquema.

Dos accesos en monoespaciada, con un corchete y una etiqueta bajo cada parte
(prefijo · cuerpo · versión). El prefijo va en TEAL. El guion bajo (= RefSeq) se
señala. Debajo del ensamblado GCF, su par GCA en gris ("misma secuencia, copia
INSDC"). Sin datos: es un esquema de anotación.

Regenerar:  python figuras/ncbi_anatomia_acceso.py
"""
import matplotlib.pyplot as plt

import estilo

CW = 0.42   # ancho de carácter (unidades de datos)


def _acceso(ax, x0, y, texto, segs, base=estilo.TEXTO, fs=17):
    color_de = {}
    for a, b, _, c in segs:
        for i in range(a, b):
            color_de[i] = c
    for i, ch in enumerate(texto):
        ax.text(x0 + i * CW, y, ch, ha="center", va="center", fontfamily="monospace",
                fontsize=fs, fontweight="bold", color=color_de.get(i, base), zorder=3)
    yb = y - 0.5
    for a, b, etq, c in segs:
        xa = x0 + a * CW - CW / 2
        xb = x0 + (b - 1) * CW + CW / 2
        ax.plot([xa, xa, xb, xb], [yb + 0.13, yb, yb, yb + 0.13],
                color=estilo.GRIS, lw=1.1, zorder=2)
        ax.text((xa + xb) / 2, yb - 0.14, etq, ha="center", va="top",
                fontsize=8.3, color=base)
    return x0 + len(texto) * CW   # x final


def construir():
    estilo.configurar()
    fig, ax = plt.subplots(figsize=(9.4, 5.0))

    # 1 · transcrito de RefSeq
    ax.text(0, 3.15, "un transcrito de RefSeq", fontsize=10, style="italic",
            color=estilo.TEXTO)
    _acceso(ax, 0.1, 2.4, "NM_001744.6", [
        (0, 3, "prefijo · mRNA curado", estilo.TEAL),
        (3, 9, "cuerpo", estilo.TEXTO),
        (9, 11, "versión", estilo.TEXTO),
    ])
    # señalar el guion bajo
    ax.annotate("el guion bajo marca RefSeq", xy=(0.1 + 2 * CW, 2.63),
                xytext=(4.7, 3.1), fontsize=8.8, color=estilo.AMBAR,
                ha="left", arrowprops=dict(arrowstyle="-|>", color=estilo.AMBAR, lw=1.1))

    # 2 · ensamblado de genoma
    ax.text(0, 0.5, "un ensamblado de genoma", fontsize=10, style="italic",
            color=estilo.TEXTO)
    _acceso(ax, 0.1, -0.25, "GCF_000001405.40", [
        (0, 4, "prefijo · ensamblado RefSeq", estilo.TEAL),
        (4, 13, "cuerpo", estilo.TEXTO),
        (13, 16, "versión", estilo.TEXTO),
    ])
    # el par GCA, en gris
    ax.text(0.1, -1.95, "GCA_000001405.29", fontfamily="monospace", fontsize=13,
            fontweight="bold", color=estilo.GRIS, va="center")
    ax.text(5.3, -1.95, "misma secuencia, copia INSDC\n(depósito del autor, sin anotación del NCBI)",
            fontsize=8.4, color=estilo.GRIS, ha="left", va="center")

    ax.set_xlim(-0.6, 10.4)
    ax.set_ylim(-2.6, 3.7)
    ax.axis("off")
    fig.tight_layout()
    return fig


if __name__ == "__main__":
    estilo.guardar(construir(), "anatomia_acceso", subdir="ncbi", transparent=True)
