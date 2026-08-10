## Fig. @fig-r-python (Sesión 12, § R o Python)
## El reparto entre R y Python, por TAREA.
##
## ---------------------------------------------------------------------------
## LA FRANJA DEL MEDIO ES LA FIGURA
##
## Sin la franja de puentes esto parece una comparación, y una comparación
## invita a elegir bando. Con la franja se ve que la respuesta del capítulo es
## "los dos": las dos columnas desembocan en el mismo lugar y la flecha es
## bidireccional. Por eso la franja va en NARANJA, del ancho completo y
## cruzando las dos columnas, no como un pie de página.
##
## Las columnas son de TAREAS, no de lenguajes: los encabezados dicen "donde
## gana R" y "donde gana Python", no "R" y "Python". La decisión es por tarea.
##
## Esquema: no afirma ninguna cantidad más que la de Bioconductor, que está en
## la prosa del capítulo. Sin título dentro del SVG.
## ---------------------------------------------------------------------------
##
## Regenerar:  Rscript figuras/unidad6/01_r_vs_python.R

.ubicar <- function() {
  for (i in rev(seq_len(sys.nframe()))) {
    o <- sys.frame(i)$ofile
    if (!is.null(o)) return(normalizePath(o, winslash = "/"))
  }
  a <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1]), winslash = "/"))
  stop("no se pudo ubicar el script: correr con Rscript o con source()")
}
source(file.path(dirname(.ubicar()), "_tema.R"))

# --- Geometría, en milímetros (panel 156 x 96) ------------------------------
X_IZQ <- 4;  W_COL <- 74
X_DER <- 82
Y_COL_TOP <- 96; Y_COL_BOT <- 40
Y_BANDA_TOP <- 30; Y_BANDA_BOT <- 12

cajas <- data.frame(
  xmin = c(X_IZQ, X_DER),
  xmax = c(X_IZQ + W_COL, X_DER + W_COL),
  ymin = Y_COL_BOT, ymax = Y_COL_TOP,
  color = c(AZUL, VERDE)
)

encabezados <- data.frame(
  x = c(X_IZQ + W_COL/2, X_DER + W_COL/2),
  y = Y_COL_TOP - 7,
  lab = c("donde gana R", "donde gana Python"),
  color = c(AZUL, VERDE)
)

items_r <- c(
  "genómica estadística",
  "   DESeq2 · edgeR · limma",
  "álgebra de intervalos",
  "   GenomicRanges",
  "gráficas de publicación",
  "   ggplot2",
  "Bioconductor: >2400 paquetes"
)
items_py <- c(
  "aprendizaje profundo",
  "   PyTorch · JAX",
  "célula única a gran escala",
  "   scanpy · scverse",
  "orquestación de pipelines",
  "   Nextflow · Snakemake",
  "ingeniería de software"
)

.y_items <- function(n, top = Y_COL_TOP - 16, paso = 5.4) {
  top - (seq_len(n) - 1) * paso
}

items <- rbind(
  data.frame(x = X_IZQ + 5, y = .y_items(length(items_r)), lab = items_r,
             sub = grepl("^ ", items_r)),
  data.frame(x = X_DER + 5, y = .y_items(length(items_py)), lab = items_py,
             sub = grepl("^ ", items_py))
)
items$lab <- trimws(items$lab)
items$x   <- items$x + ifelse(items$sub, 4, 0)

# --- La franja de puentes ---------------------------------------------------
banda <- data.frame(xmin = X_IZQ, xmax = X_DER + W_COL,
                    ymin = Y_BANDA_BOT, ymax = Y_BANDA_TOP)

# Bajadas de cada columna hacia la franja: las dos desembocan en lo mismo.
bajadas <- data.frame(
  x = c(X_IZQ + W_COL/2, X_DER + W_COL/2),
  xend = c(X_IZQ + W_COL/2, X_DER + W_COL/2),
  y = Y_COL_BOT - 1.5, yend = Y_BANDA_TOP + 1.5
)

p <- ggplot() +
  geom_rect(data = cajas,
            aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
            fill = "transparent", colour = cajas$color, linewidth = 0.45) +
  geom_text(data = encabezados, aes(x = x, y = y, label = lab),
            colour = encabezados$color, family = familia_base(),
            fontface = "bold", size = 3.5) +
  geom_text(data = items, aes(x = x, y = y, label = lab),
            hjust = 0, family = familia_base(), colour = TEXTO,
            size = ifelse(items$sub, 2.6, 3.0),
            fontface = ifelse(items$sub, "italic", "plain")) +
  geom_segment(data = bajadas, aes(x = x, xend = xend, y = y, yend = yend),
               colour = GRIS, linewidth = 0.4,
               arrow = arrow(length = unit(1.6, "mm"), type = "closed")) +
  # la franja
  geom_rect(data = banda,
            aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
            fill = alpha(NARANJA, 0.13), colour = NARANJA, linewidth = 0.5) +
  annotate("text", x = (X_IZQ + X_DER + W_COL)/2, y = Y_BANDA_TOP - 6,
           label = "puentes", family = familia_base(), fontface = "bold",
           colour = NARANJA, size = 3.4) +
  annotate("text", x = (X_IZQ + X_DER + W_COL)/2, y = Y_BANDA_TOP - 11.5,
           label = "reticulate  ·  zellkonverter  ·  anndata",
           family = familia_mono(), colour = TEXTO, size = 2.9) +
  annotate("segment", x = X_IZQ + 10, xend = X_DER + W_COL - 10,
           y = Y_BANDA_BOT + 3.5, yend = Y_BANDA_BOT + 3.5,
           colour = NARANJA, linewidth = 0.5,
           arrow = arrow(length = unit(1.8, "mm"), ends = "both",
                         type = "closed")) +
  coord_fixed(xlim = c(0, 160), ylim = c(0, 100), expand = FALSE) +
  labs(caption = "Panorama de 2026. Este reparto cambia.") +
  tema_esquema()

guardar(p, "r-vs-python", w = 16, h = 10)
