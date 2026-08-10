## Fig. @fig-composicion (Sesión 2-3, § Elementos repetitivos)
## Composición del genoma humano por clase de secuencia, en una barra apilada.
##
## ---------------------------------------------------------------------------
## DE DÓNDE SALE CADA NÚMERO (y qué tan firme es)
##
## Las cinco fracciones de secuencia repetitiva vienen de IHGSC 2001
## (Nature 409:860), tabla 11 del artículo, redondeadas: LINE 20.4 -> 21,
## SINE 13.1 -> 13, LTR 8.3 -> 8, transposones de DNA 2.8 -> 3. La quinta,
## satélites y demás repeticiones en tándem, se pone en 3.
##
## Exones codificantes (1.5), intrones (26) y resto intergénico (24.5) son las
## cifras convencionales del mismo artículo; el intergénico se ajusta para que
## el total dé 100 exacto (es la categoría residual, la de definición más
## blanda, así que es donde debe caer el ajuste).
##
## VERIFICADO contra el resumen de RepeatMasker para hg38
## (https://www.repeatmasker.org/species/hg.html, Dfam 3.x):
##     repeticiones intercaladas  48.49 %      acá: 45 (LINE+SINE+LTR+DNA)
##     total enmascarado          52.58 %      acá: 48 (con satélites)
## O sea que estas fracciones subestiman ~3.5 puntos, casi todos en el bloque
## de satélites y repeticiones simples, que acá vale 3 y en RepeatMasker vale
## ~4.1. No se corrigen porque el cuerpo del capítulo cita los mismos valores de
## IHGSC (LINE ~21 %, Alu ~10 %, LTR ~8 %, DNA ~3 %) y figura y texto tienen que
## decir lo mismo. Si algún día se actualiza el texto a las cifras de
## RepeatMasker o de T2T-CHM13, hay que actualizar las dos cosas a la vez.
##
## La barra dice ~48 % de secuencia repetitiva; el caption avisa que la
## estimación de de Koning et al. 2011 llega a dos tercios.
## ---------------------------------------------------------------------------
##
## Se dibuja en milímetros con theme_void y no con un geom_col sobre un eje,
## porque en 16 x 6 cm hay que meter barra, llave, leyenda y una guía al
## segmento de 1.5 % (que mide 2 mm) sin que nada se encime. Con la geometría
## explícita eso se puede comprobar; con las escalas de ggplot, no.
##
## Sin título dentro del SVG: el caption vive en el .qmd.
##
## Regenerar:  Rscript figuras/sesion02/03_composicion_genoma.R

.ubicar <- function() {
  for (i in rev(seq_len(sys.nframe()))) {   # de adentro hacia afuera
    o <- sys.frame(i)$ofile
    if (!is.null(o)) return(normalizePath(o, winslash = "/"))
  }
  a <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1]), winslash = "/"))
  stop("no se pudo ubicar el script: correr con Rscript o con source()")
}
source(file.path(dirname(.ubicar()), "_tema.R"))


# --- Los datos --------------------------------------------------------------
# Fracciones aproximadas del genoma humano. Fuente: IHGSC 2001 (Nature 409:860)
# para los elementos repetitivos. Ver la nota larga de arriba sobre la
# comparación con RepeatMasker para hg38.
composicion <- data.frame(
  clase = c("LINE", "SINE (Alu y otros)", "LTR / retrovirus endógenos",
            "Transposones de DNA", "Satélites y otras repeticiones",
            "Exones codificantes", "Intrones", "Resto intergénico"),
  pct   = c(21, 13, 8, 3, 3, 1.5, 26, 24.5),
  stringsAsFactors = FALSE
)

# Qué cuenta como repetitivo. De acá sale el total de la llave, que NO está
# tecleado.
REPETITIVAS <- composicion$clase[1:5]
composicion$repetitiva <- composicion$clase %in% REPETITIVAS
PCT_REPETITIVO <- sum(composicion$pct[composicion$repetitiva])

DESTACADA <- "Exones codificantes"   # la que lleva guía propia

# Referencias de verificación, para el mensaje del final y para el .tsv.
RM_INTERCALADAS <- 48.49   # RepeatMasker hg38: repeticiones intercaladas
RM_TOTAL        <- 52.58   # RepeatMasker hg38: total enmascarado


# --- Geometría, en milímetros -----------------------------------------------
# guardar(w = 16, h = 6) con 2 mm de margen a los lados: panel de 156 x 52 mm.
ANCHO_PANEL <- 156
ALTO_PANEL  <- 52

X_BARRA <- 8
W_BARRA <- 140                 # 140 mm = 100 %
MM_POR_PCT <- W_BARRA / 100

Y_BARRA_MIN <- 32
Y_BARRA_MAX <- 41

Y_LLAVE     <- Y_BARRA_MAX + 2   # base de la llave de repetitivas
PROF_LLAVE  <- 3
Y_ETIQ_REP  <- 49.5

Y_EXTREMOS  <- 28.5              # "0 %" y "100 %", bajo la barra
Y_GUIA      <- 25                # donde aterriza la guía del segmento chico
X_GUIA_LAB  <- 84

Y_LEYENDA   <- c(20, 15.5, 11, 6.5)
X_LEYENDA   <- c(8, 84)
W_SWATCH    <- 4
H_SWATCH    <- 2.6
SEP_SWATCH  <- 1.8               # del swatch a su texto

TAM_PCT   <- 2.1                 # el % dentro de la barra
TAM_ETIQ  <- 2.3
TAM_LEY   <- 2.0
TAM_MIN   <- 1.9

# Sólo se rotula dentro de la barra el segmento que tenga sitio de sobra.
PCT_MIN_ROTULO <- 8

SANS <- familia_base()

# --- Colores ----------------------------------------------------------------
# El bloque repetitivo en naranja y grises, para que se lea como UN bloque; lo
# codificante en verde; intrones e intergénico en azul claro. Ningún hex suelto:
# todo sale de la paleta de estilo.R, variando la opacidad.
COLOR <- c(
  "LINE"                           = NARANJA,
  "SINE (Alu y otros)"             = alpha(NARANJA, 0.70),
  "LTR / retrovirus endógenos"     = GRIS,
  "Transposones de DNA"            = alpha(GRIS, 0.68),
  "Satélites y otras repeticiones" = alpha(GRIS, 0.42),
  "Exones codificantes"            = VERDE,
  "Intrones"                       = alpha(AZUL_CLARO, 0.75),
  "Resto intergénico"              = alpha(AZUL_CLARO, 0.35)
)

# --- Segmentos de la barra --------------------------------------------------
fin <- cumsum(composicion$pct)
segmentos <- transform(
  composicion,
  pct_ini = fin - composicion$pct,
  pct_fin = fin
)
segmentos$xmin <- X_BARRA + segmentos$pct_ini * MM_POR_PCT
segmentos$xmax <- X_BARRA + segmentos$pct_fin * MM_POR_PCT
segmentos$x    <- (segmentos$xmin + segmentos$xmax) / 2
segmentos$clase <- factor(segmentos$clase, levels = composicion$clase)

# El texto de cada clase lleva su porcentaje: los segmentos angostos no caben
# rotulados por dentro y así no se quedan sin cifra.
fmt_pct <- function(p) sub(".", ",", sprintf("%g %%", p), fixed = TRUE)
segmentos$etiqueta_leyenda <- paste0(segmentos$clase, " — ", fmt_pct(segmentos$pct))

rotulos <- subset(segmentos, pct >= PCT_MIN_ROTULO)

# --- Llave de las repetitivas -----------------------------------------------
X_REP_FIN <- X_BARRA + PCT_REPETITIVO * MM_POR_PCT
llave_rep <- llave(X_BARRA, X_REP_FIN, Y_LLAVE, PROF_LLAVE, arriba = TRUE)
ETIQ_REP  <- sprintf("secuencia repetitiva detectable  %s", fmt_pct(PCT_REPETITIVO))

# --- Guía al segmento chico -------------------------------------------------
# El de exones codificantes mide 2.1 mm: no cabe rotulado por dentro, y es
# justamente el que el capítulo quiere que se vea de lo chico que es.
destacada <- subset(segmentos, clase == DESTACADA)
guia <- data.frame(
  x    = c(destacada$x, destacada$x, X_GUIA_LAB - 1),
  y    = c(Y_BARRA_MIN - 0.5, Y_GUIA, Y_GUIA)
)
ETIQ_DESTACADA <- sprintf("%s: %s del genoma",
                          destacada$clase, fmt_pct(destacada$pct))

# --- Leyenda ----------------------------------------------------------------
# Dos columnas de cuatro. La primera queda con los cuatro tipos de elemento
# transponible y la segunda arranca con los satélites: sale así de la propia
# ordenación de los datos, no hay que reacomodar nada.
leyenda <- transform(
  segmentos,
  col  = rep(seq_along(X_LEYENDA), each = length(Y_LEYENDA))[seq_len(nrow(segmentos))],
  fila = rep(seq_along(Y_LEYENDA), times = length(X_LEYENDA))[seq_len(nrow(segmentos))]
)
leyenda$sx   <- X_LEYENDA[leyenda$col]
leyenda$sy   <- Y_LEYENDA[leyenda$fila]
leyenda$tx   <- leyenda$sx + W_SWATCH + SEP_SWATCH


construir <- function() {
  ggplot() +
    # --- La barra ---
    geom_rect(data = segmentos,
              aes(xmin = xmin, xmax = xmax, ymin = Y_BARRA_MIN, ymax = Y_BARRA_MAX,
                  fill = clase),
              colour = "white", linewidth = 0.25) +
    geom_text(data = rotulos, aes(x = x, y = (Y_BARRA_MIN + Y_BARRA_MAX) / 2,
                                  label = fmt_pct(pct)),
              family = SANS, size = TAM_PCT, colour = "white") +

    # --- Llave de la fracción repetitiva ---
    geom_path(data = llave_rep, aes(x = x, y = y),
              colour = GRIS, linewidth = 0.45, lineend = "round") +
    geom_text(data = data.frame(1), aes(x = (X_BARRA + X_REP_FIN) / 2, y = Y_ETIQ_REP),
              label = ETIQ_REP, family = SANS, size = TAM_ETIQ, colour = GRIS) +

    # --- Extremos de la escala ---
    geom_text(data = data.frame(x = c(X_BARRA, X_BARRA + W_BARRA),
                                txt = c("0 %", "100 %"), h = c(0, 1)),
              aes(x = x, y = Y_EXTREMOS, label = txt, hjust = h),
              family = SANS, size = TAM_MIN, colour = GRIS) +

    # --- Guía al segmento de exones codificantes ---
    geom_path(data = guia, aes(x = x, y = y),
              colour = VERDE, linewidth = 0.35) +
    geom_text(data = data.frame(1), aes(x = X_GUIA_LAB, y = Y_GUIA),
              label = ETIQ_DESTACADA, family = SANS, size = TAM_ETIQ,
              colour = VERDE, hjust = 0) +

    # --- Leyenda dibujada a mano (dos columnas de cuatro) ---
    geom_rect(data = leyenda,
              aes(xmin = sx, xmax = sx + W_SWATCH,
                  ymin = sy - H_SWATCH / 2, ymax = sy + H_SWATCH / 2,
                  fill = clase),
              colour = NA) +
    geom_text(data = leyenda, aes(x = tx, y = sy, label = etiqueta_leyenda),
              family = SANS, size = TAM_LEY, colour = TEXTO, hjust = 0) +

    scale_fill_manual(values = COLOR, guide = "none") +
    coord_cartesian(xlim = c(0, ANCHO_PANEL), ylim = c(0, ALTO_PANEL),
                    expand = FALSE, clip = "off") +
    labs(caption = paste(
      "Fracciones aproximadas. La detección por homología estima ~50 % de secuencia repetitiva;",
      "estimaciones que incluyen\nelementos muy divergentes llegan a dos tercios",
      "(de Koning et al. 2011).")) +
    tema_esquema()
}


if (!interactive()) {
  m_ley  <- media_ancho(leyenda$etiqueta_leyenda, TAM_LEY)
  m_rep  <- media_ancho(ETIQ_REP,       TAM_ETIQ)
  m_dest <- media_ancho(ETIQ_DESTACADA, TAM_ETIQ)
  m_pct  <- media_ancho(fmt_pct(rotulos$pct), TAM_PCT)

  # Ancho del texto de cada columna de la leyenda, para ver que no se pisen.
  fin_col <- tapply(leyenda$tx + 2 * m_ley, leyenda$col, max)

  stopifnot(
    # --- Los datos ---
    nrow(composicion) == 8L,
    isTRUE(all.equal(sum(composicion$pct), 100)),   # suman 100 exacto
    all(composicion$pct > 0),
    sum(composicion$repetitiva) == 5L,
    isTRUE(all.equal(PCT_REPETITIVO, 48)),
    nrow(destacada) == 1L,
    destacada$pct == 1.5,
    # el bloque repetitivo va primero y sin interrupciones: la llave es un tramo
    identical(which(composicion$repetitiva), seq_len(5)),

    # --- La barra ---
    isTRUE(all.equal(min(segmentos$xmin), X_BARRA)),
    isTRUE(all.equal(max(segmentos$xmax), X_BARRA + W_BARRA)),
    all(segmentos$xmax > segmentos$xmin),
    # ningún rótulo interno se sale de su propio segmento
    all(rotulos$x - m_pct > rotulos$xmin + 0.5),
    all(rotulos$x + m_pct < rotulos$xmax - 0.5),
    # y los que no llevan rótulo es porque de verdad no cabía
    all(subset(segmentos, pct < PCT_MIN_ROTULO)$pct * MM_POR_PCT < 12),

    # --- Nada se sale del panel, nada se encima ---
    X_BARRA + W_BARRA <= ANCHO_PANEL,
    Y_ETIQ_REP + TAM_ETIQ <= ALTO_PANEL,
    max(llave_rep$y) < Y_ETIQ_REP - TAM_ETIQ,
    (X_BARRA + X_REP_FIN) / 2 - m_rep >= 0,
    (X_BARRA + X_REP_FIN) / 2 + m_rep <= ANCHO_PANEL,
    X_GUIA_LAB + 2 * m_dest <= ANCHO_PANEL,
    X_GUIA_LAB > destacada$xmax + 2,          # la etiqueta no tapa su segmento
    Y_GUIA < Y_EXTREMOS - TAM_MIN,
    max(Y_LEYENDA) + H_SWATCH < Y_GUIA - TAM_ETIQ,
    min(Y_LEYENDA) - H_SWATCH / 2 >= 0,
    fin_col[["1"]] < X_LEYENDA[2] - 1,        # la columna 1 no invade la 2
    fin_col[["2"]] <= ANCHO_PANEL,
    nrow(leyenda) == nrow(composicion)        # ninguna clase se queda fuera
  )

  message(sprintf("  %d clases; los porcentajes suman %g", nrow(composicion),
                  sum(composicion$pct)))
  for (i in seq_len(nrow(composicion))) {
    message(sprintf("    %-32s %5.1f %%%s", composicion$clase[i],
                    composicion$pct[i],
                    if (composicion$repetitiva[i]) "   (repetitiva)" else ""))
  }
  message(sprintf("  repetitivo en la figura: %g %%", PCT_REPETITIVO))
  message(sprintf("  RepeatMasker hg38: intercaladas %.2f %%, total enmascarado %.2f %%",
                  RM_INTERCALADAS, RM_TOTAL))
  message(sprintf("  -> la figura subestima %.2f puntos contra el total enmascarado",
                  RM_TOTAL - PCT_REPETITIVO))

  escribir_tsv(
    data.frame(clase       = composicion$clase,
               pct         = composicion$pct,
               repetitiva  = composicion$repetitiva,
               fuente      = "IHGSC 2001 (Nature 409:860), redondeado",
               rm_hg38_intercaladas_pct = RM_INTERCALADAS,
               rm_hg38_total_pct        = RM_TOTAL,
               stringsAsFactors = FALSE),
    "composicion-genoma")
  guardar(construir(), "composicion-genoma", 16, 6)
}
