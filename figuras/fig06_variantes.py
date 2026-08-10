"""
Fig. 6 — Traceback por variante (deseable).

Cuatro paneles esquemáticos, sin números. En cada uno se sombrea sólo la región
donde puede ARRANCAR el traceback (el máximo, en verde) y donde puede TERMINAR
(en ámbar). Es la figura que muestra que las variantes son la misma máquina
tocando bordes y máximos.

Convención (A = columnas/horizontal, B = filas/vertical):
  - Global:      esquina → esquina.
  - Semi-global: gaps terminales libres en ambas; máximo en última fila/columna.
  - Overlap:     sufijo de A con prefijo de B; entra por arriba, sale por la derecha.
  - Fitting:     B corta encajada en A larga; entra por arriba, sale por abajo.

Regenerar:  python figuras/fig06_variantes.py
"""
import matplotlib.pyplot as plt

import estilo
from estilo import CELDA

M, N = 4, 5   # 5x6 celdas (i = 0..M filas, j = 0..N columnas)


def _regiones(nombre):
    fila0 = {(0, j) for j in range(N + 1)}
    filaM = {(M, j) for j in range(N + 1)}
    col0 = {(i, 0) for i in range(M + 1)}
    colN = {(i, N) for i in range(M + 1)}
    if nombre == "global":
        return {(M, N)}, {(0, 0)}                       # inicio, fin
    if nombre == "semi-global":
        return filaM | colN, fila0 | col0
    if nombre == "overlap":
        return colN, fila0
    if nombre == "fitting":
        return filaM, fila0
    raise ValueError(nombre)


def _panel(ax, nombre, titulo):
    inicio, fin = _regiones(nombre)
    for i in range(M + 1):
        for j in range(N + 1):
            if (i, j) in inicio:
                relleno = estilo.VERDE_CLARO
            elif (i, j) in fin:
                relleno = estilo.AMBAR_CLARO
            else:
                relleno = "white"
            estilo.celda(ax, i, j, relleno=relleno, borde=estilo.GRIS, lw=0.9)
    ax.set_title(titulo, fontsize=11, color=estilo.TEXTO, pad=6)
    ax.set_aspect("equal")
    ax.axis("off")
    ax.set_xlim(-0.7, N + 0.7)
    ax.set_ylim(-M - 0.7, 0.7)


def construir():
    estilo.configurar()
    fig, axes = plt.subplots(2, 2, figsize=(7.8, 6.2))
    paneles = [("global", "Global"), ("semi-global", "Semi-global"),
               ("overlap", "Overlap"), ("fitting", "Fitting")]
    for ax, (nombre, titulo) in zip(axes.flat, paneles):
        _panel(ax, nombre, titulo)

    inicio = plt.matplotlib.patches.Patch(facecolor=estilo.VERDE_CLARO,
                                          edgecolor=estilo.GRIS, label="inicio del traceback (máximo)")
    fin = plt.matplotlib.patches.Patch(facecolor=estilo.AMBAR_CLARO,
                                       edgecolor=estilo.GRIS, label="fin del traceback")
    fig.legend(handles=[inicio, fin], loc="lower center", ncol=2, frameon=False,
               fontsize=10, bbox_to_anchor=(0.5, -0.01))
    fig.tight_layout(rect=[0, 0.05, 1, 1])
    return fig


if __name__ == "__main__":
    estilo.guardar(construir(), "fig06_variantes")
