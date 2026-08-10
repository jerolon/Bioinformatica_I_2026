"""
Fig. 5 — Wavefront (WFA) vs matriz completa.

Dos paneles, misma retícula, secuencias PARECIDAS (que es donde WFA gana: con
secuencias muy distintas la ventaja desaparece y la figura mentiría).

  - Izquierda: la matriz clásica calcula TODAS las celdas.
  - Derecha: WFA sólo toca una banda alrededor de la diagonal, en frentes de
    score creciente (degradado TEAL_CLARO → TEAL).

El WFA aquí es real (modelo de distancia de edición: match 0, mismatch/indel 1);
las celdas tocadas y el score se calculan, no se inventan (regla 1). El __main__
verifica que el score de WFA coincide con la DP completa.

Regenerar:  python figuras/fig05_wavefront.py
"""
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap
from matplotlib.patches import Rectangle
import numpy as np

import estilo
from estilo import centro, CELDA

# Secuencias parecidas (~80% idénticas), con una indel: la banda que visita WFA
# se desplaza en diagonal donde cae el hueco. Score óptimo 3.
COL = "GACATTACAGGCATTAC"   # eje horizontal (j)
FIL = "GACATATCAGGCTTAC"    # eje vertical (i)


def wfa_edicion(a, b):
    """WFA para distancia de edición. Devuelve (tocadas, score) donde `tocadas`
    es {(i, j): frente} con el score del frente en que cada celda se toca."""
    n, m = len(a), len(b)
    objetivo = n - m
    tocadas = {}

    def extender(wf, s):
        for k, j in wf.items():
            i = j - k
            tocadas.setdefault((i, j), s)
            while i < m and j < n and b[i] == a[j]:
                i, j = i + 1, j + 1
                tocadas.setdefault((i, j), s)
            wf[k] = j
        return wf

    wf = extender({0: 0}, 0)
    s = 0
    while not (objetivo in wf and wf[objetivo] >= n):
        s += 1
        nuevo, ks = {}, set()
        for k in wf:
            ks.update((k - 1, k, k + 1))
        for k in ks:
            cand = []
            if k in wf:      cand.append(wf[k] + 1)       # sustitución
            if k + 1 in wf:  cand.append(wf[k + 1])       # deleción (baja)
            if k - 1 in wf:  cand.append(wf[k - 1] + 1)   # inserción (derecha)
            j = min(max(cand), n)
            i = j - k
            if 0 <= i <= m and 0 <= j <= n:
                nuevo[k] = j
        wf = extender(nuevo, s)
        if s > n + m:
            break
    return tocadas, s


def dp_edicion(a, b):
    """Distancia de edición por DP completa, para verificar WFA."""
    n, m = len(a), len(b)
    D = np.zeros((m + 1, n + 1), dtype=int)
    D[0, :] = np.arange(n + 1)
    D[:, 0] = np.arange(m + 1)
    for i in range(1, m + 1):
        for j in range(1, n + 1):
            D[i, j] = min(D[i - 1, j] + 1, D[i, j - 1] + 1,
                          D[i - 1, j - 1] + (a[j - 1] != b[i - 1]))
    return int(D[m, n])


def _grid(ax, m, n):
    for i in range(m + 1):
        for j in range(n + 1):
            ax.add_patch(Rectangle((j - CELDA / 2, -i - CELDA / 2), CELDA, CELDA,
                                    facecolor="none", edgecolor=estilo.GRIS,
                                    lw=0.4, zorder=3))          # rejilla encima del relleno


def _pinta(ax, i, j, color, z=2):
    ax.add_patch(Rectangle((j - CELDA / 2, -i - CELDA / 2), CELDA, CELDA,
                           facecolor=color, edgecolor="none", zorder=z))


def construir():
    estilo.configurar()
    n, m = len(COL), len(FIL)
    tocadas, score = wfa_edicion(COL, FIL)

    cmap = LinearSegmentedColormap.from_list("frentes", [estilo.TEAL_CLARO, estilo.TEAL])
    total = (m + 1) * (n + 1)

    fig, (axl, axr) = plt.subplots(1, 2, figsize=(9.6, 5.2))

    # Panel izquierdo: se calcula todo.
    for i in range(m + 1):
        for j in range(n + 1):
            _pinta(axl, i, j, estilo.FONDO_CELDA)
    _grid(axl, m, n)
    axl.set_title(f"Matriz completa\nse calculan {total} celdas",
                  fontsize=11.5, color=estilo.TEXTO, pad=8)

    # Panel derecho: sólo los frentes de WFA.
    for (i, j), s in tocadas.items():
        _pinta(axr, i, j, cmap(s / max(score, 1)))
    _grid(axr, m, n)
    axr.set_title(f"WFA · secuencias parecidas (score {score})\n"
                  f"sólo {len(tocadas)} celdas visitadas",
                  fontsize=11.5, color=estilo.TEXTO, pad=8)

    for ax in (axl, axr):
        ax.set_aspect("equal")
        ax.axis("off")
        ax.set_xlim(-1.0, n + 1.0)
        ax.set_ylim(-m - 1.0, 1.0)

    # Barra de degradado: orden de los frentes.
    sm = plt.cm.ScalarMappable(cmap=cmap, norm=plt.Normalize(0, score))
    cb = fig.colorbar(sm, ax=axr, fraction=0.046, pad=0.04)
    cb.set_label("frente (score creciente)", fontsize=9.5)
    cb.outline.set_edgecolor(estilo.GRIS)

    fig.tight_layout()
    return fig


if __name__ == "__main__":
    s_wfa = wfa_edicion(COL, FIL)[1]
    s_dp = dp_edicion(COL, FIL)
    assert s_wfa == s_dp, f"WFA {s_wfa} != DP {s_dp}"
    print(f"  verificado: score WFA = DP = {s_wfa}")
    estilo.guardar(construir(), "fig05_wavefront")
