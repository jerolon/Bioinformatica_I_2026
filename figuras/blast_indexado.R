## Fig. @fig-indexado (Sesión 8, §8.1 Qué se indexa): qué indexa y qué
## recorre cada herramienta. Dos paneles con la misma gramática visual:
## BLAST indexa la consulta (chica) y recorre la base (grande); BLAT
## indexa el genoma (grande) y recorre la consulta (chica). Lo que se
## indexa va en NARANJA, lo que se recorre en AZUL: que el naranja salte
## de la caja chica a la cinta grande entre paneles es el punto entero.
##
## Esquema conceptual puro: no hay números, sólo geometría. Por eso no
## aplica la regla de "números calculados"; la figura calculada del
## E-value vive en blast_evalue_base.py.
##
## Script escrito: 2026-08-10 · R 4.6.0 · ggplot2 4.0.3 · svglite 2.2.2
##
## NOTA SOBRE EL TEMA: igual que en fig_msa_*.R, se usa figuras/estilo.R
## (no existe figuras/_tema.R en este repo) y los alias AZUL/NARANJA se
## definen acá. theme_void(): el lienzo es de 16 x 11 unidades ≈ cm.
##
## Regenerar:  Rscript figuras/blast_indexado.R   (desde la raíz)

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

AZUL    <- TEAL     # lo que se recorre
NARANJA <- AMBAR    # lo que se indexa

FAM <- familia_base()

## Rejilla de tiles centrada en (cx, cy), ncol x nrow con paso `pitch`.
rejilla <- function(cx, cy, ncol, nrow, pitch) {
  expand.grid(
    x = cx + (seq_len(ncol) - (ncol + 1) / 2) * pitch,
    y = cy + (seq_len(nrow) - (nrow + 1) / 2) * pitch
  )
}

txt <- function(x, y, label, size = 2.9, colour = TEXTO, ...) {
  annotate("text", x = x, y = y, label = label, family = FAM,
           size = size, colour = colour, lineheight = 1.05, ...)
}

flecha <- function(x, xend, y, yend = y, colour = GRIS, lw = 0.5, pt = 4.5) {
  annotate("segment", x = x, xend = xend, y = y, yend = yend,
           colour = colour, linewidth = lw,
           arrow = arrow(length = unit(pt, "pt"), type = "closed"))
}

p <- ggplot() +

  ## ---- panel superior: BLAST ------------------------------------------
  txt(0.5, 10.25, "BLAST", size = 4.4, fontface = "bold", hjust = 0) +

  ## la consulta, chica, NARANJA: es lo que se indexa
  annotate("rect", xmin = 0.9, xmax = 2.7, ymin = 8.35, ymax = 9.15,
           fill = alpha(NARANJA, 0.25), colour = NARANJA, linewidth = 0.6) +
  txt(1.8, 8.75, "consulta") +
  flecha(2.95, 4.15, 8.75) +

  ## su índice: una rejilla chica
  geom_tile(data = rejilla(5.25, 8.75, 4, 3, 0.42), aes(x, y),
            fill = alpha(NARANJA, 0.22), colour = NARANJA,
            linewidth = 0.35, width = 0.36, height = 0.36) +
  txt(5.25, 7.6, "tabla de palabras (índice)", size = 2.6) +

  ## la base de datos, cinta larga AZUL, pasa por delante del índice
  annotate("rect", xmin = 7.6, xmax = 15.5, ymin = 8.55, ymax = 8.95,
           fill = alpha(AZUL, 0.28), colour = AZUL, linewidth = 0.6) +
  txt(11.55, 9.35, "base de datos") +
  flecha(13.6, 7.4, 8.05, colour = AZUL, lw = 0.55, pt = 5) +

  txt(8, 6.55, "indexa lo chico, recorre lo grande",
      size = 3.1, fontface = "italic") +

  ## ---- divisor --------------------------------------------------------
  annotate("segment", x = 0.5, xend = 15.5, y = 5.9, yend = 5.9,
           colour = alpha(GRIS, 0.35), linewidth = 0.3) +

  ## ---- panel inferior: BLAT (invertido) -------------------------------
  txt(0.5, 5.45, "BLAT", size = 4.4, fontface = "bold", hjust = 0) +

  ## el genoma, cinta larga NARANJA: ahora lo grande es lo que se indexa
  annotate("rect", xmin = 0.9, xmax = 6.9, ymin = 3.45, ymax = 3.85,
           fill = alpha(NARANJA, 0.25), colour = NARANJA, linewidth = 0.6) +
  txt(3.9, 4.25, "genoma") +
  flecha(7.15, 8.1, 3.65) +

  ## su índice: una rejilla grande
  geom_tile(data = rejilla(9.85, 3.65, 6, 5, 0.5), aes(x, y),
            fill = alpha(NARANJA, 0.22), colour = NARANJA,
            linewidth = 0.35, width = 0.43, height = 0.43) +
  txt(9.85, 2.0, "índice de k-mers en RAM", size = 2.6) +

  ## la consulta, caja chica AZUL, pasa por delante del índice
  annotate("rect", xmin = 12.6, xmax = 14.2, ymin = 3.35, ymax = 3.95,
           fill = alpha(AZUL, 0.28), colour = AZUL, linewidth = 0.6) +
  txt(13.4, 4.35, "consulta") +
  flecha(14.7, 11.75, 2.85, colour = AZUL, lw = 0.55, pt = 5) +

  txt(8, 1.45, "indexa lo grande, recorre lo chico",
      size = 3.1, fontface = "italic") +

  ## ---- pie ------------------------------------------------------------
  txt(8, 0.45,
      "El megablast indexado del NCBI difumina esta dicotomía desde 2008.",
      size = 2.4, colour = GRIS, fontface = "italic") +

  coord_fixed(xlim = c(0, 16), ylim = c(0, 11), expand = FALSE,
              clip = "off") +
  theme_void(base_family = FAM) +
  theme(plot.margin = margin(2, 2, 2, 2), legend.position = "none")

guardar(p, "blast_indexado", ancho = 16 / 2.54, alto = 11 / 2.54)
