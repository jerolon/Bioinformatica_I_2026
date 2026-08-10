"""
Fig. 2 — Matriz de Needleman–Wunsch llena, con traceback.

Par GCATGCG (columnas) vs GATTACA (filas), scoring de la práctica:
match +1, mismatch −1, gap −1. Todos los números salen de nw_sw.py (regla 1).
Este par tiene TRES alineamientos óptimos: la figura dibuja los tres caminos
(el texto del §3 afirma que los empates existen; la figura lo respalda).

Regenerar:  python figuras/fig02_nw_matriz.py
"""
import matplotlib.pyplot as plt

import estilo
import nw_sw
from matriz import dibujar_matriz


def construir():
    estilo.configurar()
    res = nw_sw.needleman_wunsch("GCATGCG", "GATTACA", match=1, mismatch=-1, gap=-1)
    fig, ax = plt.subplots(figsize=(7.0, 7.3))
    dibujar_matriz(ax, res)
    caminos = nw_sw.contar_caminos(res)
    ax.set_title(
        f"Needleman–Wunsch · score {res['score']} · {caminos} alineamientos óptimos",
        fontsize=12, color=estilo.TEXTO, pad=12)
    fig.tight_layout()
    return fig


if __name__ == "__main__":
    estilo.guardar(construir(), "fig02_nw_matriz")
