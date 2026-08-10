"""
Fig. blast_evd (§4) — Distribución de valores extremos (Gumbel) vs normal.

Los scores de alineamiento local óptimo entre secuencias aleatorias siguen una
EVD, no una normal. En escala logarítmica en y se ve lo que importa: la cola
derecha. Todo se calcula de las fórmulas (regla 1).

Parámetros verificados (instrucciones §3): Gumbel con λ=1, u=0; la normal de
comparación usa la MISMA media y varianza, μ = u + γ/λ = 0.5772 y
σ = π/(√6·λ) = 1.2825. En x=10 la densidad de la Gumbel es ~77 millones de veces
la de la normal: ése es el argumento entero del apartado en un número.

Regenerar:  python figuras/blast_evd.py
"""
import numpy as np
import matplotlib.pyplot as plt

import estilo

LAM, U = 1.0, 0.0
EULER = 0.5772156649


def _gumbel(x):
    z = LAM * (x - U)
    return LAM * np.exp(-z - np.exp(-z))


def _normal(x):
    mu = U + EULER / LAM
    sd = np.pi / (LAM * np.sqrt(6))
    return np.exp(-((x - mu) ** 2) / (2 * sd ** 2)) / (sd * np.sqrt(2 * np.pi))


def construir():
    estilo.configurar()
    x = np.linspace(-2, 10, 700)
    g, n = _gumbel(x), _normal(x)
    mu = U + EULER / LAM

    fig, ax = plt.subplots(figsize=(7.6, 4.8))
    ax.semilogy(x, n, color=estilo.GRIS, lw=2.2, ls="--",
                label="normal (misma media y varianza)")
    ax.semilogy(x, g, color=estilo.TEAL, lw=2.8,
                label="valores extremos (Gumbel)")

    cola = (x > mu) & (g > n)
    ax.fill_between(x, n, g, where=cola, color=estilo.AMBAR, alpha=0.25, zorder=1)

    # El número que resume el apartado: en x=10, Gumbel / normal ≈ 77 millones.
    gx, nx = _gumbel(10.0), _normal(10.0)
    ax.scatter([10, 10], [gx, nx], s=32, color=[estilo.TEAL, estilo.GRIS],
               zorder=5, ec="white")
    ax.annotate("", xy=(10, gx), xytext=(10, nx),
                arrowprops=dict(arrowstyle="<|-|>", color=estilo.AMBAR, lw=1.4))
    ax.annotate(f"en x = 10 la Gumbel es\n≈ 77 millones de veces\nla normal",
                xy=(10, np.sqrt(gx * nx)), xytext=(6.0, 3e-9), fontsize=9.2,
                color=estilo.TEXTO, ha="center",
                arrowprops=dict(arrowstyle="-|>", color=estilo.AMBAR, lw=1.2))

    ax.set_xlabel("score de alineamiento local", fontsize=11)
    ax.set_ylabel("densidad (escala log)", fontsize=11)
    ax.set_ylim(1e-13, 1)
    ax.set_xlim(-2, 10)
    ax.grid(True, which="major", axis="y", color=estilo.GRIS, alpha=0.13, lw=0.7)
    for lado in ("top", "right"):
        ax.spines[lado].set_visible(False)
    ax.legend(loc="lower left", fontsize=9.3, frameon=False)
    ax.set_title("Los scores por azar siguen una EVD, no una normal",
                 fontsize=11.5, color=estilo.TEXTO, pad=10)
    fig.tight_layout()
    return fig


if __name__ == "__main__":
    for xi in (4, 6, 8, 10):
        print(f"  x={xi:>2}  Gumbel={_gumbel(float(xi)):.2e}  "
              f"normal={_normal(float(xi)):.2e}  razón={_gumbel(float(xi))/_normal(float(xi)):.1e}")
    estilo.guardar(construir(), "blast_evd")
