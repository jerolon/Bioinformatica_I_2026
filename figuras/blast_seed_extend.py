"""
Fig. blast_seed_extend (§3) — Seed-and-extend con score REAL de BLOSUM62.

El perfil de score y los bordes del HSP se calculan (instrucciones cap. 8, §3):
se recorre un par de secuencias de juguete acumulando BLOSUM62 desde una semilla,
y la extensión para donde el acumulado cae X por debajo de su máximo (X-drop).
El HSP es el segmento entre los máximos de cada dirección.

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
from matplotlib.patches import FancyBboxPatch

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
    cum = np.cumsum(sc)
    L = len(sc)
    bl, br, pl, pr, gl, gr = _extender(sc, SEED[0], SEED[1], X)
    # HSP = [bl, br]; su score en el eje acumulado
    seed_sc = int(sc[SEED[0]:SEED[1]].sum())
    hsp_sc = int(sc[bl:br + 1].sum())
    pico = cum[br]              # nivel del máximo acumulado (borde derecho)

    fig, (axc, axl) = plt.subplots(
        2, 1, figsize=(9.6, 5.4), sharex=True,
        gridspec_kw={"height_ratios": [2.1, 1.3], "hspace": 0.08})

    # --- Panel de score acumulado ---
    axc.axvspan(bl - 0.5, br + 0.5, color=estilo.VERDE_CLARO, zorder=0)
    axc.plot(range(L), cum, color=estilo.TEAL, lw=2.2, zorder=3)
    axc.scatter(range(L), cum, s=12, color=estilo.TEAL, zorder=4)
    # máximo (borde derecho del HSP)
    axc.scatter([br], [cum[br]], s=60, color=estilo.VERDE, zorder=5, ec="white")
    axc.annotate("máximo → borde del HSP", xy=(br, cum[br]),
                 xytext=(br - 8.5, cum[br] + 6), fontsize=9, color=estilo.VERDE,
                 arrowprops=dict(arrowstyle="-|>", color=estilo.VERDE, lw=1.2))
    # umbral de X-drop y punto donde para la extensión (derecha)
    axc.axhline(pico - X, ls=":", lw=1.2, color=estilo.AMBAR, zorder=2)
    axc.text(L - 0.5, pico - X + 1.5, "máximo − X", ha="right", va="bottom",
             fontsize=8.5, color=estilo.AMBAR)
    axc.scatter([pr], [cum[pr]], s=45, color=estilo.AMBAR, zorder=5, ec="white")
    axc.annotate("cae X bajo el máximo:\nla extensión para (X-drop)",
                 xy=(pr, cum[pr]), xytext=(pr - 1.5, cum[pr] - 30), fontsize=8.6,
                 color=estilo.AMBAR, ha="center",
                 arrowprops=dict(arrowstyle="-|>", color=estilo.AMBAR, lw=1.2))
    axc.set_ylabel("score acumulado\n(BLOSUM62)", fontsize=10)
    axc.set_ylim(cum.min() - 12, cum.max() + 16)
    for lado in ("top", "right"):
        axc.spines[lado].set_visible(False)
    axc.tick_params(labelbottom=False)

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
    axl.text((bl + br) / 2, -1.25, f"HSP  (score {hsp_sc}; la semilla sola vale {seed_sc})",
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
    estilo.guardar(construir(), "blast_seed_extend")
