"""
Fig. (A10-d) — El E-value del MISMO alineamiento crece con el tamaño de la base.

E = m · n · 2^(−S'), con bit score S' fijo. El bit score no cambia; el E-value
sí, en proporción a n. Un alineamiento significativo en la base chica de los
noventa es ruido en la base de hoy. Todo calculado (regla 1); los tamaños de nr
son órdenes de magnitud ilustrativos.

Regenerar:  python figuras/blast_evalue_base.py
"""
import numpy as np
import matplotlib.pyplot as plt

import estilo

SP = 40        # bit score fijo
M = 300        # longitud de la query (residuos)
UMBRAL = 0.01  # umbral típico de significancia


def E(n):
    return M * n * 2.0 ** (-SP)


def construir():
    estilo.configurar()
    n = np.logspace(6, 12, 300)
    fig, ax = plt.subplots(figsize=(7.4, 4.6))

    ax.loglog(n, E(n), color=estilo.TEAL, lw=2.8, zorder=3)

    # Umbral de significancia (punteado, ámbar) y zona significativa.
    ax.axhline(UMBRAL, color=estilo.AMBAR, ls=":", lw=1.5, zorder=2)
    ax.text(1.2e6, UMBRAL * 1.5, "umbral típico  E = 0.01", fontsize=9,
            color=estilo.AMBAR, va="bottom")
    ax.axhspan(1e-6, UMBRAL, color=estilo.VERDE, alpha=0.05, zorder=0)

    # Dos puntos: misma query, mismo alineamiento, base de dos épocas.
    def fmt(e):
        return f"E ≈ {e:,.0f}" if e >= 1 else f"E ≈ {e:.2g}"

    puntos = [
        (1e7,  "base ~1993 (nr chico)\nsignificativo", (2.2e7, 4e-2), "bottom"),
        (1e11, "base contemporánea\nruido",            (1.1e10, 1.2), "top"),
    ]
    for nn, etq, xytext, va in puntos:
        ee = E(nn)
        ax.plot(nn, ee, "o", ms=9, color=estilo.AMBAR, mec="white", mew=1.2, zorder=5)
        ax.annotate(f"{etq}\n{fmt(ee)}", xy=(nn, ee), xytext=xytext,
                    ha="center", va=va, fontsize=9, color=estilo.TEXTO,
                    arrowprops=dict(arrowstyle="-", color=estilo.AMBAR, lw=1),
                    zorder=6)

    ax.set_xlabel("tamaño de la base  $n$  (residuos)", fontsize=11)
    ax.set_ylabel("E-value  (bit score fijo, $S' = 40$)", fontsize=11)
    ax.set_ylim(1e-4, 1e3)
    ax.set_xlim(1e6, 1e12)
    ax.grid(True, which="major", color=estilo.GRIS, alpha=0.18, lw=0.7)
    for lado in ("top", "right"):
        ax.spines[lado].set_visible(False)
    ax.set_title("El mismo alineamiento pasa de significativo a ruido",
                 fontsize=11.5, color=estilo.TEXTO, pad=10)
    fig.tight_layout()
    return fig


if __name__ == "__main__":
    for nn, _ in [(1e7, ""), (1e11, "")]:
        print(f"  n={nn:.0e}  E={E(nn):.3g}")
    estilo.guardar(construir(), "blast_evalue_base")
