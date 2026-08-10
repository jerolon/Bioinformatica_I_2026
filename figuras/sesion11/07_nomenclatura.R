## Fig. @fig-nomenclatura (Sesión 11, § chr17 contra 17)
## El error silencioso: un BED estilo UCSC contra un GTF estilo Ensembl da
## cero intersecciones y ningún mensaje de error.
##
## ---------------------------------------------------------------------------
## LA CAJA DEL RESULTADO ESTÁ VACÍA A PROPÓSITO
##
## Es el punto entero de la figura. Un error que grita se corrige solo; éste no
## grita. La caja de resultado no lleva una X ni un símbolo de error: lleva
## nada, porque eso es literalmente lo que devuelve `bedtools intersect`. El
## rótulo naranja de abajo es el único que dice que algo salió mal.
##
## Las dos columnas usan intervalos con las MISMAS coordenadas: 7668420-7687490
## en los dos lados (el BED en 0-based, el GTF en 1-based sobre el mismo gen).
## Si las coordenadas fueran distintas, se podría pensar que por eso no cruzan.
## Son idénticas; lo único que cambia es el nombre del cromosoma.
## ---------------------------------------------------------------------------
##
## Esquema: no afirma ninguna cantidad. Sin título dentro del SVG.
##
## Regenerar:  Rscript figuras/sesion11/07_nomenclatura.R

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


# --- El contenido de los dos archivos ----------------------------------------
# Mismas coordenadas de TP53 en los dos lados. Lo único distinto es la primera
# columna. (El BED va en 0-based y el GTF en 1-based, que es lo correcto para
# cada formato: 7668420 y 7668421 son la MISMA base.)
bed <- c("chr17\t7668420\t7687490\tTP53\t0\t-",
         "chr17\t7676520\t7676594\texon\t0\t-")
gtf <- c("17\tHAVANA\tgene\t7668421\t7687490\t.\t-\t.\tTP53",
         "17\tHAVANA\texon\t7676521\t7676594\t.\t-\t.\texon")

# Se dibujan con tabuladores expandidos a columnas fijas: un "\t" real en un
# geom_text sale como un espacio y las columnas se desalinean.
expandir <- function(x, anchos) {
  vapply(strsplit(x, "\t", fixed = TRUE), function(p) {
    paste0(mapply(function(s, w) formatC(s, width = -w), p,
                  anchos[seq_along(p)]), collapse = "")
  }, character(1))
}
bed_txt <- expandir(bed, c(7, 9, 9, 6, 2, 2))
gtf_txt <- expandir(gtf, c(4, 8, 6, 9, 9, 2, 2, 2, 6))


# --- Geometría, en milímetros -----------------------------------------------
# guardar(w = 14, h = 9) con 2 mm de margen: panel de 136 x 86 mm.
ANCHO_PANEL <- 136
ALTO_PANEL  <- 86

TAM_MONO <- 2.0
CHAR <- TAM_MONO * AVANCE_MONO

COL_W <- 60
X_IZQ <- 3
X_DER <- ANCHO_PANEL - COL_W - 3

Y_TITULO  <- 82
Y_CAJA    <- c(60, 76)            # la caja de cada archivo
Y_LINEA   <- c(72, 68)            # las dos líneas de cada archivo

Y_FLECHA  <- 50
Y_RES     <- c(28, 42)            # la caja del resultado
Y_RES_TXT <- 24                   # el rótulo naranja
Y_SOL     <- 12                   # la solución
Y_SOL_TXT <- 17

SANS <- familia_base()
MONO <- familia_mono()

TAM_TITULO <- 2.5
TAM_SUB    <- 1.95
TAM_CMD    <- 2.1
TAM_RES    <- 2.5
TAM_SOL    <- 1.95

TXT_CMD <- "bedtools intersect -a archivo.bed -b anotacion.gtf"
TXT_RES <- "0 intersecciones, sin ningún mensaje de error"
TXT_SOL <- "awk 'BEGIN{OFS=\"\\t\"}{sub(/^chr/,\"\",$1); print}' archivo.bed"

caja_res <- caja_redonda(ANCHO_PANEL / 2 - 30, ANCHO_PANEL / 2 + 30,
                         Y_RES[1], Y_RES[2], r = 2)


construir <- function() {
  ggplot() +
    # ---------------- Los dos archivos --------------------------------------
    annotate("rect", xmin = X_IZQ, xmax = X_IZQ + COL_W,
             ymin = Y_CAJA[1], ymax = Y_CAJA[2],
             fill = alpha(AZUL_CLARO, 0.10), colour = alpha(GRIS, 0.5),
             linewidth = 0.3) +
    annotate("rect", xmin = X_DER, xmax = X_DER + COL_W,
             ymin = Y_CAJA[1], ymax = Y_CAJA[2],
             fill = alpha(VERDE, 0.07), colour = alpha(GRIS, 0.5),
             linewidth = 0.3) +

    annotate("text", x = X_IZQ, y = Y_TITULO, label = "estilo UCSC",
             family = SANS, size = TAM_TITULO, colour = AZUL,
             fontface = "bold", hjust = 0) +
    annotate("text", x = X_IZQ + 26, y = Y_TITULO, label = "archivo.bed",
             family = MONO, size = TAM_SUB, colour = GRIS, hjust = 0) +
    annotate("text", x = X_DER, y = Y_TITULO, label = "estilo Ensembl / GRC",
             family = SANS, size = TAM_TITULO, colour = VERDE,
             fontface = "bold", hjust = 0) +
    annotate("text", x = X_DER + 42, y = Y_TITULO, label = "anotacion.gtf",
             family = MONO, size = TAM_SUB, colour = GRIS, hjust = 0) +

    # Las líneas de cada archivo. El nombre del cromosoma va aparte y en
    # color, porque es lo único que difiere.
    annotate("text", x = X_IZQ + 2, y = Y_LINEA, label = bed_txt,
             family = MONO, size = TAM_MONO, colour = TEXTO, hjust = 0) +
    annotate("text", x = X_DER + 2, y = Y_LINEA, label = gtf_txt,
             family = MONO, size = TAM_MONO, colour = TEXTO, hjust = 0) +
    # resalte del nombre del cromosoma
    annotate("rect", xmin = X_IZQ + 1.4, xmax = X_IZQ + 1.4 + 5 * CHAR + 1,
             ymin = min(Y_LINEA) - 1.6, ymax = max(Y_LINEA) + 1.6,
             fill = alpha(AZUL, 0.16), colour = NA) +
    annotate("rect", xmin = X_DER + 1.4, xmax = X_DER + 1.4 + 2 * CHAR + 1,
             ymin = min(Y_LINEA) - 1.6, ymax = max(Y_LINEA) + 1.6,
             fill = alpha(VERDE, 0.16), colour = NA) +

    # ---------------- La operación ------------------------------------------
    annotate("segment", x = X_IZQ + COL_W / 2, xend = ANCHO_PANEL / 2,
             y = Y_CAJA[1] - 1.5, yend = Y_FLECHA + 3,
             colour = GRIS, linewidth = 0.4) +
    annotate("segment", x = X_DER + COL_W / 2, xend = ANCHO_PANEL / 2,
             y = Y_CAJA[1] - 1.5, yend = Y_FLECHA + 3,
             colour = GRIS, linewidth = 0.4) +
    annotate("text", x = ANCHO_PANEL / 2, y = Y_FLECHA, label = TXT_CMD,
             family = MONO, size = TAM_CMD, colour = TEXTO) +
    annotate("segment", x = ANCHO_PANEL / 2, xend = ANCHO_PANEL / 2,
             y = Y_FLECHA - 3, yend = Y_RES[2] + 1.5,
             colour = GRIS, linewidth = 0.4,
             arrow = arrow(length = unit(2.2, "mm"), type = "closed")) +

    # ---------------- El resultado: una caja VACÍA --------------------------
    geom_polygon(data = caja_res, aes(x = x, y = y),
                 fill = "transparent", colour = GRIS_BORDE, linewidth = 0.4,
                 linetype = "dashed") +
    annotate("text", x = ANCHO_PANEL / 2, y = mean(Y_RES), label = "",
             family = MONO, size = TAM_MONO) +
    annotate("text", x = ANCHO_PANEL / 2, y = Y_RES_TXT, label = TXT_RES,
             family = SANS, size = TAM_RES, colour = NARANJA,
             fontface = "bold") +

    # ---------------- La solución -------------------------------------------
    annotate("segment", x = 3, xend = ANCHO_PANEL - 3,
             y = Y_SOL_TXT + 2.5, yend = Y_SOL_TXT + 2.5,
             colour = alpha(GRIS, 0.4), linewidth = 0.3) +
    annotate("text", x = 3, y = Y_SOL_TXT, label = "normalizar antes de operar:",
             family = SANS, size = TAM_SOL, colour = GRIS, hjust = 0) +
    annotate("text", x = 3, y = Y_SOL, label = TXT_SOL,
             family = MONO, size = TAM_SOL, colour = VERDE, hjust = 0) +

    coord_cartesian(xlim = c(0, ANCHO_PANEL), ylim = c(0, ALTO_PANEL),
                    expand = FALSE, clip = "off") +
    tema_esquema()
}


if (!interactive()) {
  # Las coordenadas de los dos archivos tienen que describir el mismo gen: es
  # lo que prueba que el problema es el nombre del cromosoma y nada más.
  bed_ini <- as.integer(strsplit(bed[1], "\t")[[1]][2])
  bed_fin <- as.integer(strsplit(bed[1], "\t")[[1]][3])
  gtf_ini <- as.integer(strsplit(gtf[1], "\t")[[1]][4])
  gtf_fin <- as.integer(strsplit(gtf[1], "\t")[[1]][5])

  m_cmd <- media_ancho(TXT_CMD, TAM_CMD, AVANCE_MONO)
  m_res <- media_ancho(TXT_RES, TAM_RES)
  m_sol <- media_ancho(TXT_SOL, TAM_SOL, AVANCE_MONO)
  m_bed <- media_ancho(bed_txt, TAM_MONO, AVANCE_MONO)
  m_gtf <- media_ancho(gtf_txt, TAM_MONO, AVANCE_MONO)

  stopifnot(
    # --- Los dos archivos describen el MISMO intervalo ---
    # BED es 0-based semiabierto, GTF es 1-based cerrado: mismo gen.
    gtf_ini == bed_ini + 1L,
    gtf_fin == bed_fin,
    # ...y son las coordenadas reales de TP53 en hg38
    bed_ini == 7668420L, gtf_fin == 7687490L,

    # --- Lo único que difiere es el nombre del cromosoma ---
    startsWith(bed[1], "chr17\t"),
    startsWith(gtf[1], "17\t"),
    sub("^chr", "", strsplit(bed[1], "\t")[[1]][1]) ==
      strsplit(gtf[1], "\t")[[1]][1],

    # --- La solución de awk sí quita el prefijo ---
    grepl("sub\\(/\\^chr/", TXT_SOL),

    # --- Nada se sale del panel ---
    X_DER + COL_W <= ANCHO_PANEL,
    X_IZQ + COL_W < X_DER,                    # las dos columnas no se tocan
    all(X_IZQ + 2 + 2 * m_bed <= X_IZQ + COL_W + 1),
    all(X_DER + 2 + 2 * m_gtf <= X_DER + COL_W + 1),
    ANCHO_PANEL / 2 - m_cmd >= 0,
    ANCHO_PANEL / 2 - m_res >= 0,
    3 + 2 * m_sol <= ANCHO_PANEL,
    Y_TITULO <= ALTO_PANEL,
    Y_RES[1] > Y_RES_TXT + TAM_RES,
    Y_RES_TXT - TAM_RES > Y_SOL_TXT + TAM_SOL
  )

  message("  el mismo intervalo de TP53 (hg38) en los dos estilos:")
  message(sprintf("    BED  0-based  chr17 %s %s", bed_ini, bed_fin))
  message(sprintf("    GTF  1-based  17    %s %s", gtf_ini, gtf_fin))
  message("    -> misma base de inicio; lo único distinto es 'chr'")
  message(sprintf("  resultado dibujado: caja vacía + '%s'", TXT_RES))

  guardar(construir(), "nomenclatura", 14, 9)
}
