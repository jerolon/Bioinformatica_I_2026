## Fig. @fig-tres-ensamblados (Sesión 11, § El mismo gen, tres direcciones)
## TP53 en GRCh37, GRCh38 y T2T-CHM13v2.0, sobre la MISMA ventana del
## cromosoma 17 y a la MISMA escala.
##
## ---------------------------------------------------------------------------
## POR QUÉ LAS TRES BARRAS SON LA MISMA VENTANA
##
## Es lo único que hace que la figura signifique algo. Si cada barra fuera su
## propio ensamblado reescalado, TP53 saldría en el mismo sitio en las tres y
## la figura diría "es el mismo gen", que ya se sabe. Compartiendo ventana y
## escala, el gen sale DESPLAZADO, y el desplazamiento es el tema del capítulo.
##
## Las líneas punteadas que unen los tres intervalos salen inclinadas por esa
## misma razón. Si salieran verticales, algo estaría mal.
##
## ---------------------------------------------------------------------------
## COORDENADAS VERIFICADAS EL 2026-08-07
##
##   GRCh38 y T2T   NCBI Datasets, gene 7157:
##       https://api.ncbi.nlm.nih.gov/datasets/v2alpha/gene/id/7157
##       GRCh38.p14      7,668,421-7,687,490   (minus)
##       T2T-CHM13v2.0   7,572,544-7,591,594   (minus)
##
##   GRCh37         API de UCSC, track ncbiRefSeqCurated sobre hg19, tomando
##       el mínimo txStart y el máximo txEnd de los 26 transcritos de TP53:
##       BED 0-based 7571738-7590808  ->  1-based 7,571,739-7,590,808
##
## Las tres coinciden con lo que dice la tabla de `ensamblados.qmd`. Ojo: son
## coordenadas del modelo de genes de RefSeq/NCBI, NO de Ensembl. Ensembl da
## un tramo más largo (GRCh38 17:7,661,779-7,687,546) porque su modelo incluye
## transcritos que RefSeq no. Esa discrepancia es un tema del capítulo de
## Ensembl, no un error de acá.
## ---------------------------------------------------------------------------
##
## Sin título dentro del SVG: el caption vive en el .qmd.
##
## Regenerar:  Rscript figuras/sesion11/06_tres_ensamblados.R

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


# --- Los datos ---------------------------------------------------------------
VERIFICADO <- "2026-08-07"

ens <- data.frame(
  ensamblado = c("GRCh37 / hg19", "GRCh38 / hg38", "T2T-CHM13v2.0"),
  cromosoma  = c("NC_000017.10", "NC_000017.11", "NC_060941.1"),
  inicio     = c(7571739L, 7668421L, 7572544L),
  fin        = c(7590808L, 7687490L, 7591594L),
  stringsAsFactors = FALSE
)
ens$largo <- ens$fin - ens$inicio + 1L

# La ventana: la misma para las tres, con margen a los lados. Se calcula de los
# datos para que no haya un número tecleado que se desincronice.
MARGEN <- 26000
VENTANA <- c(min(ens$inicio) - MARGEN, max(ens$fin) + MARGEN)


# --- Geometría, en milímetros -----------------------------------------------
# guardar(w = 16, h = 8) con 2 mm de margen: panel de 156 x 76 mm.
ANCHO_PANEL <- 156
ALTO_PANEL  <- 76

X_ETIQ <- 2                       # rótulo del ensamblado
X_BAR  <- 34                      # borde izquierdo de la barra
W_BAR  <- 84                      # ancho de la barra
X_NOTA <- X_BAR + W_BAR + 4       # la nota del margen derecho

ALTO_BAR <- 7
Y_BAR <- c(56, 36, 16)            # centro de cada barra
ens$y <- Y_BAR

Y_ESCALA <- 5                     # la barra de escala, abajo

SANS <- familia_base()
MONO <- familia_mono()

TAM_ETIQ  <- 2.35
TAM_CROM  <- 1.95
TAM_COORD <- 2.0
TAM_NOTA  <- 2.2
TAM_ESC   <- 1.9

# Posición en mm de una coordenada genómica dentro de la barra.
en_mm <- function(pos) X_BAR + W_BAR * (pos - VENTANA[1]) / diff(VENTANA)

ens$x0 <- en_mm(ens$inicio)
ens$x1 <- en_mm(ens$fin)
ens$xm <- (ens$x0 + ens$x1) / 2

ens$coord <- sprintf("%s - %s",
                     format(ens$inicio, big.mark = ","),
                     format(ens$fin, big.mark = ","))

# --- Las conexiones entre barras --------------------------------------------
# Unen el mismo gen de una barra a la siguiente. Salen inclinadas: ése es el
# punto. Se dibujan los dos bordes del intervalo, no el centro, para que se
# vea que el bloque entero se corre.
conex <- do.call(rbind, lapply(1:2, function(k) {
  rbind(
    data.frame(x = ens$x0[k], y = ens$y[k] - ALTO_BAR / 2,
               xend = ens$x0[k + 1], yend = ens$y[k + 1] + ALTO_BAR / 2,
               id = paste0(k, "a")),
    data.frame(x = ens$x1[k], y = ens$y[k] - ALTO_BAR / 2,
               xend = ens$x1[k + 1], yend = ens$y[k + 1] + ALTO_BAR / 2,
               id = paste0(k, "b"))
  )
}))

# --- La barra de escala ------------------------------------------------------
# Va pegada al extremo DERECHO de las barras, no al izquierdo. Arrancándola en
# X_BAR se montaba encima del rótulo "misma ventana en las tres: ... kb", que
# ocupa toda la mitad izquierda de esa línea. (Se vio en el PNG; el stopifnot
# medía que la escala no se saliera de la barra, no que no pisara el texto.
## Ahora hay una comprobación de eso.)
ESCALA_KB <- 20
esc_ancho <- W_BAR * (ESCALA_KB * 1000) / diff(VENTANA)
esc_x1 <- X_BAR + W_BAR
esc_x0 <- esc_x1 - esc_ancho

TXT_VENTANA <- sprintf("misma ventana en las tres: %s kb del cromosoma 17",
                       format(round(diff(VENTANA) / 1000), big.mark = ","))

# Va partida a mano en líneas cortas: el margen derecho son ~30 mm y con
# líneas más largas el rótulo se salía del panel (lo atrapó el stopifnot).
TXT_NOTA <- paste0("el mismo gen,\n",
                   "tres direcciones,\n",
                   "ninguna convertible\n",
                   "a las otras sin un\n",
                   "archivo de cadenas")


construir <- function() {
  ggplot() +
    # --- Las barras: la ventana del cromosoma ---
    geom_rect(data = ens,
              aes(xmin = X_BAR, xmax = X_BAR + W_BAR,
                  ymin = y - ALTO_BAR / 2, ymax = y + ALTO_BAR / 2),
              fill = alpha(GRIS_CAJA, 0.75), colour = GRIS_BORDE,
              linewidth = 0.35) +

    # --- Las conexiones, inclinadas ---
    geom_segment(data = conex,
                 aes(x = x, y = y, xend = xend, yend = yend),
                 colour = alpha(NARANJA, 0.55), linewidth = 0.3,
                 linetype = "dotted") +

    # --- TP53, en naranja ---
    geom_rect(data = ens,
              aes(xmin = x0, xmax = x1,
                  ymin = y - ALTO_BAR / 2, ymax = y + ALTO_BAR / 2),
              fill = NARANJA, colour = NA) +

    # --- Rótulos del ensamblado y del cromosoma ---
    geom_text(data = ens, aes(x = X_ETIQ, y = y + 1.4, label = ensamblado),
              family = SANS, size = TAM_ETIQ, colour = TEXTO,
              fontface = "bold", hjust = 0) +
    geom_text(data = ens, aes(x = X_ETIQ, y = y - 2.4, label = cromosoma),
              family = MONO, size = TAM_CROM, colour = GRIS, hjust = 0) +

    # --- Las coordenadas, encima de cada intervalo ---
    geom_text(data = ens, aes(x = xm, y = y + ALTO_BAR / 2 + 2.6, label = coord),
              family = MONO, size = TAM_COORD, colour = NARANJA,
              fontface = "bold") +

    # --- La nota del margen derecho ---
    annotate("text", x = X_NOTA, y = mean(Y_BAR), label = TXT_NOTA,
             family = SANS, size = TAM_NOTA, colour = NARANJA,
             hjust = 0, lineheight = 1.15, fontface = "bold") +

    # --- Barra de escala ---
    annotate("segment", x = esc_x0, xend = esc_x1, y = Y_ESCALA, yend = Y_ESCALA,
             colour = GRIS, linewidth = 0.4) +
    annotate("segment", x = esc_x0, xend = esc_x0, y = Y_ESCALA - 1,
             yend = Y_ESCALA + 1, colour = GRIS, linewidth = 0.4) +
    annotate("segment", x = esc_x1, xend = esc_x1, y = Y_ESCALA - 1,
             yend = Y_ESCALA + 1, colour = GRIS, linewidth = 0.4) +
    annotate("text", x = esc_x1 + 2, y = Y_ESCALA,
             label = sprintf("%d kb", ESCALA_KB), family = SANS,
             size = TAM_ESC, colour = GRIS, hjust = 0) +
    annotate("text", x = X_ETIQ, y = Y_ESCALA, label = TXT_VENTANA,
             family = SANS, size = TAM_ESC, colour = GRIS, hjust = 0) +

    coord_cartesian(xlim = c(0, ANCHO_PANEL), ylim = c(0, ALTO_PANEL),
                    expand = FALSE, clip = "off") +
    labs(caption = sprintf(paste("Coordenadas del modelo de genes de",
                                 "RefSeq/NCBI, verificadas el %s contra NCBI",
                                 "Datasets (GRCh38, T2T) y la API de UCSC\n(hg19).",
                                 "Ensembl da un tramo distinto para el mismo gen:",
                                 "son dos modelos sobre el mismo genoma."),
                           VERIFICADO)) +
    tema_esquema()
}


if (!interactive()) {
  m_nota <- media_ancho(TXT_NOTA, TAM_NOTA)
  m_coord <- media_ancho(ens$coord, TAM_COORD, AVANCE_MONO)

  stopifnot(
    # --- Los datos ---
    nrow(ens) == 3L,
    all(ens$fin > ens$inicio),
    !anyDuplicated(ens$inicio),
    # el gen mide ~19 kb en los tres; si alguno se sale de rango, alguien
    # tecleó mal una coordenada
    all(ens$largo > 19000L), all(ens$largo < 19100L),
    # hg19 y T2T caen cerca; hg38 está ~97 kb más adelante. Es el hecho que
    # la figura viene a contar.
    ens$inicio[2] - ens$inicio[1] > 90000L,
    abs(ens$inicio[3] - ens$inicio[1]) < 2000L,

    # --- La ventana los contiene a los tres, con margen ---
    VENTANA[1] < min(ens$inicio), VENTANA[2] > max(ens$fin),
    all(ens$x0 > X_BAR), all(ens$x1 < X_BAR + W_BAR),

    # --- Las conexiones salen inclinadas. Si alguna saliera vertical, las
    #     coordenadas de dos ensamblados serían iguales y la figura no
    #     tendría nada que decir. ---
    all(abs(conex$x - conex$xend) > 0.5),

    # --- Nada se sale del panel ni se encima ---
    X_NOTA + 2 * m_nota <= ANCHO_PANEL,
    max(ens$y) + ALTO_BAR / 2 + 2.6 + TAM_COORD <= ALTO_PANEL,
    min(ens$y) - ALTO_BAR / 2 > Y_ESCALA + 1.5,
    all(ens$xm - m_coord > X_ETIQ),      # la coordenada no pisa el rótulo

    # --- La línea de la escala: el rótulo de la ventana, la barra y el "20 kb"
    #     comparten renglón y no se pisan. Esto es lo que faltaba comprobar. ---
    esc_x0 >= X_BAR, esc_x1 <= X_BAR + W_BAR,
    X_ETIQ + 2 * media_ancho(TXT_VENTANA, TAM_ESC) < esc_x0,
    esc_x1 + 2 + 2 * media_ancho(sprintf("%d kb", ESCALA_KB), TAM_ESC)
      <= ANCHO_PANEL
  )

  message(sprintf("  TP53 en tres ensamblados (verificado %s):", VERIFICADO))
  for (k in seq_len(nrow(ens))) {
    message(sprintf("    %-16s %-14s %s   (%s bp)", ens$ensamblado[k],
                    ens$cromosoma[k], ens$coord[k],
                    format(ens$largo[k], big.mark = ",")))
  }
  message(sprintf("  desplazamiento hg19 -> hg38: %s bp",
                  format(ens$inicio[2] - ens$inicio[1], big.mark = ",")))
  message(sprintf("  hg19 vs T2T: %s bp de diferencia",
                  format(ens$inicio[3] - ens$inicio[1], big.mark = ",")))
  message(sprintf("  ventana común: %s - %s (%s kb)",
                  format(VENTANA[1], big.mark = ","),
                  format(VENTANA[2], big.mark = ","),
                  format(round(diff(VENTANA) / 1000))))

  escribir_tsv(ens[, c("ensamblado", "cromosoma", "inicio", "fin", "largo")],
               "tp53-tres-ensamblados")
  guardar(construir(), "tp53-tres-ensamblados", 16, 8)
}
