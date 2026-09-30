"""
Fig. blast_seed_extend (§3) — Seed-and-extend con score REAL de BLOSUM62.

El perfil de score y los bordes del HSP se calculan (instrucciones cap. 8, §3):
se recorre un par de secuencias de juguete acumulando BLOSUM62 desde una semilla,
y la extensión para donde el acumulado cae X por debajo de su máximo (X-drop).
El HSP es el segmento entre los máximos de cada dirección.

El panel de arriba dibuja el acumulado COMO LO CALCULA EL ALGORITMO: dos curvas
que nacen en 0 en los bordes de la semilla, una recorrida hacia la derecha y la
otra hacia la izquierda, cada una con su propio máximo (que fija un borde del
HSP) y su propio umbral máximo − X. Nada de cumsum global de izquierda a
derecha: eso escondía el score del HSP en una diferencia de alturas ilegible.
La aritmética queda a la vista: semilla + ganancia izq. + ganancia der. = HSP.

Par elegido y por qué: un par de ~30 aa con núcleo conservado (semilla CWHYF)
y flancos divergentes. El HSP resultante (posiciones 8–21) CONTIENE mismatches
—K/R, R/K, I/V, D/E, todos con score positivo en BLOSUM62— para que se vea que
el HSP tolera desajustes mientras el score aguante; y los dos flancos caen lo
bastante para disparar el X-drop antes de los extremos (con X = 10). Si se
cambia el par, revisar que se cumplan esas dos cosas.

Regenerar:  python figuras/blast_seed_extend.py
"""
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch, FancyBboxPatch

import estilo

# BLOSUM62 (NCBI). Tecleada aquí para no depender de Biopython (instrucciones §4).
_BLOSUM62 = """
   A  R  N  D  C  Q  E  G  H  I  L  K  M  F  P  S  T  W  Y  V
A  4 -1 -2 -2  0 -1 -1  0 -2 -1 -1 -1 -1 -2 -1  1  0 -3 -2  0
R -1  5  0 -2 -3  1  0 -2  0 -3 -2  2 -1 -3 -2 -1 -1 -3 -2 -3
N -2  0  6  1 -3  0  0  0  1 -3 -3  0 -2 -3 -2  1  0 -4 -2 -3
D -2 -2  1  6 -3  0  2 -1 -1 -3 -4 -1 -3 -3 -1  0 -1 -4 -3 -3
C  0 -3 -3 -3  9 -3 -4 -3 -3 -1 -1 -3 -1 -2 -3 -1 -1 -2 -2 -1
Q -1  1  0  0 -3  5  2 -2  0 -3 -2  1  0 -3 -1  0 -1 -2 -1 -2
E -1  0  0  2 -4  2  5 -2  0 -3 -3  1 -2 -3 -1  0 -1 -3 -2 -2
G  0 -2  0 -1 -3 -2 -2  6 -2 -4 -4 -2 -3 -3 -2  0 -2 -2 -3 -3
H -2  0  1 -1 -3  0  0 -2  8 -3 -3 -1 -2 -1 -2 -1 -2 -2  2 -3
I -1 -3 -3 -3 -1 -3 -3 -4 -3  4  2 -3  1  0 -3 -2 -1 -3 -1  3
L -1 -2 -3 -4 -1 -2 -3 -4 -3  2  4 -2  2  0 -3 -2 -1 -2 -1  1
K -1  2  0 -1 -3  1  1 -2 -1 -3 -2  5 -1 -3 -1  0 -1 -3 -2 -2
M -1 -1 -2 -3 -1  0 -2 -3 -2  1  2 -1  5  0 -2 -1 -1 -1 -1  1
F -2 -3 -3 -3 -2 -3 -3 -3 -1  0  0 -3  0  6 -4 -2 -2  1  3 -1
P -1 -2 -2 -1 -3 -1 -1 -2 -2 -3 -3 -1 -2 -4  7 -1 -1 -4 -3 -2
S  1 -1  1  0 -1  0  0  0 -1 -2 -2  0 -1 -2 -1  4  1 -3 -2 -2
T  0 -1  0 -1 -1 -1 -1 -2 -2 -1 -1 -1 -1 -2 -1  1  5 -2 -2  0
W -3 -3 -4 -4 -2 -2 -3 -2 -2 -3 -2 -3 -1  1 -4 -3 -2 11  2 -3
Y -2 -2 -2 -3 -2 -1 -2 -3  2 -1 -1 -2 -1  3 -3 -2 -2  2  7 -1
V  0 -3 -3 -3 -1 -2 -2 -3 -3  3  1 -2  1 -1 -2 -2  0 -3 -1  4
"""

Q = "APAPGPAG" + "LKER" + "CWHYF" + "ILQND" + "PGPAPGPA"
S = "WWWKWWKW" + "LREK" + "CWHYF" + "VLQNE" + "WWKWWKWW"
SEED = (12, 17)   # CWHYF, media-abierto
X = 10            # umbral de X-drop


def _blosum():
    filas = [r.split() for r in _BLOSUM62.strip().splitlines()]
    cols = filas[0]
    return {(f[0], b): int(v) for f in filas[1:] for b, v in zip(cols, f[1:])}


def _extender(sc, seed_l, seed_r, x):
    """X-drop desde la semilla hacia cada lado. Devuelve bordes del HSP (los
    máximos) y dónde para la extensión (donde cae x bajo el máximo)."""
    def lado(rango):
        cum = mx = 0
        borde = paro = rango[0]
        for i in rango:
            cum += sc[i]
            paro = i
            if cum > mx:
                mx, borde = cum, i
            if cum <= mx - x:
                break
        return borde, paro, mx
    br, pr, gr = lado(range(seed_r, len(sc)))          # derecha
    bl, pl, gl = lado(range(seed_l - 1, -1, -1))        # izquierda
    return bl, br, pl, pr, gl, gr


def construir():
    estilo.configurar()
    B = _blosum()
    sc = np.array([B[(a, b)] for a, b in zip(Q, S)])
    L = len(sc)
    bl, br, pl, pr, gl, gr = _extender(sc, SEED[0], SEED[1], X)
    seed_sc = int(sc[SEED[0]:SEED[1]].sum())
    hsp_sc = int(sc[bl:br + 1].sum())
    # la aritmética que la figura enseña: semilla + ganancia izq + ganancia der
    assert hsp_sc == seed_sc + gl + gr

    # acumulado de cada extensión, desde el borde de la semilla hacia afuera
    pos_der = np.arange(SEED[1], pr + 1)
    cum_der = np.cumsum(sc[SEED[1]:pr + 1])
    pos_izq = np.arange(SEED[0] - 1, pl - 1, -1)   # 11, 10, …, pl
    cum_izq = np.cumsum(sc[pl:SEED[0]][::-1])

    fig, (axc, axl) = plt.subplots(
        2, 1, figsize=(9.6, 5.4), sharex=True,
        gridspec_kw={"height_ratios": [2.1, 1.3], "hspace": 0.08})

    # --- Panel de score: una curva por lado, ancladas en 0 en la semilla ---
    axc.axvspan(bl - 0.5, br + 0.5, color=estilo.VERDE_CLARO, zorder=0)
    axc.axvspan(SEED[0] - 0.5, SEED[1] - 0.5, color=estilo.FONDO_CELDA, zorder=0.5)
    axc.axhline(0, lw=0.8, color=estilo.GRIS, alpha=0.6, zorder=1)
    axc.plot([SEED[1] - 0.5] + list(pos_der), [0] + list(cum_der),
             color=estilo.TEAL, lw=2.2, zorder=3)
    axc.plot([SEED[0] - 0.5] + list(pos_izq), [0] + list(cum_izq),
             color=estilo.TEAL, lw=2.2, zorder=3)
    axc.scatter(pos_der, cum_der, s=12, color=estilo.TEAL, zorder=4)
    axc.scatter(pos_izq, cum_izq, s=12, color=estilo.TEAL, zorder=4)
    axc.text((SEED[0] + SEED[1]) / 2 - 0.5, 6.5, f"semilla\nvale {seed_sc}",
             ha="center", va="center", fontsize=9, color=estilo.TEAL,
             fontweight="bold")
    axc.text((pl + SEED[0]) / 2, -4.2, "← se acumula hacia la izquierda",
             ha="center", va="center", fontsize=8, color=estilo.TEAL,
             style="italic")
    axc.text((SEED[1] + pr) / 2, -4.2, "se acumula hacia la derecha →",
             ha="center", va="center", fontsize=8, color=estilo.TEAL,
             style="italic")
    # el máximo de cada lado fija un borde del HSP
    axc.scatter([bl, br], [gl, gr], s=60, color=estilo.VERDE, zorder=5,
                ec="white")
    axc.text(15, 25.6, "el máximo de cada lado fija un borde del HSP",
             ha="center", va="center", fontsize=9, color=estilo.VERDE)
    for p0, p1 in (((10.2, 24.4), (bl + 0.25, gl + 1.0)),
                   ((19.8, 24.4), (br - 0.15, gr + 0.9))):
        axc.add_patch(FancyArrowPatch(p0, p1, arrowstyle="-|>",
                                      mutation_scale=10, color=estilo.VERDE,
                                      lw=1.2, zorder=5))
    # X-drop: cada lado tiene su umbral máximo − X y su punto de paro
    axc.hlines(gr - X, SEED[1] - 0.5, pr + 2.4, colors=estilo.AMBAR,
               linestyles=":", lw=1.2, zorder=2)
    axc.hlines(gl - X, pl - 2.4, SEED[0] - 0.5, colors=estilo.AMBAR,
               linestyles=":", lw=1.2, zorder=2)
    axc.text(pr + 2.4, gr - X - 0.9, "máximo − X", ha="right", va="top",
             fontsize=8.5, color=estilo.AMBAR)
    axc.text(pl - 2.4, gl - X - 0.9, "máximo − X", ha="left", va="top",
             fontsize=8.5, color=estilo.AMBAR)
    axc.scatter([pl, pr], [cum_izq[-1], cum_der[-1]], s=45, color=estilo.AMBAR,
                zorder=5, ec="white")
    axc.annotate("cae X bajo el máximo:\nla extensión para (X-drop)",
                 xy=(pr, cum_der[-1] + 0.7), xytext=(26.5, 18.5), fontsize=8.6,
                 color=estilo.AMBAR, ha="center", va="top",
                 arrowprops=dict(arrowstyle="-|>", color=estilo.AMBAR, lw=1.2))
    axc.set_ylabel("score de la extensión\n(acumulado desde la semilla)",
                   fontsize=10)
    axc.set_ylim(-6, 28.5)
    axc.set_yticks([0, 5, 10, 15, 20])
    for lado in ("top", "right"):
        axc.spines[lado].set_visible(False)
    axc.tick_params(labelbottom=False, bottom=False)

    # --- Panel de secuencias ---
    axl.add_patch(plt.Rectangle((bl - 0.5, -0.6), (br - bl + 1), 2.2,
                                facecolor=estilo.VERDE_CLARO, edgecolor="none", zorder=0))
    for i in range(L):
        col = estilo.AMBAR if Q[i] != S[i] else estilo.TEXTO   # mismatch en ámbar
        for y, seq in ((1, Q), (0, S)):
            axl.text(i, y, seq[i], ha="center", va="center", color=col,
                     fontfamily="monospace", fontsize=11, zorder=2,
                     fontweight="bold" if SEED[0] <= i < SEED[1] else "normal")
    # semilla
    axl.add_patch(FancyBboxPatch((SEED[0] - 0.45, -0.45), (SEED[1] - SEED[0]) - 0.1, 1.9,
                                 boxstyle="round,pad=0.02,rounding_size=0.12",
                                 facecolor="none", edgecolor=estilo.TEAL, lw=2, zorder=3))
    axl.text((SEED[0] + SEED[1]) / 2 - 0.5, 1.75, "semilla (word)", ha="center",
             va="bottom", fontsize=9, color=estilo.TEAL, fontweight="bold")
    # corchete del HSP
    axl.annotate("", xy=(bl - 0.5, -0.75), xytext=(br + 0.5, -0.75),
                 arrowprops=dict(arrowstyle="-", color=estilo.VERDE, lw=1.6))
    axl.text((bl + br) / 2, -1.25,
             f"HSP: score {seed_sc} (semilla) + {gl} (izq.) + {gr} (der.) = {hsp_sc}",
             ha="center", va="top", fontsize=9.5, color=estilo.VERDE, fontweight="bold")
    axl.set_ylim(-1.7, 2.2)
    axl.set_xlim(-0.8, L - 0.2)
    axl.axis("off")
    return fig


if __name__ == "__main__":
    B = _blosum()
    sc = [B[(a, b)] for a, b in zip(Q, S)]
    bl, br, pl, pr, gl, gr = _extender(np.array(sc), SEED[0], SEED[1], X)
    print(f"  HSP = posiciones {bl}..{br}  (semilla {SEED[0]}..{SEED[1]-1})")
    print(f"  X-drop para en: izq {pl}, der {pr}  (X={X})")
    print(f"  ganancias: izq +{gl}, der +{gr}")
    estilo.guardar(construir(), "blast_seed_extend")
