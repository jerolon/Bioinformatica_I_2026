## Fig. blast_tres (OPCIONAL, Sesión 8, §9.4): las tres herramientas como
## tres preguntas. Una columna por herramienta, con un icono simple (lupa
## para BLAST, alfiler sobre mapa para BLAT, lluvia de lecturas para BWA),
## la pregunta que contesta en grande, y los detalles técnicos en chico.
## El punto no es la tabla: es que son tres preguntas distintas.
##
## NO ESTÁ REFERENCIADA EN EL .QMD: la sección 9.4 tiene la misma
## información como tabla Markdown. Se generó para compararla contra la
## tabla y decidir; si gana, se inserta y se quita la tabla.
##
## Script escrito: 2026-08-10 · R 4.6.0 · ggplot2 4.0.3 · svglite 2.2.2
##
## NOTA SOBRE EL TEMA: igual que en fig_msa_*.R, se usa figuras/estilo.R
## (no existe figuras/_tema.R en este repo) y los alias AZUL/NARANJA se
## definen acá. theme_void(): el lienzo es de 16 x 12 unidades ≈ cm.
##
## Regenerar:  Rscript figuras/blast_tres.R   (desde la raíz)

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

FAM <- familia_base()

CX <- c(2.85, 8.0, 13.15)   # centros de las tres columnas

txt <- function(x, y, label, size = 2.9, colour = TEXTO, ...) {
  annotate("text", x = x, y = y, label = label, family = FAM,
           size = size, colour = colour, lineheight = 1.08, ...)
}

circulo <- function(cx, cy, r, n = 100) {
  t <- seq(0, 2 * pi, length.out = n)
  data.frame(x = cx + r * cos(t), y = cy + r * sin(t))
}

## Los detalles técnicos, en chico, bajo cada pregunta.
detalles <- function(cx, lineas) {
  ys <- 5.9 - 0.78 * (seq_along(lineas) - 1)
  lapply(seq_along(lineas), function(i) {
    txt(cx - 1.85, ys[i], lineas[i], size = 2.45, colour = GRIS, hjust = 0)
  })
}

p <- ggplot() +

  ## ---- divisores de columna -------------------------------------------
  annotate("segment", x = c(5.42, 10.58), xend = c(5.42, 10.58),
           y = 2.1, yend = 11.3, colour = alpha(GRIS, 0.3),
           linewidth = 0.3) +

  ## ---- icono BLAST: una lupa ------------------------------------------
  geom_path(data = circulo(2.85, 10.15, 0.52), aes(x, y),
            colour = AZUL, linewidth = 1.0) +
  annotate("segment", x = 3.22, xend = 3.68, y = 9.78, yend = 9.32,
           colour = AZUL, linewidth = 1.3, lineend = "round") +

  ## ---- icono BLAT: un alfiler sobre un mapa ---------------------------
  annotate("rect", xmin = 7.05, xmax = 8.95, ymin = 9.35, ymax = 10.25,
           fill = alpha(GRIS, 0.12), colour = GRIS, linewidth = 0.5) +
  annotate("segment", x = c(7.68, 8.32), xend = c(7.68, 8.32),
           y = 9.35, yend = 10.25, colour = alpha(GRIS, 0.4),
           linewidth = 0.35) +
  annotate("polygon", x = c(7.82, 8.18, 8.0), y = c(10.05, 10.05, 9.62),
           fill = AZUL, colour = NA) +
  geom_polygon(data = circulo(8.0, 10.15, 0.27), aes(x, y),
               fill = AZUL, colour = NA) +
  annotate("point", x = 8.0, y = 10.15, colour = "white", size = 1.1) +

  ## ---- icono BWA: lluvia de lecturas sobre una línea ------------------
  annotate("point",
           x = c(12.5, 12.95, 13.4, 13.8, 12.7, 13.6, 13.15),
           y = c(10.6, 10.25, 10.55, 10.2, 9.95, 9.9, 10.05),
           colour = AZUL, size = 1.5) +
  annotate("segment", x = c(12.6, 13.2, 13.75), xend = c(12.6, 13.2, 13.75),
           y = c(9.85, 9.9, 9.78), yend = 9.58,
           colour = alpha(GRIS, 0.6), linewidth = 0.35) +
  annotate("segment", x = 12.2, xend = 14.1, y = 9.42, yend = 9.42,
           colour = AZUL, linewidth = 0.9, lineend = "round") +

  ## ---- nombres --------------------------------------------------------
  txt(CX[1], 8.75, "BLAST", size = 4.6, fontface = "bold") +
  txt(CX[2], 8.75, "BLAT",  size = 4.6, fontface = "bold") +
  txt(CX[3], 8.75, "BWA",   size = 4.6, fontface = "bold") +

  ## ---- las preguntas, que son el punto de la figura -------------------
  txt(CX[1], 7.65, "¿qué se parece\na esto?",
      size = 3.9, colour = AZUL, fontface = "bold") +
  txt(CX[2], 7.65, "¿dónde está esto\nen este genoma?",
      size = 3.9, colour = AZUL, fontface = "bold") +
  txt(CX[3], 7.65, "¿de dónde vino\ncada una?",
      size = 3.9, colour = AZUL, fontface = "bold") +

  ## ---- los detalles, subordinados -------------------------------------
  detalles(CX[1], c("indexa · la consulta",
                    "recorre · la base de datos",
                    "identidad · hasta ~25%",
                    "salida · tabular",
                    "su número · E-value (sorpresa)")) +
  detalles(CX[2], c("indexa · el genoma",
                    "recorre · la consulta",
                    "identidad · ≥ 95%",
                    "salida · PSL, exones cosidos",
                    "su número · identidad y bloques")) +
  detalles(CX[3], c("indexa · el genoma (índice FM)",
                    "recorre · las lecturas",
                    "identidad · ≥ ~95%",
                    "salida · SAM/BAM",
                    "su número · MAPQ (unicidad)")) +

  coord_fixed(xlim = c(0, 16), ylim = c(0, 12), expand = FALSE,
              clip = "off") +
  theme_void(base_family = FAM) +
  theme(plot.margin = margin(2, 2, 2, 2), legend.position = "none")

guardar(p, "blast_tres", ancho = 16 / 2.54, alto = 12 / 2.54)
