## Fig. @fig-decodificador (Sesión 11, § El decodificador)
## Un identificador real de cada recurso, despiezado por color: prefijo AZUL,
## cuerpo gris, versión NARANJA. Es la figura que se llevan a la libreta.
##
## ---------------------------------------------------------------------------
## EL DESPIECE SE CALCULA, NO SE TECLEA
##
## Cada accession se parte con una expresión regular por familia, y los
## stopifnot comprueban que las tres piezas vuelvan a formar el original. Si
## alguien agrega una fila con un prefijo que la regla no contempla, la figura
## truena en vez de dibujar un despiece equivocado — que sería peor que no
## tener figura, porque enseñaría a leer mal.
##
## DOS FILAS VAN SIN VERSIÓN A PROPÓSITO (X02469 y P04637), tal como las lista
## la especificación. No es un olvido: es el contraste que hace visible el
## naranja de las otras. Un accession de INSDC sí tiene versión (X02469.1); acá
## se muestra la forma corta que es la que van a encontrar citada, y el
## capítulo se encarga de decir que citarla así es insuficiente.
##
## OJO CON EL EJEMPLO DE INSDC. La especificación pedía `X03495`, pero ese
## accession es mRNA de glutamina sintetasa de hámster chino, no de p53 humano
## (verificado contra el NCBI el 2026-08-07). En una tabla donde TODO lo demás
## es TP53, eso es una trampa: se lee como "el accession de INSDC de TP53".
## Se cambió por `X02469`, "Human mRNA for p53 cellular tumor antigen", que
## además es la PRIMERA referencia cruzada `DR EMBL` del registro P04637 de
## UniProt, así que la fila encaja con el resto del hilo del capítulo.
## ---------------------------------------------------------------------------
##
## Esquema: no afirma ninguna cantidad. Sin título dentro del SVG.
##
## Regenerar:  Rscript figuras/sesion11/05_decodificador.R

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


# --- Las filas ---------------------------------------------------------------
filas <- data.frame(
  acc = c("NM_000546.6", "X02469", "NC_000017.11", "P04637",
          "ENSG00000141510", "SRR1234567", "ERR1234567", "PRJNA12345"),
  que = c("RefSeq · mRNA curado",
          "INSDC · envío original",
          "RefSeq · cromosoma",
          "UniProt · proteína",
          "Ensembl · gen",
          "SRA · corrida (NCBI)",
          "SRA · corrida (ENA)",
          "BioProject (NCBI)"),
  pista = c("el guión bajo delata RefSeq",
            "nunca lleva guión bajo",
            "la 2ª letra es la molécula: C = cromosoma",
            "seis o diez alfanuméricos, sin puntos",
            "el prefijo ENS",
            "la 1ª letra dice el socio: S = NCBI",
            "E de EMBL-EBI; D sería DDBJ",
            "PRJ + NA / EB / DB"),
  stringsAsFactors = FALSE
)

# --- El despiece -------------------------------------------------------------
# Prefijo = las letras iniciales (con su guión bajo si lo lleva).
# Versión  = el ".n" final, si lo hay.  Cuerpo = lo de en medio.
despiezar <- function(acc) {
  m <- regmatches(acc, regexec("^([A-Z]+_?)([0-9]+)(\\.[0-9]+)?$", acc))[[1]]
  if (!length(m)) stop("no se pudo despiezar: ", acc, call. = FALSE)
  c(prefijo = m[2], cuerpo = m[3], version = if (is.na(m[4])) "" else m[4])
}

piezas <- as.data.frame(do.call(rbind, lapply(filas$acc, despiezar)),
                        stringsAsFactors = FALSE)
filas <- cbind(filas, piezas)


# --- Geometría, en milímetros -----------------------------------------------
# guardar(w = 16, h = 10) con 2 mm de margen: panel de 156 x 96 mm.
ANCHO_PANEL <- 156
ALTO_PANEL  <- 96

TAM_MONO <- 2.8
CHAR <- TAM_MONO * AVANCE_MONO

X_ACC   <- 6
X_QUE   <- 42
X_PISTA <- 88

Y_CABEZA <- 88
Y_TOPE   <- 78
PASO     <- 8.2
filas$y  <- Y_TOPE - (seq_len(nrow(filas)) - 1) * PASO

Y_LEYENDA <- 8

TAM_QUE   <- 2.3
TAM_PISTA <- 2.15
TAM_CAB   <- 2.35

SANS <- familia_base()
MONO <- familia_mono()

# Posición de cada pieza dentro de la línea monoespaciada.
filas$x_pre <- X_ACC
filas$x_cue <- X_ACC + nchar(filas$prefijo) * CHAR
filas$x_ver <- X_ACC + (nchar(filas$prefijo) + nchar(filas$cuerpo)) * CHAR

# Bandas alternas, para que el ojo no salte de renglón.
bandas <- filas[seq(1, nrow(filas), by = 2), ]

# La leyenda del código de color.
leyenda <- data.frame(
  x = c(X_ACC, X_ACC + 34, X_ACC + 68),
  txt = c("prefijo", "cuerpo", "versión"),
  col = c(AZUL, GRIS, NARANJA),
  stringsAsFactors = FALSE
)


construir <- function() {
  ggplot() +
    # --- Bandas alternas ---
    geom_rect(data = bandas,
              aes(xmin = 3, xmax = ANCHO_PANEL - 3,
                  ymin = y - PASO / 2 + 0.4, ymax = y + PASO / 2 - 0.4),
              fill = alpha(AZUL_CLARO, 0.07), colour = NA) +

    # --- Encabezados ---
    annotate("text", x = X_ACC, y = Y_CABEZA, label = "identificador",
             family = SANS, size = TAM_CAB, colour = GRIS, fontface = "bold",
             hjust = 0) +
    annotate("text", x = X_QUE, y = Y_CABEZA, label = "qué es",
             family = SANS, size = TAM_CAB, colour = GRIS, fontface = "bold",
             hjust = 0) +
    annotate("text", x = X_PISTA, y = Y_CABEZA, label = "la pista",
             family = SANS, size = TAM_CAB, colour = GRIS, fontface = "bold",
             hjust = 0) +
    annotate("segment", x = 3, xend = ANCHO_PANEL - 3,
             y = Y_CABEZA - 3.6, yend = Y_CABEZA - 3.6,
             colour = alpha(GRIS, 0.45), linewidth = 0.35) +

    # --- El despiece de cada accession ---
    geom_text(data = filas, aes(x = x_pre, y = y, label = prefijo),
              family = MONO, size = TAM_MONO, colour = AZUL,
              fontface = "bold", hjust = 0) +
    geom_text(data = filas, aes(x = x_cue, y = y, label = cuerpo),
              family = MONO, size = TAM_MONO, colour = GRIS, hjust = 0) +
    geom_text(data = filas[nzchar(filas$version), ],
              aes(x = x_ver, y = y, label = version),
              family = MONO, size = TAM_MONO, colour = NARANJA,
              fontface = "bold", hjust = 0) +

    # --- Qué es y la pista ---
    geom_text(data = filas, aes(x = X_QUE, y = y, label = que),
              family = SANS, size = TAM_QUE, colour = TEXTO, hjust = 0) +
    geom_text(data = filas, aes(x = X_PISTA, y = y, label = pista),
              family = SANS, size = TAM_PISTA, colour = GRIS,
              fontface = "italic", hjust = 0) +

    # --- Leyenda del color ---
    annotate("segment", x = 3, xend = ANCHO_PANEL - 3,
             y = Y_LEYENDA + 5, yend = Y_LEYENDA + 5,
             colour = alpha(GRIS, 0.45), linewidth = 0.35) +
    geom_text(data = leyenda, aes(x = x, y = Y_LEYENDA, label = txt,
                                  colour = I(col)),
              family = SANS, size = TAM_QUE, fontface = "bold", hjust = 0) +
    annotate("text", x = X_ACC + 100, y = Y_LEYENDA,
             label = "dos filas van sin versión: es el contraste, no un olvido",
             family = SANS, size = TAM_PISTA, colour = GRIS,
             fontface = "italic", hjust = 0) +

    coord_cartesian(xlim = c(0, ANCHO_PANEL), ylim = c(0, ALTO_PANEL),
                    expand = FALSE, clip = "off") +
    tema_esquema()
}


if (!interactive()) {
  # El despiece tiene que reconstruir el original, carácter por carácter.
  rearmado <- paste0(filas$prefijo, filas$cuerpo, filas$version)

  m_pista <- media_ancho(filas$pista, TAM_PISTA)
  m_que   <- media_ancho(filas$que, TAM_QUE)

  stopifnot(
    # --- El despiece es fiel ---
    identical(rearmado, filas$acc),
    all(nzchar(filas$prefijo)), all(nzchar(filas$cuerpo)),
    all(grepl("^[A-Z]+_?$", filas$prefijo)),
    all(grepl("^[0-9]+$", filas$cuerpo)),
    all(filas$version == "" | grepl("^\\.[0-9]+$", filas$version)),

    # --- Las reglas que enseña el capítulo se cumplen en los ejemplos ---
    # "si lleva guión bajo, es RefSeq" — y sólo esas dos filas lo llevan
    all(grepl("_$", filas$prefijo) == grepl("^RefSeq", filas$que)),
    # las dos filas de RefSeq son las que traen versión
    all(nzchar(filas$version) == grepl("^RefSeq", filas$que)),
    sum(nzchar(filas$version)) == 2L,

    nrow(filas) == 8L,
    !anyDuplicated(filas$acc),

    # --- Nada se sale del panel ni se encima con la columna siguiente ---
    max(filas$x_ver + nchar(filas$version) * CHAR) < X_QUE,
    all(X_QUE + 2 * m_que < X_PISTA),
    all(X_PISTA + 2 * m_pista <= ANCHO_PANEL),
    min(filas$y) - PASO / 2 > Y_LEYENDA + 5,
    max(filas$y) < Y_CABEZA - 3.6,
    Y_CABEZA <= ALTO_PANEL
  )

  message(sprintf("  %d identificadores, despiezados y rearmados sin pérdida:",
                  nrow(filas)))
  for (k in seq_len(nrow(filas))) {
    message(sprintf("    %-16s = [%s][%s][%s]", filas$acc[k], filas$prefijo[k],
                    filas$cuerpo[k],
                    ifelse(nzchar(filas$version[k]), filas$version[k], "-")))
  }
  message(sprintf("  con versión: %d de %d (las dos de RefSeq)",
                  sum(nzchar(filas$version)), nrow(filas)))

  escribir_tsv(filas[, c("acc", "prefijo", "cuerpo", "version", "que", "pista")],
               "decodificador")
  guardar(construir(), "decodificador", 16, 10)
}
