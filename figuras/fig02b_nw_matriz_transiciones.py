"""
Fig. 2b — La misma matriz de Needleman–Wunsch, con el esquema
transición/transversión del §3 (la tabla que sigue a "…más probables que las
transversiones").

Mismo par que la fig. 2 —GCATGCG (columnas) vs GATTACA (filas)— y mismo gap −1,
para que la comparación sea limpia: lo ÚNICO que cambia es la matriz Diagonal.
Por eso aquí se dibujan las 49 aristas diagonales con su peso encima, en vez de
las flechas de procedencia: la figura muestra el dato de entrada que cambió
(Diagonal, en teal) y el resultado (el camino más largo, en verde).

Las aristas horizontales y verticales no se dibujan porque todas valen lo mismo,
−1; sólo aparecen las del camino óptimo.

Regenerar:  python figuras/fig02b_nw_matriz_transiciones.py
"""
import matplotlib.pyplot as plt

import estilo
import nw_sw
from matriz import dibujar_matriz, num


def tres_decimales(v):
    """Los pesos diagonales salen de una tabla escrita con tres decimales: se
    escriben con tres, incluido el 1.000 de C/C (num() lo dejaría en '1')."""
    return f"{float(v):.3f}"


def construir():
    estilo.configurar()
    res = nw_sw.needleman_wunsch("GCATGCG", "GATTACA", gap=-1,
                                 sub=nw_sw.TRANSICIONES)
    fig, ax = plt.subplots(figsize=(8.4, 8.9))
    dibujar_matriz(ax, res, flechas="diagonales", encoge=0.20,
                   fmt_diag=tres_decimales, fs_num=8.5, fs_diag=6.8)

    caminos = nw_sw.contar_caminos(res)
    ax.set_title(
        f"Needleman–Wunsch, esquema transición/transversión · "
        f"score {num(res['score'])} · {caminos} alineamientos óptimos",
        fontsize=11.5, color=estilo.TEXTO, pad=12)

    # Leyenda al pie: qué es cada número. Sin esto, los dos juegos de cifras
    # (peso de arista y valor de celda) se confunden.
    y0, y1 = ax.get_ylim()
    ax.set_ylim(y0 - 0.9, y1)
    ax.text(res["n"] / 2, y0 - 0.45,
            "En teal, sobre cada flecha, el peso de esa arista diagonal: "
            "la matriz Diagonal completa, s(a$_i$, b$_j$).\n"
            "En negro, s[i, j], el camino más largo hasta la celda. Las aristas "
            "horizontales y verticales valen todas -1 y no se dibujan.",
            ha="center", va="center", fontsize=8.5, color=estilo.GRIS,
            linespacing=1.5)

    fig.tight_layout()
    return fig


if __name__ == "__main__":
    estilo.guardar(construir(), "fig02b_nw_matriz_transiciones")
