"""
Fig. 3 — Needleman–Wunsch vs Smith–Waterman sobre el mismo par.

Par distinto al de la fig. 2 a propósito: el alineamiento local necesita un
bloque conservado que el global no necesita. GCATGCG/GATTACA no comparte ningún
bloque, así que su SW es un mar de ceros (verificado). Aquí:

    GCGATTAG (columnas)  vs  TTGATTACA (filas)     bloque GATTA
    NW score 1 (2 óptimos)   ·   SW score 5

Mismo scoring que la fig. 2 (match +1, mismatch −1, gap −1). Los tres cambios
NW→SW se anotan sobre la figura. Números calculados por nw_sw.py (regla 1).

Regenerar:  python figuras/fig03_nw_vs_sw.py
"""
import matplotlib.pyplot as plt

import estilo
import nw_sw
from matriz import dibujar_matriz

COL, FIL = "GCGATTAG", "TTGATTACA"


def construir():
    estilo.configurar()
    nw = nw_sw.needleman_wunsch(COL, FIL, match=1, mismatch=-1, gap=-1)
    sw = nw_sw.smith_waterman(COL, FIL, match=1, mismatch=-1, gap=-1)
    _mx, maximos = nw_sw.maximos(sw)

    fig, (axn, axs) = plt.subplots(1, 2, figsize=(9.8, 6.6))

    dibujar_matriz(axn, nw, flechas="optimo")
    axn.set_title(f"Global — Needleman–Wunsch  ·  score {nw['score']}",
                  fontsize=11.5, color=estilo.TEXTO, pad=8)

    dibujar_matriz(axs, sw, inicios=maximos, marcar_maximo=True, flechas="optimo")
    axs.set_title(f"Local — Smith–Waterman  ·  score {sw['score']}",
                  fontsize=11.5, color=estilo.TEXTO, pad=8)

    # Los tres cambios acoplados, anotados bajo los paneles.
    y = 0.135
    fig.text(0.5, y + 0.045, "Tres cambios acoplados — el mismo par, el mismo scoring:",
             ha="center", va="bottom", fontsize=10.5, fontweight="bold",
             color=estilo.TEXTO)
    lineas = [
        ("①  Bordes de inicialización: ", "negativos en NW", " → ", "ceros en SW"),
        ("②  Aparecen ceros dentro de la matriz (SW): ", "ahí el alineamiento reinicia", "", ""),
        ("③  El traceback arranca en la esquina (NW) o en el ", "máximo global (SW)", "", ""),
        ("      y termina en el origen (NW) o en la ", "primera celda con 0 (SW)", "", ""),
    ]
    for k, partes in enumerate(lineas):
        fig.text(0.5, y - k * 0.032, "".join(partes), ha="center", va="top",
                 fontsize=9.5, color=estilo.TEXTO)

    fig.tight_layout(rect=[0, 0.20, 1, 0.97])
    return fig


if __name__ == "__main__":
    estilo.guardar(construir(), "fig03_nw_vs_sw")
