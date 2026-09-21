#!/usr/bin/env python3
"""Acuerdo por columna entre dos alineamientos múltiples de las MISMAS secuencias.

Para cada columna del alineamiento 1 se calcula qué fracción de sus pares de residuos
(i,j) sigue en la misma columna en el alineamiento 2 (la medida de la Figura 3 de la
sesión). Lee FASTA alineado o formato CLUSTAL. Solo biblioteca estándar.

uso:  acuerdo_por_columna.py ALN1 ALN2 [--ref NOMBRE] [--umbral 0.5] > acuerdo.tsv
      --ref     secuencia cuya numeración (sin gaps) se reporta junto a cada columna
      --umbral  columnas con acuerdo < umbral se agrupan en "regiones de desacuerdo" (stderr)
"""
import sys, argparse
from itertools import combinations

def leer(path):
    seqs, orden = {}, []
    with open(path) as fh:
        lineas = fh.read().splitlines()
    if lineas and lineas[0].startswith('>'):
        nombre = None
        for l in lineas:
            if l.startswith('>'):
                nombre = l[1:].split()[0]; orden.append(nombre); seqs[nombre] = []
            elif nombre:
                seqs[nombre].append(l.strip())
    else:  # CLUSTAL
        for l in lineas:
            if not l.strip() or l.upper().startswith('CLUSTAL') or l[0] in ' \t*:.':
                continue
            partes = l.split()
            if len(partes) < 2: continue
            nombre, bloque = partes[0], partes[1]
            if nombre not in seqs: orden.append(nombre); seqs[nombre] = []
            seqs[nombre].append(bloque)
    return orden, {k: ''.join(v).upper() for k, v in seqs.items()}

def mapa_col(seq):
    """residuo k (0-based, sin gaps) -> columna"""
    m = []
    for c, ch in enumerate(seq):
        if ch not in '-.': m.append(c)
    return m

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('aln1'); ap.add_argument('aln2')
    ap.add_argument('--ref'); ap.add_argument('--umbral', type=float, default=0.5)
    a = ap.parse_args()
    o1, s1 = leer(a.aln1); o2, s2 = leer(a.aln2)
    if set(o1) != set(o2):
        sys.exit(f'los alineamientos no tienen las mismas secuencias: {set(o1) ^ set(o2)}')
    for n in o1:
        if s1[n].replace('-', '').replace('.', '') != s2[n].replace('-', '').replace('.', ''):
            sys.exit(f'la secuencia {n} difiere (sin gaps) entre los dos archivos')
    L1 = len(next(iter(s1.values())))
    col2 = {n: mapa_col(s2[n]) for n in o1}          # (n, k) -> columna en aln2
    idx = {n: 0 for n in o1}                          # contador de residuos vistos en aln1
    ref = a.ref
    if ref and ref not in s1: sys.exit(f'--ref {ref} no está en el alineamiento')
    print('columna\tpos_' + (ref or 'ref') + '\tn_residuos\tn_pares\tpares_concordantes\tacuerdo')
    bajas = []
    for c in range(L1):
        res = []
        posref = ''
        for n in o1:
            ch = s1[n][c]
            if ch not in '-.':
                res.append((n, idx[n]))
                if n == ref: posref = str(idx[n] + 1)
                idx[n] += 1
        pares = list(combinations(res, 2))
        ok = sum(1 for (n1, k1), (n2, k2) in pares if col2[n1][k1] == col2[n2][k2])
        acc = ok / len(pares) if pares else float('nan')
        print(f'{c+1}\t{posref}\t{len(res)}\t{len(pares)}\t{ok}\t{acc:.3f}' if pares else f'{c+1}\t{posref}\t{len(res)}\t0\t0\tNA')
        if pares and acc < a.umbral: bajas.append(c + 1)
    # regiones contiguas (tolerando huecos de 1 columna)
    regiones = []
    for c in bajas:
        if regiones and c - regiones[-1][1] <= 2: regiones[-1][1] = c
        else: regiones.append([c, c])
    tot = sum(1 for _ in range(L1))
    sys.stderr.write(f'# columnas en aln1: {L1}; con acuerdo < {a.umbral}: {len(bajas)}\n')
    for i, (x, y) in enumerate(regiones, 1):
        sys.stderr.write(f'# region {i}: columnas {x}-{y} ({y-x+1} col)\n')

if __name__ == '__main__':
    main()
