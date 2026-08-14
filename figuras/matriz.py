"""
dibujar_matriz(): la retícula de DP llena — números, celdas de inicialización,
flechas de procedencia en cada celda y camino óptimo en verde.

Compartida por fig02 (NW) y fig03 (NW vs SW) para que las dos usen el mismo
dibujo y no diverjan (mismo motivo por el que comparten nw_sw.py). Sirve igual
para NW y SW: el tipo lo trae `res["tipo"]`.
"""
import estilo
from estilo import centro
import nw_sw


def num(v):
    """Formato por defecto de los números de la retícula: entero cuando el valor
    es entero (esquema match/mismatch) y tres decimales cuando no (matriz de
    sustitución). Así la fig. 2 sigue diciendo '−3' y no '−3.000'."""
    v = float(v)
    return str(int(round(v))) if abs(v - round(v)) < nw_sw.TOL else f"{v:.3f}"


def dibujar_matriz(ax, res, *, inicios=None, marcar_maximo=False, encoge=0.30,
                   flechas="todas", fmt=num, fmt_diag=None, fs_num=10,
                   fs_diag=6.5, sep_diag=0.0):
    """Dibuja la matriz de `res` en `ax`.

    inicios        : celdas donde arranca el traceback. NW -> esquina (default);
                     SW -> los máximos globales (ver nw_sw.maximos).
    marcar_maximo  : resalta con borde verde la(s) celda(s) de `inicios` (SW).
    flechas        : "todas" (procedencia en cada celda, fig. 2) | "optimo"
                     (sólo el camino óptimo, para la comparación densa de fig. 3)
                     | "diagonales" (camino óptimo + TODAS las aristas diagonales
                     rotuladas con su peso, o sea la matriz Diagonal dibujada
                     encima de la retícula) | "ninguna".
    fmt            : cómo se escribe cada número de celda (ver num()).
    fmt_diag       : ídem para los pesos diagonales; por defecto, el mismo. Los
                     pesos vienen de una tabla y conviene escribirlos todos con
                     los mismos decimales ('1.000', no '1').
    sep_diag       : separación del rótulo respecto a su flecha, en
                     perpendicular. 0 = encima de la arista (lo normal para un
                     peso); súbelo si el rótulo tapa algo.
    """
    if fmt_diag is None:
        fmt_diag = fmt
    F, m, n = res["F"], res["m"], res["n"]
    es_sw = res["tipo"] == "SW"
    celdas_opt, aristas_opt = nw_sw.optimo(res, inicios)

    # 1) Rellenos.
    for i in range(m + 1):
        for j in range(n + 1):
            if (i, j) in celdas_opt:
                relleno = estilo.VERDE_CLARO
            elif i == 0 or j == 0:
                relleno = estilo.AMBAR_CLARO            # borde de init (regla del plan)
            elif es_sw and F[i, j] == 0:
                relleno = estilo.GRIS_CLARO             # ceros interiores de SW
            else:
                relleno = "white"
            estilo.celda(ax, i, j, relleno=relleno, borde=estilo.GRIS, lw=0.8)

    # 2a) Todas las aristas diagonales, ganen o no. Son la matriz Diagonal: la
    # única tabla que cambia al cambiar el esquema de puntaje, así que dibujarlas
    # todas con su peso es dibujar el dato de entrada, no el resultado.
    if flechas == "diagonales":
        for i in range(1, m + 1):
            for j in range(1, n + 1):
                if ((i, j), "diag") in aristas_opt:
                    continue                        # esa va en verde, más abajo
                estilo.flecha(ax, (i, j), (i - 1, j - 1), color=estilo.GRIS,
                              lw=0.8, encoge=encoge, alpha=0.45, escala=8, z=2)

    # 2b) Flechas de procedencia. Las del camino óptimo, en verde y gruesas.
    for i in range(m + 1):
        for j in range(n + 1):
            for mov in res["punteros"].get((i, j), ()):
                di, dj = nw_sw.MOVS[mov]
                pred = (i + di, j + dj)
                opt = ((i, j), mov) in aristas_opt
                if flechas == "ninguna" or (flechas in ("optimo", "diagonales")
                                            and not opt):
                    continue
                estilo.flecha(ax, (i, j), pred,
                              color=estilo.VERDE if opt else estilo.GRIS,
                              lw=2.4 if opt else 0.9,
                              encoge=encoge,
                              alpha=1.0 if opt else 0.6,
                              escala=13 if opt else 9,
                              z=4 if opt else 2)

    # 2c) El peso de cada arista diagonal, escrito sobre su propia flecha (el
    # punto medio de cada diagonal cae en una esquina distinta de la retícula,
    # así que no hay dos rótulos que compitan). En teal, porque es un peso del
    # problema y no un valor calculado: esos son los negros de las celdas.
    if flechas == "diagonales":
        D = res["D"]
        for i in range(1, m + 1):
            for j in range(1, n + 1):
                x0, y0 = centro(i, j)
                x1, y1 = centro(i - 1, j - 1)
                opt = ((i, j), "diag") in aristas_opt
                ax.text((x0 + x1) / 2 + sep_diag, (y0 + y1) / 2 + sep_diag,
                        fmt_diag(D[i - 1, j - 1]), ha="center", va="center",
                        color=estilo.VERDE if opt else estilo.TEAL,
                        fontweight="bold" if opt else "normal",
                        fontsize=fs_diag, zorder=5,
                        bbox=dict(boxstyle="round,pad=0.12", facecolor="white",
                                  edgecolor="none", alpha=0.8))

    # 3) Números.
    for i in range(m + 1):
        for j in range(n + 1):
            x, y = centro(i, j)
            if i == 0 or j == 0:
                color, peso = estilo.AMBAR, "bold"
            elif (i, j) in celdas_opt:
                color, peso = estilo.TEXTO, "bold"
            else:
                color, peso = estilo.TEXTO, "normal"
            ax.text(x, y, fmt(F[i, j]), ha="center", va="center",
                    color=color, fontweight=peso, fontsize=fs_num, zorder=5)

    # 4) Inicio del traceback en SW: borde verde en el máximo global.
    if marcar_maximo and inicios:
        for celda in inicios:
            estilo.celda(ax, *celda, borde=estilo.VERDE, lw=2.6, z=6)

    estilo.encabezados(ax, res["seq_col"], res["seq_fil"], cero="–")
    estilo.marco_limpio(ax, m, n)
