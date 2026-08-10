## Fig. @fig-escalamiento (Sesión 9, § Por qué la programación dinámica
## no escala): costo de la PD exacta (L^N) contra el alineamiento
## progresivo (N^2·L^2), en escala logarítmica.
##
## Generada: 2026-08-09 · R 4.6.0 (2026-04-24 ucrt) · ggplot2 4.0.3 ·
## svglite 2.2.2. Datos deterministas calculados acá mismo; no hay
## archivo de entrada ni herramientas externas.
##
## ---------------------------------------------------------------------------
## NOTA SOBRE EL TEMA. La especificación pide source("figuras/_tema.R"),
## pero en este repo no existe un _tema.R al nivel de figuras/: el tema
## central es figuras/estilo.R y los _tema.R son adaptadores por sesión
## (sesion01/ ... sesion11/, unidad6/). Se usa estilo.R directamente y
## los alias AZUL/NARANJA que pide la especificación se definen acá,
## igual que hacen los adaptadores. estilo.R además impone lo que la
## especificación exige del SVG: svglite con fix_text_size = FALSE,
## fondo transparente, texto como texto y sin título dentro del SVG.
## ---------------------------------------------------------------------------
##
## Regenerar:  Rscript figuras/fig_msa_escalamiento.R   (desde la raíz)

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

# Alias con los nombres de la especificación (ver nota de arriba).
AZUL    <- TEAL     # alineamiento progresivo
NARANJA <- AMBAR    # programación dinámica exacta

# --- Datos ------------------------------------------------------------------
L <- 300
N <- 2:10

exacta     <- data.frame(N = N, ops = L^N)         # hipercubo completo
progresivo <- data.frame(N = N, ops = N^2 * L^2)   # orden N^2·L^2

# Un petaflop durante un año: 1e15 op/s por ~3.15e7 s ~ 3e22 operaciones.
PETAFLOP_ANIO <- 3e22

# La curva exacta debe cruzar esa línea entre N = 9 y N = 10 con L = 300;
# si alguien cambia L o el umbral, la anotación deja de ser cierta y el
# script tiene que fallar acá, no producir una figura que miente.
stopifnot(L^9 < PETAFLOP_ANIO, L^10 > PETAFLOP_ANIO)

# --- La figura --------------------------------------------------------------
p <- ggplot(mapping = aes(x = N, y = ops)) +
  geom_hline(yintercept = PETAFLOP_ANIO, linetype = "dashed",
             colour = GRIS, linewidth = 0.4) +
  geom_line(data = exacta, colour = NARANJA, linewidth = 0.9) +
  geom_line(data = progresivo, colour = AZUL, linewidth = 0.9) +
  # Etiquetas sobre las curvas, no leyenda aparte.
  annotate("text", x = 5.6, y = 1e15, label = "programación dinámica exacta",
           hjust = 1, colour = NARANJA, family = familia_base(),
           fontface = "bold", size = 3.2) +
  annotate("text", x = 6.5, y = 6e7, label = "alineamiento progresivo",
           hjust = 0.5, colour = AZUL, family = familia_base(),
           fontface = "bold", size = 3.2) +
  annotate("text", x = 2, y = PETAFLOP_ANIO,
           label = "un petaflop durante un año",
           hjust = 0, vjust = -0.7, colour = GRIS,
           family = familia_base(), size = 2.9) +
  scale_x_continuous(breaks = N) +
  scale_y_log10(labels = scales::label_log()) +
  labs(x = "número de secuencias N", y = "operaciones (escala log)") +
  tema_lgc() +
  theme(panel.background = element_rect(fill = "transparent", colour = NA),
        plot.background  = element_rect(fill = "transparent", colour = NA))

guardar(p, "msa_escalamiento", subdir = "svg", ancho = 7, alto = 4.2)
