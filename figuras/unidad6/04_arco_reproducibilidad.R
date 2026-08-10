## Fig. @fig-arco (Sesión 15, § Por qué esto cierra el arco)
## Los tres hitos de reproducibilidad del semestre, unidos por un arco.
##
## ---------------------------------------------------------------------------
## ES UNA FIGURA DE CIERRE Y PUEDE PERMITIRSE SER CEREMONIOSA
##
## Las quince sesiones van como marcas tenues: el punto no es el temario, es
## que los tres hitos están repartidos a lo largo de TODO el semestre y no
## fueron una unidad al final. El arco los une porque el argumento del capítulo
## es que las tres piezas son una sola cosa.
##
## Las tres etiquetas del arco son las tres piezas del antídoto tal como las
## enumera la prosa: versionar el código, registrar la procedencia, regenerar
## los resultados. Van sobre el arco, alineadas con el hito que les toca.
##
## Esquema: no afirma ninguna cantidad. Sin título dentro del SVG.
## ---------------------------------------------------------------------------
##
## Regenerar:  Rscript figuras/unidad6/04_arco_reproducibilidad.R

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

# --- Geometría, en milímetros (panel 156 x 66) ------------------------------
X0 <- 12; X1 <- 148          # extremos de la línea de tiempo
Y_LINEA <- 30
.x_sesion <- function(k) X0 + (k - 1) * (X1 - X0) / 14

sesiones <- data.frame(k = 1:15, x = .x_sesion(1:15), y = Y_LINEA)
sesiones$hito <- sesiones$k %in% c(1, 5, 11, 15)

# --- El arco ----------------------------------------------------------------
# Semielipse sobre la línea, de la sesión 1 a la 15.
.t <- seq(0, pi, length.out = 200)
arco <- data.frame(
  x = (X0 + X1)/2 - ((X1 - X0)/2) * cos(.t),
  y = Y_LINEA + 4 + 17 * sin(.t)
)

etiquetas_arco <- data.frame(
  x = c(.x_sesion(2.6), .x_sesion(8), .x_sesion(13.6)),
  y = c(50.5, 54.5, 50.5),
  lab = c("versionar\nel código", "registrar la procedencia",
          "regenerar\nlos resultados")
)

hitos <- data.frame(
  x = c(.x_sesion(1), .x_sesion(8), .x_sesion(15)),
  y = Y_LINEA,
  titulo = c("Sesión 1", "Sesiones 5 y 11", "Sesión 15"),
  detalle = c("git init", "accession, versión,\nfecha, checksum",
              "quarto render")
)
# Las sesiones 5 y 11 son dos marcas, pero una sola idea: la etiqueta va
# centrada entre ellas y las dos marcas van en naranja.
puentes_5_11 <- data.frame(x = c(.x_sesion(5), .x_sesion(11)), y = Y_LINEA)

p <- ggplot() +
  # el arco
  geom_path(data = arco, aes(x = x, y = y), colour = alpha(NARANJA, 0.55),
            linewidth = 0.6, lineend = "round") +
  geom_text(data = etiquetas_arco, aes(x = x, y = y, label = lab),
            family = familia_base(), colour = NARANJA, size = 2.9,
            fontface = "bold", lineheight = 0.95) +
  # la línea de tiempo y las quince marcas
  annotate("segment", x = X0 - 4, xend = X1 + 4, y = Y_LINEA, yend = Y_LINEA,
           colour = GRIS_BORDE, linewidth = 0.45) +
  geom_point(data = subset(sesiones, !hito), aes(x = x, y = y),
             colour = GRIS_TENUE, size = 1.1) +
  geom_point(data = puentes_5_11, aes(x = x, y = y),
             colour = NARANJA, size = 2.4) +
  geom_point(data = data.frame(x = c(.x_sesion(1), .x_sesion(15)), y = Y_LINEA),
             aes(x = x, y = y), colour = NARANJA, size = 2.8) +
  # etiquetas de los hitos, bajo la línea
  geom_text(data = hitos, aes(x = x, y = y - 6, label = titulo),
            family = familia_base(), fontface = "bold", colour = TEXTO,
            size = 3.0) +
  geom_text(data = hitos, aes(x = x, y = y - 13, label = detalle),
            family = familia_mono(), colour = GRIS, size = 2.6,
            lineheight = 1.0) +
  # el cierre, en prosa
  annotate("text", x = (X0 + X1)/2, y = 4,
           label = "un resultado que no puedes reproducir no es un resultado",
           family = familia_base(), fontface = "italic", colour = GRIS,
           size = 2.8) +
  coord_fixed(xlim = c(0, 160), ylim = c(0, 70), expand = FALSE) +
  tema_esquema()

guardar(p, "arco-reproducibilidad", w = 16, h = 7)
