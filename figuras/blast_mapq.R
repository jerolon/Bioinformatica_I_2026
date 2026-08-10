## Fig. @fig-mapq (Sesión 8, §9.3 MAPQ contra E-value): sorpresa contra
## unicidad. Panel izquierdo: el E-value pregunta cuántos aciertos así
## esperaría por azar en una base de este tamaño, y crece con la base.
## Panel derecho: el MAPQ pregunta qué tan seguro estoy de la posición;
## una lectura 100% idéntica que cae en dos sitios tiene MAPQ = 0.
##
## Esquema conceptual: los E-values del eje inferior (1e-40 → 1e-12, con
## el mismo bit score) son ilustrativos, sin espacio de búsqueda
## concreto; la versión calculada de esa dependencia es
## blast_evalue_base.py y esta figura no la duplica, la cita en chiquito.
##
## Script escrito: 2026-08-10 · R 4.6.0 · ggplot2 4.0.3 · svglite 2.2.2
##
## NOTA SOBRE EL TEMA: igual que en fig_msa_*.R, se usa figuras/estilo.R
## (no existe figuras/_tema.R en este repo) y los alias AZUL/NARANJA se
## definen acá. theme_void(): el lienzo es de 18 x 10 unidades ≈ cm.
##
## Regenerar:  Rscript figuras/blast_mapq.R   (desde la raíz)

.ubicar <- function() {
  for (i in rev(seq_len(sys.nframe()))) {
    o <- sys.frame(i)$ofile
    if (!is.null(o)) return(normalizePath(o, winslash = "/"))
  }
  a <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  if (length(a)) {
    return(normalizePath(sub("^--file=", "", a[1]), winslash = "/"))
  }
  stop("no se pudo ubicar el script: correr con Rscript o con source()")
}
source(file.path(dirname(.ubicar()), "estilo.R"))

AZUL    <- TEAL
NARANJA <- AMBAR

FAM  <- familia_base()
MONO <- familia_mono()

txt <- function(x, y, label, size = 2.9, colour = TEXTO, family = FAM, ...) {
  annotate("text", x = x, y = y, label = label, family = family,
           size = size, colour = colour, lineheight = 1.05, ...)
}

flecha <- function(x, xend, y, yend, colour = GRIS, lw = 0.5, pt = 4.5) {
  annotate("segment", x = x, xend = xend, y = y, yend = yend,
           colour = colour, linewidth = lw,
           arrow = arrow(length = unit(pt, "pt"), type = "closed"))
}

## Las cintas apiladas de la base de datos del panel izquierdo.
cintas <- data.frame(ymax = 7.55 - 0.48 * 0:5)
cintas$ymin <- cintas$ymax - 0.30

p <- ggplot() +

  ## ---- panel izquierdo: E-value = sorpresa ----------------------------
  txt(4.5, 9.45, "E-value: sorpresa", size = 3.6, fontface = "bold") +

  annotate("rect", xmin = 3.55, xmax = 5.45, ymin = 8.35, ymax = 8.9,
           fill = alpha(AZUL, 0.25), colour = AZUL, linewidth = 0.6) +
  txt(4.5, 8.62, "consulta", size = 2.5) +

  ## la base: muchas cintas apiladas, un solo acierto
  txt(1.1, 7.95, "base de datos", size = 2.4, colour = GRIS, hjust = 0) +
  annotate("rect", xmin = 1.1, xmax = 7.9, ymin = cintas$ymin,
           ymax = cintas$ymax, fill = alpha(GRIS, 0.28), colour = NA) +
  annotate("rect", xmin = 4.15, xmax = 5.15, ymin = 6.29, ymax = 6.59,
           fill = alpha(AZUL, 0.9), colour = NA) +
  annotate("segment", x = 4.5, xend = 4.65, y = 8.3, yend = 6.63,
           colour = GRIS, linewidth = 0.4, linetype = "22") +

  txt(4.5, 4.15,
      "¿cuántos así esperaría por azar\nen una base de este tamaño?",
      size = 2.7, colour = GRIS, fontface = "italic") +

  ## la dependencia del tamaño: mismo bit score, base más grande
  txt(4.5, 3.05, "base más grande", size = 2.6, colour = GRIS) +
  flecha(1.7, 7.3, 2.7, 2.7, colour = GRIS, lw = 0.5, pt = 5) +
  txt(1.7, 2.15, "E = 1e-40", size = 2.7, family = MONO, hjust = 0) +
  txt(7.3, 2.15, "E = 1e-12", size = 2.7, family = MONO, hjust = 1) +
  txt(4.5, 1.6, "mismo bit score", size = 2.4, colour = GRIS,
      fontface = "italic") +

  ## ---- divisor central ------------------------------------------------
  annotate("segment", x = 9, xend = 9, y = 1.4, yend = 9.6,
           colour = alpha(GRIS, 0.5), linewidth = 0.4) +

  ## ---- panel derecho: MAPQ = unicidad ---------------------------------
  txt(13.5, 9.45, "MAPQ: unicidad", size = 3.6, fontface = "bold") +

  ## arriba: dos sitios idénticos, confianza nula
  annotate("rect", xmin = 12.7, xmax = 14.3, ymin = 8.35, ymax = 8.9,
           fill = alpha(AZUL, 0.25), colour = AZUL, linewidth = 0.6) +
  txt(13.5, 8.62, "lectura", size = 2.5) +
  txt(10.0, 7.35, "genoma", size = 2.4, colour = GRIS, hjust = 0) +
  annotate("rect", xmin = 10.0, xmax = 17.0, ymin = 6.7, ymax = 7.02,
           fill = alpha(GRIS, 0.28), colour = NA) +
  annotate("rect", xmin = c(10.8, 15.1), xmax = c(11.8, 16.1),
           ymin = 6.62, ymax = 7.1,
           fill = alpha(NARANJA, 0.85), colour = NA) +
  flecha(13.15, 11.4, 8.3, 7.22, colour = NARANJA, lw = 0.5) +
  flecha(13.85, 15.55, 8.3, 7.22, colour = NARANJA, lw = 0.5) +
  txt(13.5, 5.9, "100% de identidad, MAPQ = 0", size = 3.0,
      colour = NARANJA, fontface = "bold") +

  ## abajo: un solo sitio candidato, confianza máxima
  annotate("rect", xmin = 12.7, xmax = 14.3, ymin = 4.5, ymax = 5.05,
           fill = alpha(AZUL, 0.25), colour = AZUL, linewidth = 0.6) +
  txt(13.5, 4.77, "lectura", size = 2.5) +
  annotate("rect", xmin = 10.0, xmax = 17.0, ymin = 2.85, ymax = 3.17,
           fill = alpha(GRIS, 0.28), colour = NA) +
  annotate("rect", xmin = 13.0, xmax = 14.0, ymin = 2.77, ymax = 3.25,
           fill = alpha(AZUL, 0.9), colour = NA) +
  flecha(13.5, 13.5, 4.45, 3.35, colour = AZUL, lw = 0.5) +
  txt(13.5, 2.15, "MAPQ = 60", size = 2.9, family = MONO) +

  ## ---- la frase que amarra --------------------------------------------
  txt(9, 0.55, "dos preguntas distintas, dos números que se ven parecidos",
      size = 3.0, fontface = "bold") +

  coord_fixed(xlim = c(0, 18), ylim = c(0, 10), expand = FALSE,
              clip = "off") +
  theme_void(base_family = FAM) +
  theme(plot.margin = margin(2, 2, 2, 2), legend.position = "none")

guardar(p, "blast_mapq", ancho = 18 / 2.54, alto = 10 / 2.54)
