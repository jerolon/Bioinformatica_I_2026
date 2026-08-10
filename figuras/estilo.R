## Paleta y configuración compartida de las figuras hechas en R (ggplot2 + svglite).
##
## Es el gemelo de estilo.py: MISMA paleta, mismos hex, misma tipografía. Un
## capítulo puede tener figuras en Python y en R y verse igual. Si el tema del
## libro cambia, se cambia en los dos archivos.
##
## Reglas de salida que impone este módulo:
##   - svglite escribe el texto como <text>, no como paths: las etiquetas quedan
##     editables en CorelDRAW. Es la razón de usar svglite y no el device svg()
##     de base R, que vectoriza.
##   - fix_text_size = FALSE: sin atributos textLength. Con textLength puesto,
##     editar una etiqueta en CorelDRAW la estira o la aplasta para respetar el
##     ancho original. Sin él, el texto se comporta como texto normal.
##   - svglite no escribe fecha ni IDs aleatorios (sus ids de clip salen de las
##     coordenadas), así que dos corridas dan bytes idénticos y el diff de git
##     queda limpio al regenerar. Comprobado.
##   - guardar() reescribe el font-family que resuelve svglite (una sola familia,
##     la que haya en la máquina) por el stack completo del libro, para que la
##     figura combine con el cuerpo del sitio aunque Source Sans Pro no esté
##     instalada. Mismo truco que estilo.py.

suppressPackageStartupMessages({
  library(ggplot2)
  library(svglite)
  library(scales)
})

# --- Paleta. Único lugar donde vive un hex (regla compartida con estilo.py). ---
TEAL        <- "#1a7a8a"   # primario
TEAL_CLARO  <- "#2bb5c6"   # secundario / acentos
FONDO_CELDA <- "#e0f7fa"   # relleno suave
AMBAR       <- "#d98c00"   # contraste / referencia / lo que se descarta
VERDE       <- "#2e7d32"   # acento terciario
MORADO      <- "#7b4fa0"   # cuarto color categórico (ver nota)
GRIS        <- "#666666"   # rejilla, ejes, texto secundario
TEXTO       <- "#1a1a1a"

# Nota sobre MORADO. Los cuatro colores de arriba alcanzan para casi todo el
# libro, donde lo típico es una serie principal y un contraste. No alcanzan
# para una escala CATEGÓRICA de cinco o seis niveles: las figuras del código
# genético colorean los aminoácidos por clase química (hidrofóbico, polar,
# ácido, básico, especial) y ácido/básico son justo el contraste que no puede
# perderse. Con TEAL y TEAL_CLARO esos dos quedaban a un paso de distancia en
# el mismo tono. De ahí el quinto tono.
# Está en estilo.py también, para no romper el pacto de que las dos paletas son
# la misma aunque hoy ninguna figura de Python lo use.

# El mismo stack que assets/css/quarto-lgc.scss. Va con comillas DOBLES porque
# svglite delimita el atributo style con comillas simples.
STACK_SANS <- paste0('"Source Sans Pro", "Segoe UI", "Roboto", ',
                     '"Helvetica Neue", "Arial", sans-serif')

# Stack monoespaciado, para las figuras de esquema donde el texto ES código
# (anatomía de un FASTA, un pipeline) y tiene que caer en una retícula de ancho
# fijo. Mismo criterio que STACK_SANS: se escribe el stack completo, no la
# familia que resolvió esta máquina.
STACK_MONO <- paste0('"Source Code Pro", "Consolas", "DejaVu Sans Mono", ',
                     '"Courier New", monospace')

# Preferencias de familia, en orden. Se usa la primera instalada para que R no
# tire warnings de fuente faltante; el SVG final lleva el stack completo de
# todos modos, así que en el navegador manda el stack, no esta elección.
.FAMILIAS      <- c("Source Sans Pro", "Segoe UI", "Roboto", "Helvetica Neue", "Arial")
.FAMILIAS_MONO <- c("Source Code Pro", "Consolas", "DejaVu Sans Mono",
                    "Courier New", "Liberation Mono", "Menlo", "monospace")


familia_base <- function() {
  instaladas <- unique(systemfonts::system_fonts()$family)
  hit <- .FAMILIAS[.FAMILIAS %in% instaladas]
  if (length(hit)) hit[1] else ""
}


#' Gemela de familia_base() para texto que es código.
familia_mono <- function() {
  instaladas <- unique(systemfonts::system_fonts()$family)
  hit <- .FAMILIAS_MONO[.FAMILIAS_MONO %in% instaladas]
  if (length(hit)) hit[1] else "mono"
}


#' Tema del libro. Equivale a los rcParams de estilo.py::configurar().
tema_lgc <- function(base_size = 11) {
  theme_minimal(base_size = base_size, base_family = familia_base()) +
    theme(
      text             = element_text(colour = TEXTO),
      axis.title       = element_text(size = rel(0.96), colour = TEXTO),
      axis.text        = element_text(size = rel(0.86), colour = TEXTO),
      axis.line        = element_line(colour = GRIS, linewidth = 0.35),
      axis.ticks       = element_line(colour = GRIS, linewidth = 0.35),
      axis.ticks.length = unit(2.5, "pt"),
      panel.grid.major = element_line(colour = alpha(GRIS, 0.16), linewidth = 0.35),
      panel.grid.minor = element_blank(),
      panel.background = element_blank(),
      plot.background  = element_blank(),
      legend.background = element_blank(),
      legend.key       = element_blank(),
      legend.title     = element_blank(),
      legend.text      = element_text(size = rel(0.86)),
      # Nota de fuente: gris, chica, en cursiva y pegada al borde izquierdo de
      # la figura (no del panel), como la ponía estilo.py.
      plot.caption     = element_text(size = rel(0.73), colour = GRIS,
                                      face = "italic", hjust = 0,
                                      margin = margin(t = 8)),
      plot.caption.position = "plot",
      plot.title       = element_blank(),   # el caption vive en el .qmd
      plot.margin      = margin(4, 6, 4, 4)
    )
}


#' Guarda el SVG de forma determinista en figuras/<subdir>/<nombre>.svg.
#'
#' @param p       objeto ggplot
#' @param nombre  sin extensión
#' @param subdir  subcarpeta dentro de figuras/ (p. ej. "sesion01")
#' @param ancho,alto  pulgadas
#' @param transparent  sin caja de fondo, para embeber en el sitio
guardar <- function(p, nombre, subdir = "svg", ancho = 6.3, alto = 3.9,
                    transparent = TRUE) {
  destino <- file.path(DIR_FIGURAS, subdir)
  dir.create(destino, showWarnings = FALSE, recursive = TRUE)
  ruta <- file.path(destino, paste0(nombre, ".svg"))

  svglite(ruta, width = ancho, height = alto,
          bg = if (transparent) "transparent" else "white",
          fix_text_size = FALSE)
  print(p)
  invisible(grDevices::dev.off())

  # svglite resuelve UNA familia ("Arial" si no hay Source Sans Pro). Se cambia
  # por el stack del libro para que el navegador use la misma cascada que el
  # cuerpo del texto. No se tocan otras propiedades del style.
  txt <- readLines(ruta, warn = FALSE, encoding = "UTF-8")

  # Las monoespaciadas se marcan ANTES para que el reemplazo de abajo no se las
  # lleve por delante. Sin esto, una figura de esquema calcula su retícula con
  # los avances de una mono y el navegador la rellena con glifos
  # proporcionales: las columnas dejan de cuadrar y las letras se encinan.
  # (Pasó, y no se ve en R: sólo aparece después del post-proceso.)
  for (fm in .FAMILIAS_MONO) {
    txt <- gsub(sprintf('font-family: "%s";', fm), "font-family: @@MONO@@;",
                txt, fixed = TRUE)
  }
  txt <- gsub('font-family: "[^"]+";', paste0("font-family: ", STACK_SANS, ";"),
              txt, perl = TRUE)
  txt <- gsub("font-family: @@MONO@@;", paste0("font-family: ", STACK_MONO, ";"),
              txt, fixed = TRUE)
  con <- file(ruta, open = "wb")
  writeLines(txt, con, useBytes = TRUE)
  close(con)

  message(sprintf("  escrito figuras/%s/%s.svg", subdir, nombre))
  invisible(ruta)
}


# --- Ubicación de figuras/ -------------------------------------------------
# R no tiene __file__. Se busca el `ofile` que source() deja en los frames de
# llamada; si estilo.R se corre directo con Rscript, se usa --file=.
.ubicar_figuras <- function() {
  # De ADENTRO hacia afuera: el `ofile` más cercano es el de este archivo. Si se
  # recorriera al revés y alguien sourcea un script de figura desde otro script
  # (p. ej. un "regenerar todo"), el primer ofile sería el del script de afuera
  # y figuras/ quedaría mal resuelto: los SVG terminarían en sesion01/sesion01/.
  for (i in rev(seq_len(sys.nframe()))) {
    of <- sys.frame(i)$ofile
    if (!is.null(of)) return(dirname(normalizePath(of, winslash = "/")))
  }
  a <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  if (length(a)) {
    return(dirname(normalizePath(sub("^--file=", "", a[1]), winslash = "/")))
  }
  normalizePath(getwd(), winslash = "/")
}

DIR_FIGURAS <- .ubicar_figuras()


# --- Formateadores de eje compartidos --------------------------------------

# Un número sin notación científica y sin decimales de más. OJO: format() es
# vectorizado y elige UN formato común para todo el vector, así que sobre un
# eje log convierte el 1000 en "1e+03". Por eso los formateadores de abajo
# trabajan elemento por elemento con formatC.
.num <- function(x, dig = 0) formatC(x, format = "f", digits = dig)

# Fábrica de formateadores por escala: devuelve una función de eje.
.fmt_escala <- function(escalas, sep = "", prefijo = "") {
  function(v) {
    vapply(v, function(x) {
      if (is.na(x)) return(NA_character_)
      for (e in escalas) {
        u <- as.numeric(e[[1]])
        if (abs(x) >= u) return(paste0(prefijo, .num(x / u), sep, e[[2]]))
      }
      paste0(prefijo, .num(x))
    }, character(1))
  }
}

#' Dinero corto y legible: $100, $1K, $100K, $1M, $100M.
fmt_dolar <- .fmt_escala(list(list(1e6, "M"), list(1e3, "K")), prefijo = "$")

#' Bases en Kb / Mb / Gb / Tb.
fmt_bases <- .fmt_escala(list(list(1e12, "Tb"), list(1e9, "Gb"),
                              list(1e6, "Mb"), list(1e3, "Kb")), sep = " ")

#' Conteos en K / M / G.
fmt_conteo <- .fmt_escala(list(list(1e9, "G"), list(1e6, "M"), list(1e3, "K")),
                          sep = " ")

#' Año decimal a partir de (año, mes), tomando el punto medio del mes.
a_fraccion <- function(anio, mes) anio + (mes - 0.5) / 12
