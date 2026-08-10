"""
Paleta y configuración compartida de las figuras del capítulo 7.

Todos los scripts de figuras importan de aquí. Nadie teclea un hex suelto
(regla 5 del plan). El teal es el del curso.

Reglas de salida que impone este módulo:
  - svg.fonttype = 'none'  -> el texto queda como texto seleccionable, editable
    en CorelDRAW (regla 3 del plan).
  - guardar() usa metadata={'Date': None} -> sin <dc:date>: el diff de git
    queda limpio al regenerar (regla 4).
  - svg.hashsalt fijo -> los IDs internos del SVG (clips, gradientes) no cambian
    entre corridas, para que el diff sea de verdad limpio.

Además de la paleta trae helpers de rejilla (centro, celda, flecha) para que las
figuras 1, 2 y 3 compartan tamaño de celda y orientación (checklist del plan).
"""
import logging
import re
from pathlib import Path

import matplotlib as mpl
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch, Rectangle

# --- Paleta (regla 3 del plan). Único lugar donde vive un hex. ---
TEAL        = "#1a7a8a"   # primario
TEAL_CLARO  = "#2bb5c6"   # secundario / acentos / frentes de wavefront
FONDO_CELDA = "#e0f7fa"   # relleno suave de celda
AMBAR       = "#d98c00"   # alertas / lo que se descarta / inicialización
VERDE       = "#2e7d32"   # el camino óptimo (traceback)
MORADO      = "#7b4fa0"   # cuarto color categórico (ver nota)
GRIS        = "#666666"   # rejilla, ejes
TEXTO       = "#1a1a1a"

# Nota sobre MORADO. Los cuatro colores de arriba alcanzan para casi todo el
# libro, donde lo típico es una serie principal y un contraste. No alcanzan para
# una escala CATEGÓRICA de cinco o seis niveles: las figuras del código genético
# (figuras/sesion03/, en R) colorean los aminoácidos por clase química y
# ácido/básico es justo el contraste que no puede perderse. Vive acá también,
# aunque hoy ninguna figura de Python lo use, porque estilo.py y estilo.R son la
# misma paleta y esa promesa está escrita en el encabezado de los dos archivos.

# Derivados suaves para rellenos. No son hex "sueltos": son versiones claras de
# los tres colores con significado (verde = óptimo, ámbar = init, teal = celda).
VERDE_CLARO = "#d7ebd8"   # relleno de celda en el camino óptimo
AMBAR_CLARO = "#f6e4c3"   # relleno de celda de inicialización
GRIS_CLARO  = "#eef0f1"   # neutro: los ceros interiores de SW ("mar de ceros")

# Tamaño de celda, en unidades de datos. Mismo en las figuras 1, 2 y 3 para que
# la retícula se vea idéntica (argumento pedagógico del plan: es el mismo objeto).
CELDA = 1.0

SVG = Path(__file__).resolve().parent / "svg"

# Stack sans que matplotlib escribe para el texto normal (= el del sitio). Lo
# reusamos en guardar() para reescribir los pocos font-family "sueltos" que deja
# el mathtext y que si no quedarían en la fuente local en vez del stack del libro.
_STACK_SANS = "'Source Sans Pro', 'Segoe UI', 'Roboto', 'Helvetica Neue', 'Arial', sans-serif"
# Un font-family "suelto" es un solo nombre (sin coma) que cierra el valor. Se
# respetan las fuentes de símbolos matemáticos (cm*) y las stacks (llevan coma).
_FONT_SUELTO = re.compile(r"font-family: '(?!cm)[^',]+'(?=[\";])")


def configurar():
    """rcParams comunes. Llamar una vez al principio de cada script."""
    # El texto de las figuras usa el MISMO stack de fuentes que el sitio
    # (assets/css/quarto-lgc.scss): Source Sans Pro para las etiquetas, la
    # monoespaciada del tema para las secuencias. Como svg.fonttype='none', el
    # SVG guarda el nombre de la fuente y el navegador la pinta: al usar el
    # mismo stack que el cuerpo, la figura y el texto combinan —cargue o no
    # Source Sans Pro, porque el fallback es idéntico al del sitio—.
    logging.getLogger("matplotlib.font_manager").setLevel(logging.ERROR)
    mpl.rcParams.update({
        "svg.fonttype": "none",            # texto como texto (regla 3)
        "svg.hashsalt": "bioinfo1-cap07",  # IDs deterministas -> diff limpio
        "font.family": "sans-serif",
        "font.sans-serif": ["Source Sans Pro", "Segoe UI", "Roboto",
                            "Helvetica Neue", "Arial", "sans-serif"],
        "font.monospace": ["SFMono-Regular", "Menlo", "Consolas",
                           "Liberation Mono", "monospace"],
        "font.size": 11,
        "text.color": TEXTO,
        "axes.edgecolor": GRIS,
        "axes.linewidth": 0.8,
        "figure.dpi": 100,
    })


def guardar(fig, nombre, subdir="svg", transparent=False):
    """Guarda el SVG de forma determinista en figuras/<subdir>/<nombre>.svg.

    metadata={'Date': None} quita el <dc:date> que matplotlib mete por defecto;
    sin eso, cada regeneración ensucia el diff de git (regla 4). `subdir` deja
    agrupar por capítulo (p. ej. 'ncbi'); `transparent` para figuras que se
    embeben sin caja de fondo.
    """
    destino = Path(__file__).resolve().parent / subdir
    destino.mkdir(exist_ok=True)
    ruta = destino / f"{nombre}.svg"
    fig.savefig(ruta, format="svg", bbox_inches="tight", metadata={"Date": None},
                transparent=transparent)
    plt.close(fig)
    # El mathtext (ticks de ejes log, $S'$…) escribe la fuente resuelta suelta
    # ('Segoe UI', 'DejaVu Sans'…) en vez del stack. La reescribimos al stack del
    # libro para que TODO el texto combine con el cuerpo, sin tocar símbolos cm*
    # ni la mono (que ya va como stack).
    txt = ruta.read_text(encoding="utf-8")
    txt = _FONT_SUELTO.sub(f"font-family: {_STACK_SANS}", txt)
    ruta.write_text(txt, encoding="utf-8")
    print(f"  escrito figuras/{subdir}/{nombre}.svg")
    return ruta


# --- Helpers de rejilla (compartidos por figs 1, 2, 3, 5, 6) ---

def centro(i, j):
    """Centro (x, y) de la celda (i, j). Fila 0 arriba: y decrece hacia abajo."""
    return (j * CELDA, -i * CELDA)


def celda(ax, i, j, relleno=None, borde=GRIS, lw=0.8, z=1):
    """Dibuja el recuadro de la celda (i, j). Devuelve el Rectangle."""
    x, y = centro(i, j)
    rect = Rectangle((x - CELDA / 2, y - CELDA / 2), CELDA, CELDA,
                     facecolor=relleno if relleno else "none",
                     edgecolor=borde, linewidth=lw, zorder=z)
    ax.add_patch(rect)
    return rect


def flecha(ax, desde_ij, hacia_ij, color=GRIS, lw=1.2, encoge=0.42, alpha=1.0,
           z=3, escala=10):
    """Flecha del centro de `desde_ij` hacia el de `hacia_ij`, encogida en los
    extremos para no encimarse con el número de cada celda. `escala` es el
    tamaño de la punta."""
    x0, y0 = centro(*desde_ij)
    x1, y1 = centro(*hacia_ij)
    dx, dy = x1 - x0, y1 - y0
    d = (dx ** 2 + dy ** 2) ** 0.5
    ux, uy = dx / d, dy / d
    p0 = (x0 + ux * encoge, y0 + uy * encoge)
    p1 = (x1 - ux * encoge, y1 - uy * encoge)
    ax.add_patch(FancyArrowPatch(p0, p1, arrowstyle="-|>", mutation_scale=escala,
                                 color=color, lw=lw, alpha=alpha, zorder=z))


def encabezados(ax, seq_col, seq_fil, cero="", color=TEXTO):
    """Escribe las letras de cada secuencia fuera de la retícula: seq_col arriba,
    seq_fil a la izquierda. `cero` es la etiqueta de la fila/columna 0 (p. ej. '-')."""
    # esquina cero
    if cero:
        xc, yc = centro(0, 0)
        ax.text(xc, yc + CELDA, cero, ha="center", va="center",
                color=color, fontsize=11, fontweight="bold")
        ax.text(xc - CELDA, yc, cero, ha="center", va="center",
                color=color, fontsize=11, fontweight="bold")
    for j, letra in enumerate(seq_col, start=1):
        x, y = centro(0, j)
        ax.text(x, y + CELDA, letra, ha="center", va="center",
                color=color, fontsize=12, fontweight="bold")
    for i, letra in enumerate(seq_fil, start=1):
        x, y = centro(i, 0)
        ax.text(x - CELDA, y, letra, ha="center", va="center",
                color=color, fontsize=12, fontweight="bold")


def marco_limpio(ax, m, n, margen=1.4):
    """Quita ejes y fija límites/relación de aspecto para una retícula (m+1)x(n+1)."""
    ax.set_aspect("equal")
    ax.axis("off")
    ax.set_xlim(-margen, n * CELDA + margen - 0.4)
    ax.set_ylim(-m * CELDA - margen + 0.4, margen)
