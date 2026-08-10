"""
Needleman–Wunsch y Smith–Waterman, una sola implementación.

Las figuras 2 y 3 importan de aquí para que usen exactamente el mismo motor
(regla 1 del plan: los números de las figuras se calculan, no se teclean; y si
cada figura trae su propio NW, divergen).

Convención de índices, igual que en el capítulo:
  - seq_col  va en el eje horizontal (columnas j = 1..n).
  - seq_fil  va en el eje vertical   (filas    i = 1..m).
  - La matriz es F[i, j] con la fila 0 y la columna 0 de inicialización.

Punteros de procedencia (para dibujar flechas y empates). Para cada celda se
guarda el conjunto de movimientos que ALCANZAN el máximo:
  - 'diag'   : viene de (i-1, j-1)  -> alinear a_i con b_j
  - 'arriba' : viene de (i-1, j)    -> movimiento vertical (gap)
  - 'izq'    : viene de (i,   j-1)  -> movimiento horizontal (gap)
Guardar todos los que empatan es lo que permite dibujar varios caminos óptimos.

Esquema de puntaje. Por defecto es el de la práctica (match/mismatch/gap
escalares, todo entero). Pasando `sub=` —un dict anidado sub[a][b], p. ej. el
esquema transición/transversión del §3— cada par de bases tiene su propio peso;
entonces la tabla es de flotantes y los empates se comparan con tolerancia.
"""
import numpy as np

MOVS = {"diag": (-1, -1), "arriba": (-1, 0), "izq": (0, -1)}

# Tolerancia para decidir si dos candidatos empatan. Con enteros da lo mismo;
# con una matriz de sustitución en flotantes, `==` se pierde empates reales por
# error de redondeo (0.1+0.2 != 0.3) y la figura dejaría de dibujar ramas que sí
# existen.
TOL = 1e-9

# Esquema transición/transversión del §3 de algoritmos.qmd (la tabla que sigue a
# "…más probables que las transversiones"). Las transiciones A<->G y C<->T se
# castigan menos (−0.608, −0.596) que las transversiones (−1.346), y cada match
# vale distinto. Es simétrica; se escribe entera para poder leerla como la tabla.
TRANSICIONES = {
    "A": {"A":  0.527, "C": -1.346, "G": -0.608, "T": -1.346},
    "C": {"A": -1.346, "C":  1.000, "G": -1.346, "T": -0.596},
    "G": {"A": -0.608, "C": -1.346, "G":  0.697, "T": -1.346},
    "T": {"A": -1.346, "C": -0.596, "G": -1.346, "T":  0.730},
}


def _s(a, b, match, mismatch, sub=None):
    if sub is not None:
        return sub[a][b]
    return match if a == b else mismatch


def matriz_diagonal(seq_col, seq_fil, match=1, mismatch=-1, sub=None):
    """La matriz `Diagonal` del turista de Manhattan: m x n, el peso de la arista
    diagonal que entra a cada celda interior. Diagonal[i-1, j-1] = s(a_i, b_j)."""
    return np.array([[_s(a, b, match, mismatch, sub) for b in seq_col]
                     for a in seq_fil], dtype=float)


def needleman_wunsch(seq_col, seq_fil, match=1, mismatch=-1, gap=-1, sub=None):
    """Alineamiento global. Devuelve un dict con F, punteros, score y metadatos."""
    n, m = len(seq_col), len(seq_fil)
    F = np.zeros((m + 1, n + 1), dtype=float if sub is not None else int)
    punteros = {(0, 0): ()}

    for i in range(1, m + 1):
        F[i, 0] = F[i - 1, 0] + gap
        punteros[(i, 0)] = ("arriba",)
    for j in range(1, n + 1):
        F[0, j] = F[0, j - 1] + gap
        punteros[(0, j)] = ("izq",)

    for i in range(1, m + 1):
        for j in range(1, n + 1):
            cand = {
                "diag": F[i - 1, j - 1] + _s(seq_fil[i - 1], seq_col[j - 1],
                                             match, mismatch, sub),
                "arriba": F[i - 1, j] + gap,
                "izq": F[i, j - 1] + gap,
            }
            mejor = max(cand.values())
            F[i, j] = mejor
            punteros[(i, j)] = tuple(mov for mov, v in cand.items()
                                     if abs(v - mejor) <= TOL)

    score = F[m, n]
    return {
        "tipo": "NW", "F": F, "punteros": punteros,
        "score": float(score) if sub is not None else int(score),
        "D": matriz_diagonal(seq_col, seq_fil, match, mismatch, sub),
        "seq_col": seq_col, "seq_fil": seq_fil, "m": m, "n": n,
        "params": dict(match=match, mismatch=mismatch, gap=gap, sub=sub),
    }


def smith_waterman(seq_col, seq_fil, match=1, mismatch=-1, gap=-1, sub=None):
    """Alineamiento local. Los bordes quedan en 0 y la recurrencia añade el 0.
    Una celda cuyo máximo es 0 no tiene puntero: ahí el alineamiento reinicia."""
    n, m = len(seq_col), len(seq_fil)
    H = np.zeros((m + 1, n + 1), dtype=float if sub is not None else int)
    punteros = {}
    for j in range(n + 1):
        punteros[(0, j)] = ()
    for i in range(m + 1):
        punteros[(i, 0)] = ()

    for i in range(1, m + 1):
        for j in range(1, n + 1):
            cand = {
                "diag": H[i - 1, j - 1] + _s(seq_fil[i - 1], seq_col[j - 1],
                                             match, mismatch, sub),
                "arriba": H[i - 1, j] + gap,
                "izq": H[i, j - 1] + gap,
            }
            mejor = max(0, *cand.values())
            H[i, j] = mejor
            punteros[(i, j)] = (tuple(mov for mov, v in cand.items()
                                      if abs(v - mejor) <= TOL)
                                if mejor > 0 else ())

    return {
        "tipo": "SW", "F": H, "punteros": punteros,
        "score": float(H.max()) if sub is not None else int(H.max()),
        "D": matriz_diagonal(seq_col, seq_fil, match, mismatch, sub),
        "seq_col": seq_col, "seq_fil": seq_fil, "m": m, "n": n,
        "params": dict(match=match, mismatch=mismatch, gap=gap, sub=sub),
    }


def _pred(celda, mov):
    di, dj = MOVS[mov]
    return (celda[0] + di, celda[1] + dj)


def optimo(res, inicios=None):
    """Sub-grafo de traceback óptimo alcanzable hacia atrás desde `inicios`.

    NW: inicios por defecto = {(m, n)} (la esquina).
    SW: pasar los máximos globales (ver maximos()).

    Devuelve (celdas, aristas) donde `celdas` es el conjunto de celdas en algún
    camino óptimo y `aristas` es el conjunto de (celda, mov) de esos caminos.
    Todo puntero que sale de una celda alcanzable es, por optimalidad, una arista
    óptima: por eso basta recorrer hacia atrás siguiendo punteros.
    """
    if inicios is None:
        inicios = [(res["m"], res["n"])]
    celdas, aristas, pila, vistas = set(), set(), list(inicios), set()
    while pila:
        cel = pila.pop()
        if cel in vistas:
            continue
        vistas.add(cel)
        celdas.add(cel)
        for mov in res["punteros"].get(cel, ()):
            aristas.add((cel, mov))
            p = _pred(cel, mov)
            celdas.add(p)
            pila.append(p)
    return celdas, aristas


def contar_caminos(res, inicios=None):
    """Número de caminos óptimos distintos (para respaldar 'los empates existen')."""
    if inicios is None:
        inicios = [(res["m"], res["n"])]
    memo = {}

    def caminos(cel):
        if not res["punteros"].get(cel):          # llegó al origen / a un 0
            return 1
        if cel in memo:
            return memo[cel]
        memo[cel] = sum(caminos(_pred(cel, mov)) for mov in res["punteros"][cel])
        return memo[cel]

    return sum(caminos(c) for c in inicios)


def maximos(res):
    """Celdas que alcanzan el máximo global (inicio del traceback en SW)."""
    H = res["F"]
    mx = int(H.max())
    return mx, [(int(i), int(j)) for i, j in np.argwhere(H == mx)]


def alineamientos(res, inicios=None, limite=8):
    """Reconstruye los alineamientos óptimos como pares de cadenas (con '-').
    Útil para verificar a mano lo que dibuja la figura."""
    if inicios is None:
        inicios = [(res["m"], res["n"])]
    sc, sf = res["seq_col"], res["seq_fil"]
    salida = []

    def bajar(cel, top, bot):
        if len(salida) >= limite:
            return
        if not res["punteros"].get(cel):
            salida.append(("".join(reversed(top)), "".join(reversed(bot))))
            return
        i, j = cel
        for mov in sorted(res["punteros"][cel]):
            if mov == "diag":
                bajar(_pred(cel, mov), top + [sc[j - 1]], bot + [sf[i - 1]])
            elif mov == "arriba":
                bajar(_pred(cel, mov), top + ["-"], bot + [sf[i - 1]])
            else:
                bajar(_pred(cel, mov), top + [sc[j - 1]], bot + ["-"])

    for c in inicios:
        bajar(c, [], [])
    return salida


if __name__ == "__main__":
    # Verificación rápida contra las cifras del plan (regla 1: calcular, no inventar).
    print("== NW GCATGCG / GATTACA (match+1, mismatch-1, gap-1) ==")
    r = needleman_wunsch("GCATGCG", "GATTACA")
    print("  score NW =", r["score"], "| caminos óptimos =", contar_caminos(r))
    for a, b in alineamientos(r):
        print("   ", a, "/", b)

    print("== fig 2b: mismo par, esquema transición/transversión (gap -1) ==")
    rt = needleman_wunsch("GCATGCG", "GATTACA", gap=-1, sub=TRANSICIONES)
    print(f"  score NW = {rt['score']:.3f} | caminos óptimos = {contar_caminos(rt)}")
    for a, b in alineamientos(rt):
        print("   ", a, "/", b)

    print("== fig 3: GCGATTAG (col) / TTGATTACA (fil) ==")
    rn = needleman_wunsch("GCGATTAG", "TTGATTACA")
    rs = smith_waterman("GCGATTAG", "TTGATTACA")
    mx, celdas = maximos(rs)
    print("  score NW =", rn["score"], "| caminos NW =", contar_caminos(rn))
    print("  score SW =", rs["score"], "| máximos en", celdas)
    print("  interiores en 0 (SW):",
          int((rs["F"][1:, 1:] == 0).sum()), "de", rs["m"] * rs["n"])
