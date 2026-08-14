## Fig. @fig-linea-tiempo (Sesión 01, § Una historia corta) — Línea del tiempo
## de la disciplina, 1965-2026.
##
## Es un ESQUEMA, no una figura de datos: lo único cuantitativo es la posición
## horizontal, proporcional al año. No hay eje Y.
##
## Las etiquetas se reparten en cuatro niveles (dos arriba, dos abajo) siguiendo
## el índice del hito. Con este juego de fechas, dos hitos del mismo nivel quedan
## siempre a 17 años o más, que es de sobra para que no se encimen; si se agregan
## o quitan hitos, revisar la comprobación de separación del final.
##
## Sin título dentro del SVG: el caption vive en el .qmd.
##
## Regenerar:  Rscript figuras/sesion01/linea-tiempo.R

# `estilo.R` vive en figuras/, un nivel arriba: se ubica este script para que
# `Rscript figuras/sesion01/<script>.R` corra desde la raíz del repo.
.ubicar <- function() {
  # Si el script se corrió con source() (RStudio, o desde otro script), el path
  # correcto es el `ofile` que source() deja en su frame. Se busca ESO primero:
  # commandArgs("--file=") apuntaría al script de AFUERA, no a éste.
  for (i in rev(seq_len(sys.nframe()))) {   # de adentro hacia afuera
    o <- sys.frame(i)$ofile
    if (!is.null(o)) return(normalizePath(o, winslash = "/"))
  }
  a <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1]), winslash = "/"))
  stop("no se pudo ubicar el script: correr con Rscript o con source()")
}
source(file.path(dirname(dirname(.ubicar())), "estilo.R"))

# --- Datos -----------------------------------------------------------------
# Fechas: ver la sección Fuentes del capítulo. Son las fechas de publicación o
# de anuncio de cada hito, no las de adopción.
HITOS <- data.frame(
  anio = c(1965, 1970, 1977, 1981, 1982, 1990, 1995, 2001, 2005, 2008, 2021, 2024),
  texto = c(
    "Dayhoff: Atlas de secuencias de proteína",
    "Needleman-Wunsch (alineamiento global) · se acuña 'bioinformática'",
    "Sanger: método de secuenciación · phi-X174",
    "Smith-Waterman (alineamiento local)",
    "GenBank y EMBL",
    "BLAST",
    "H. influenzae (primer organismo de vida libre)",
    "Borrador del genoma humano",
    "Secuenciación de siguiente generación (NGS)",
    "Quiebre del costo de secuenciación",
    "AlphaFold2",
    "AlphaFold3 · Nobel de Química"),
  stringsAsFactors = FALSE
)

# Los tres fundacionales van en ámbar: son los que discute el cuerpo del texto
# y a los que apunta el caption.
FUNDACIONALES <- c(1965, 1970, 1982)

# Niveles de etiqueta, ciclados por índice: arriba cerca, abajo cerca,
# arriba lejos, abajo lejos. Así dos hitos vecinos nunca comparten nivel.
NIVELES <- c(1.0, -1.0, 1.85, -1.85)

ANCHO_ETIQUETA    <- 26   # caracteres por línea antes de partir
SEPARACION_MINIMA <- 12   # años; umbral de la comprobación del final


nivel_de <- function(i) NIVELES[((i - 1) %% length(NIVELES)) + 1]


construir <- function() {
  d <- HITOS
  d$y      <- nivel_de(seq_len(nrow(d)))
  d$arriba <- d$y > 0
  d$color  <- ifelse(d$anio %in% FUNDACIONALES, AMBAR, TEAL)
  # Año en la primera línea y la descripción partida abajo, como en la versión
  # de matplotlib (textwrap.wrap con el mismo ancho).
  d$etiqueta <- paste0(d$anio, "\n",
                       vapply(d$texto,
                              function(t) paste(strwrap(t, ANCHO_ETIQUETA),
                                                collapse = "\n"),
                              character(1)))

  anio_min <- min(d$anio); anio_max <- max(d$anio)
  decadas  <- data.frame(anio = seq(1970, 2020, 10))

  ggplot(d) +
    # Línea base.
    annotate("segment", x = anio_min - 2.5, xend = anio_max + 2.5, y = 0, yend = 0,
             colour = GRIS, linewidth = 0.5, lineend = "round") +
    # Guía de cada punto a su etiqueta.
    geom_segment(aes(x = anio, xend = anio, y = 0, yend = y * 0.88),
                 colour = alpha(GRIS, 0.55), linewidth = 0.25) +
    # Marcas de década.
    geom_segment(data = decadas, aes(x = anio, xend = anio, y = -0.07, yend = 0.07),
                 colour = GRIS, linewidth = 0.32) +
    geom_text(data = decadas, aes(x = anio, y = -0.17, label = anio),
              vjust = 1, size = 3, colour = GRIS) +
    # Puntos, con halo blanco para que se despeguen de la línea base.
    geom_point(aes(x = anio, y = 0), colour = "white", size = 2.6) +
    geom_point(aes(x = anio, y = 0, colour = I(color)), size = 1.9) +
    # Etiquetas.
    geom_text(aes(x = anio, y = y * 0.95, label = etiqueta, colour = I(color),
                  vjust = ifelse(arriba, 0, 1)),
              hjust = 0.5, size = 2.65, lineheight = 1.35) +
    # Márgenes generosos: que 1965 y 2024 no se corten.
    coord_cartesian(xlim = c(anio_min - 6, anio_max + 6), ylim = c(-3.1, 3.1),
                    expand = FALSE, clip = "off") +
    theme_void(base_family = familia_base()) +
    theme(plot.margin = margin(2, 2, 2, 2))
}


if (!interactive()) {
  # Comprobación de encimado: dos hitos en el mismo nivel deben quedar lejos.
  y <- nivel_de(seq_len(nrow(HITOS)))
  peor <- NULL
  for (i in seq_len(nrow(HITOS))) {
    for (j in seq_len(nrow(HITOS))) {
      if (j <= i || y[i] != y[j]) next
      dif <- abs(HITOS$anio[j] - HITOS$anio[i])
      if (is.null(peor) || dif < peor$d) {
        peor <- list(d = dif, a = HITOS$anio[i], b = HITOS$anio[j])
      }
    }
  }
  message(sprintf("  hitos: %d  (%d-%d)", nrow(HITOS),
                  min(HITOS$anio), max(HITOS$anio)))
  message(sprintf("  separación mínima en un mismo nivel: %d años (%d vs %d)",
                  peor$d, peor$a, peor$b))
  if (peor$d < SEPARACION_MINIMA) {
    stop(sprintf(paste("hitos demasiado juntos en el mismo nivel: %d y %d;",
                       "reacomodar NIVELES o acortar la etiqueta"),
                 peor$a, peor$b))
  }
  guardar(construir(), "linea-tiempo", subdir = "sesion01",
          ancho = 7.6, alto = 4.4)
}
