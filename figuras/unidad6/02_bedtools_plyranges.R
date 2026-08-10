## Fig. @fig-bedtools-plyranges (Sesión 14, § El mismo verbo, otra sintaxis)
## La correspondencia entre lo que hicieron en la terminal y lo que van a
## hacer en R.
##
## ---------------------------------------------------------------------------
## LA TABLA NO SE SOSTIENE SOLA, Y POR ESO LLEVA EL RENGLÓN NARANJA ABAJO
##
## Una tabla de equivalencias, leída sin más, dice "es lo mismo con otra
## sintaxis", que es justo la lectura que el capítulo quiere evitar. Lo que
## cambia no es el verbo: es lo que el objeto sabe de sí mismo. De ahí la línea
## naranja debajo de la línea divisoria, que es la única afirmación de la
## figura.
##
## La llamada al margen del renglón de `slop` está porque `anchor_center()` es
## el ejemplo más limpio de esa diferencia: bedtools ASUME qué extremo se fija,
## plyranges OBLIGA a decirlo. Va en gris y chica: es una nota, no un tercer
## encabezado.
##
## Los comandos van en monoespaciada (familia_mono()) porque el texto ES
## código y tiene que caer en retícula. _tema.R -> estilo.R se encarga de que
## el post-proceso del SVG no se lleve la mono por delante.
##
## Esquema: no afirma ninguna cantidad. Sin título dentro del SVG.
## ---------------------------------------------------------------------------
##
## Regenerar:  Rscript figuras/unidad6/02_bedtools_plyranges.R

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

# --- Geometría, en milímetros (panel 156 x 106) -----------------------------
X_BT    <- 4      # columna izquierda, hjust 0
X_FLE   <- 72     # la flecha, centrada
X_PR    <- 82     # columna derecha, hjust 0
Y_ENC   <- 100    # encabezados
Y_LINEA <- 96     # regla bajo los encabezados

filas <- data.frame(
  bt = c("bedtools intersect", "bedtools merge", "bedtools sort",
         "bedtools subtract", "bedtools closest", "bedtools slop",
         "bedtools getfasta"),
  pr = c("join_overlap_inner()", "reduce_ranges()", "arrange()",
         "setdiff_ranges()", "join_nearest()",
         "anchor_center() %>% stretch()", "getSeq()"),
  y  = c(88, 79, 70, 61, 52, 43, 30)
)
Y_NOTA_SLOP <- 37   # entre slop y getfasta

Y_DIV   <- 22       # línea divisoria
Y_PUNTO <- 15       # la afirmación, en naranja

p <- ggplot() +
  # encabezados
  annotate("text", x = X_BT, y = Y_ENC, label = "en la terminal (sesión 11)",
           hjust = 0, family = familia_base(), fontface = "bold",
           colour = GRIS, size = 3.1) +
  annotate("text", x = X_PR, y = Y_ENC, label = "en R (hoy)",
           hjust = 0, family = familia_base(), fontface = "bold",
           colour = GRIS, size = 3.1) +
  annotate("segment", x = X_BT, xend = 156, y = Y_LINEA, yend = Y_LINEA,
           colour = GRIS_BORDE, linewidth = 0.35) +
  # los pares
  geom_text(data = filas, aes(x = X_BT, y = y, label = bt), hjust = 0,
            family = familia_mono(), colour = TEXTO, size = 3.0) +
  geom_text(data = filas, aes(x = X_PR, y = y, label = pr), hjust = 0,
            family = familia_mono(), colour = AZUL, size = 3.0) +
  geom_text(data = filas, aes(x = X_FLE, y = y), label = "↔",
            family = familia_base(), colour = GRIS, size = 3.6) +
  # llamada al margen del renglón de slop
  annotate("text", x = X_BT + 4, y = Y_NOTA_SLOP,
           label = paste("bedtools asume qué extremo se fija;",
                         "plyranges obliga a decirlo"),
           hjust = 0, family = familia_base(), fontface = "italic",
           colour = GRIS, size = 2.6) +
  # la afirmación
  annotate("segment", x = X_BT, xend = 156, y = Y_DIV, yend = Y_DIV,
           colour = GRIS_BORDE, linewidth = 0.35) +
  annotate("text", x = X_BT, y = Y_PUNTO,
           label = paste("el objeto GRanges sabe su genoma y su",
                         "sistema de coordenadas;"),
           hjust = 0, family = familia_base(), fontface = "bold",
           colour = NARANJA, size = 3.1) +
  annotate("text", x = X_BT, y = Y_PUNTO - 6,
           label = "un archivo BED no sabe nada.",
           hjust = 0, family = familia_base(), fontface = "bold",
           colour = NARANJA, size = 3.1) +
  coord_fixed(xlim = c(0, 160), ylim = c(0, 110), expand = FALSE) +
  tema_esquema()

guardar(p, "bedtools-plyranges", w = 16, h = 11)
