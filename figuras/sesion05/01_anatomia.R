## Fig. @fig-anatomia (Sesión 5, § Anatomía de un registro)
## Las primeras líneas reales del FASTA de lambda, con los saltos de línea
## dibujados como lo que son: bytes del archivo que no son bases.
##
## ---------------------------------------------------------------------------
## POR QUÉ NO SE REUTILIZÓ LA DE LA SESIÓN 01
##
## La especificación decía que había una figura parecida en la sesión 2. No la
## hay: está en `figuras/sesion01/` (`01_fasta_anatomia.R`). Se revisó y no
## sirve tal cual para este capítulo, por tres razones concretas:
##
##   1. Marca UN solo salto de línea, el de la primera línea de secuencia. Acá
##      el punto es que hay uno al final de CADA línea y que sumados pesan.
##   2. No compara bytes contra bases, que es el remate que pide esta figura y
##      el contenido de los ejercicios 1 y 2.
##   3. Es la anatomía "de presentación" (qué parte es qué); ésta tiene que ser
##      literal y agresiva con el costo en bytes.
##
## Las dos pueden convivir: la de la sesión 01 presenta el formato, ésta lo
## audita. Comparten el mismo archivo de origen y no se contradicen.
## ---------------------------------------------------------------------------
##
## TODO LO QUE DICE ESTA FIGURA ESTÁ MEDIDO SOBRE EL ARCHIVO. El ancho de
## plegado, los bytes, las bases y las líneas salen de anatomia_archivo(), no
## de la prosa del capítulo. Es deliberado: el archivo que devuelve `efetch` hoy
## viene a 70 caracteres por línea, no a 60, y por eso los totales de bytes y
## de líneas no son los que cita el texto. Ver FIGURAS.md.
##
## Sin título dentro del SVG: el caption vive en el .qmd.
##
## Regenerar:  bash figuras/sesion05/00_datos.sh   # una vez
##             Rscript figuras/sesion05/01_anatomia.R

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


# --- Los datos, medidos ------------------------------------------------------
ACC <- "NC_001416.1"
info <- anatomia_archivo(ruta_fasta(ACC))

N_SEC <- 3L                       # cuántas líneas de secuencia se dibujan
lineas <- c(info$encabezado,
            info$lineas[!grepl("^>", info$lineas) & nzchar(info$lineas)][1:N_SEC])

# El identificador es lo que va hasta el primer espacio: la convención del
# capítulo. Se calcula, no se teclea.
pos_espacio <- regexpr(" ", info$encabezado, fixed = TRUE)
ID   <- substr(info$encabezado, 2, pos_espacio - 1)
DESC <- substr(info$encabezado, pos_espacio + 1, nchar(info$encabezado))

# Las dos cuentas del ejercicio 2.
BYTES <- info$bytes
BASES <- info$bases


# --- Geometría, en milímetros -----------------------------------------------
# guardar(w = 16, h = 9) con 2 mm de margen: panel de 156 x 84 mm.
ANCHO_PANEL <- 156
ALTO_PANEL  <- 84

TAM_MONO <- 3.0
CHAR <- TAM_MONO * AVANCE_MONO    # ancho de un carácter monoespaciado, en mm

X_TXT <- 9                        # borde izquierdo del texto
X_PARR <- X_TXT + info$ancho * CHAR + 0.6   # columna de los ¶

CAJA <- c(6, X_PARR + 4)          # la caja de fondo abraza también los ¶

Y_ENC <- 66                       # el encabezado
Y_SEC <- c(58, 52, 46)            # las tres líneas de secuencia
CAJA_Y <- c(41, 71)

Y_ETIQ_ENC <- 81                  # los tres rótulos del encabezado

Y_LLAVE <- 39
PROF_LLAVE <- 2.6
Y_ANCHO <- 34

Y_PARR_TXT <- 26                  # el mensaje grande del salto de línea
Y_WC  <- 15
Y_BAS <- 8

TAM_ETIQ  <- 2.0
TAM_PARR  <- 2.7
TAM_CUENTA <- 2.5
TAM_ANCHO <- 2.1

SANS <- familia_base()
MONO <- familia_mono()

# El símbolo de salto de línea. Se usa "¶" y no una flecha doblada porque una
# flecha hay que dibujarla con paths y a este tamaño se vuelve una mancha; el
# calderón se lee como carácter y además ES un carácter, que es el punto.
PARR <- "¶"


# --- Colocación --------------------------------------------------------------
# Cada línea dibujada, con su ¶ al final.
filas <- data.frame(
  texto = lineas,
  y     = c(Y_ENC, Y_SEC),
  stringsAsFactors = FALSE
)
filas$x_parr <- X_TXT + nchar(filas$texto) * CHAR + 0.6
# El encabezado es más corto que las líneas de secuencia: su ¶ va pegado a él,
# no alineado con los otros tres. Si se alinearan todos, la figura sugeriría
# que el salto está en una columna fija, que es justo lo que no es.

# Rótulos del encabezado, con su llamada curva al carácter que señalan.
etiquetas <- data.frame(
  texto = c("marca de inicio\nde registro",
            "identificador\n(hasta el primer espacio)",
            "descripción libre, sin reglas"),
  # centro del tramo que señala, en caracteres desde el inicio de la línea
  char  = c(0.5, (pos_espacio - 1) / 2, (pos_espacio + nchar(info$encabezado)) / 2),
  x_lab = c(4, 44, 96),
  hjust = c(0, 0, 0),
  stringsAsFactors = FALSE
)
etiquetas$x_obj <- X_TXT + etiquetas$char * CHAR

curvas <- do.call(rbind, lapply(seq_len(nrow(etiquetas)), function(i) {
  transform(llamada(etiquetas$x_lab[i] + 6, Y_ETIQ_ENC - 4.5,
                    etiquetas$x_obj[i], Y_ENC + 3, comba = 0.16), id = i)
}))

# Resaltados de fondo del encabezado.
resalta <- data.frame(
  xmin = X_TXT + c(0, 1, pos_espacio) * CHAR,
  xmax = X_TXT + c(1, pos_espacio - 1, nchar(info$encabezado)) * CHAR,
  fill = c(NARANJA, AZUL, GRIS)
)

llave_ancho <- llave(X_TXT, X_TXT + info$ancho * CHAR, Y_LLAVE, PROF_LLAVE,
                     arriba = FALSE)
TXT_ANCHO <- sprintf("%d caracteres por línea, por convención, no por norma",
                     info$ancho)

TXT_PARR <- "cada uno de estos ocupa un byte y NO es una base"

# Guía en L: baja por la columna de los ¶ y dobla hacia el borde derecho del
# mensaje, que está centrado en el panel.
.borde_msg <- ANCHO_PANEL / 2 + media_ancho(TXT_PARR, TAM_PARR) + 2
guia_parr <- data.frame(
  x = c(X_PARR + 1.5, X_PARR + 1.5, .borde_msg),
  y = c(min(Y_SEC) - 3, Y_PARR_TXT, Y_PARR_TXT)
)

TXT_WC  <- sprintf("wc -c            -> %s   (bytes: encabezado + saltos + bases)",
                   format(BYTES, big.mark = ","))
TXT_BAS <- sprintf("grep -v | tr -d  -> %s   (bases)",
                   format(BASES, big.mark = ","))


construir <- function() {
  ggplot() +
    # --- La caja de fondo ---
    annotate("rect", xmin = CAJA[1], xmax = CAJA[2],
             ymin = CAJA_Y[1], ymax = CAJA_Y[2],
             fill = alpha(AZUL_CLARO, 0.10), colour = alpha(GRIS, 0.5),
             linewidth = 0.3) +

    # --- Resaltados del encabezado, detrás del texto ---
    geom_rect(data = resalta,
              aes(xmin = xmin, xmax = xmax, ymin = Y_ENC - 2.1, ymax = Y_ENC + 2.1),
              fill = alpha(resalta$fill, 0.18), colour = NA) +

    # --- Las cuatro líneas reales ---
    geom_text(data = filas, aes(x = X_TXT, y = y, label = texto),
              family = MONO, size = TAM_MONO, colour = TEXTO, hjust = 0) +

    # --- Los ¶: el punto de la figura ---
    geom_text(data = filas, aes(x = x_parr, y = y), label = PARR,
              family = MONO, size = TAM_MONO * 1.25, colour = NARANJA,
              fontface = "bold", hjust = 0) +

    # --- Rótulos del encabezado con llamadas curvas ---
    geom_path(data = curvas, aes(x = x, y = y, group = id),
              colour = AZUL, linewidth = 0.35) +
    geom_text(data = etiquetas, aes(x = x_lab, y = Y_ETIQ_ENC, label = texto,
                                    hjust = hjust),
              family = SANS, size = TAM_ETIQ, colour = AZUL, lineheight = 1.05) +

    # --- Llave del ancho de plegado ---
    geom_path(data = llave_ancho, aes(x = x, y = y),
              colour = GRIS, linewidth = 0.4, lineend = "round") +
    geom_text(data = data.frame(1),
              aes(x = (X_TXT + X_TXT + info$ancho * CHAR) / 2, y = Y_ANCHO),
              label = TXT_ANCHO, family = SANS, size = TAM_ANCHO, colour = GRIS) +

    # --- El mensaje grande ---
    # La guía baja por la columna de los ¶ y dobla hacia el texto. Recta hacia
    # abajo se quedaba colgando a 25 mm del mensaje, que está centrado, y se
    # leía como una línea suelta en vez de como una llamada.
    geom_path(data = guia_parr, aes(x = x, y = y),
              colour = NARANJA, linewidth = 0.4, linetype = "dotted") +
    geom_text(data = data.frame(1), aes(x = ANCHO_PANEL / 2, y = Y_PARR_TXT),
              label = TXT_PARR, family = SANS, size = TAM_PARR, colour = NARANJA,
              fontface = "bold") +

    # --- Las dos cuentas ---
    geom_text(data = data.frame(1), aes(x = X_TXT, y = Y_WC), label = TXT_WC,
              family = MONO, size = TAM_CUENTA, colour = alpha(GRIS, 0.85),
              hjust = 0) +
    geom_text(data = data.frame(1), aes(x = X_TXT, y = Y_BAS), label = TXT_BAS,
              family = MONO, size = TAM_CUENTA, colour = VERDE, hjust = 0,
              fontface = "bold") +

    coord_cartesian(xlim = c(0, ANCHO_PANEL), ylim = c(0, ALTO_PANEL),
                    expand = FALSE, clip = "off") +
    labs(caption = sprintf(paste("Primeras %d líneas de datos/%s.fa (RefSeq).",
                                 "Los bytes, las bases y el ancho de plegado están",
                                 "medidos sobre el archivo,\nno transcritos: este",
                                 "viene a %d caracteres por línea, y con otro ancho",
                                 "el total de bytes cambia sin que cambie el genoma."),
                           nrow(filas), ACC, info$ancho)) +
    tema_esquema()
}


if (!interactive()) {
  m_etiq <- media_ancho(etiquetas$texto, TAM_ETIQ)
  m_parr <- media_ancho(TXT_PARR, TAM_PARR)
  m_wc   <- media_ancho(c(TXT_WC, TXT_BAS), TAM_CUENTA, AVANCE_MONO)

  # La identidad que sostiene toda la figura: el archivo pesa lo que pesan el
  # encabezado, las bases y UN salto por línea. Si no cierra, la figura estaría
  # afirmando algo falso sobre el archivo que tiene enfrente.
  n_lineas_reales <- info$n_registros + length(info$anchos) + info$n_blancas
  bytes_calculados <- nchar(info$encabezado) + info$bases + n_lineas_reales

  stopifnot(
    # --- Lo que se midió ---
    info$n_registros == 1L,
    info$bases == 48502L,                  # lambda, la única cifra anclada
    info$ancho > 0,
    BYTES > BASES,                         # el archivo pesa más que el genoma
    isTRUE(all.equal(bytes_calculados, BYTES)),
    length(lineas) == N_SEC + 1L,
    grepl("^>", lineas[1]),
    all(!grepl("^>", lineas[-1])),
    pos_espacio > 1,                       # el encabezado tiene un espacio
    nchar(ID) > 0, nchar(DESC) > 0,

    # --- Nada se sale del panel, nada se encima ---
    max(filas$x_parr) + 2 <= ANCHO_PANEL,
    CAJA[2] <= ANCHO_PANEL, CAJA[1] >= 0,
    max(Y_SEC) < Y_ENC, min(Y_SEC) > CAJA_Y[1],
    Y_ENC < CAJA_Y[2],
    Y_ETIQ_ENC + TAM_ETIQ <= ALTO_PANEL,
    min(llave_ancho$y) > Y_ANCHO + TAM_ANCHO,
    Y_ANCHO - TAM_ANCHO > Y_PARR_TXT + TAM_PARR,
    Y_PARR_TXT - TAM_PARR > Y_WC + TAM_CUENTA,
    Y_WC - TAM_CUENTA > Y_BAS + TAM_CUENTA / 2,
    Y_BAS - TAM_CUENTA >= 0,
    all(etiquetas$x_lab + 2 * m_etiq <= ANCHO_PANEL),
    ANCHO_PANEL / 2 - m_parr >= 0,
    all(X_TXT + 2 * m_wc <= ANCHO_PANEL)
  )

  message(sprintf("  %s", info$encabezado))
  message(sprintf("  identificador: %s   descripción: %s", ID, DESC))
  message(sprintf("  ancho de plegado medido: %d caracteres por línea", info$ancho))
  message(sprintf("  bytes %s = encabezado %d + bases %s + %d saltos",
                  format(BYTES, big.mark = ","), nchar(info$encabezado),
                  format(BASES, big.mark = ","), n_lineas_reales))
  message(sprintf("  líneas totales (wc -l): %d   registros: %d   en blanco: %d",
                  info$n_lineas, info$n_registros, info$n_blancas))
  message(sprintf("  sobrepeso del formato: %s bytes (%.1f %%)",
                  format(BYTES - BASES, big.mark = ","),
                  100 * (BYTES - BASES) / BASES))
  message("")
  message("  OJO: el capítulo dice 60 caracteres por línea, ~809 líneas y")
  message(sprintf("  ~49,365 bytes. Este archivo (efetch) viene a %d por línea.", info$ancho))
  message("  Ver FIGURAS.md, sección 'El ancho de plegado'.")

  escribir_tsv(
    data.frame(accession = ACC, encabezado = info$encabezado,
               identificador = ID, descripcion = DESC,
               ancho_plegado = info$ancho, bases = BASES, bytes = BYTES,
               lineas_wc_l = info$n_lineas, registros = info$n_registros,
               stringsAsFactors = FALSE),
    "fasta-anatomia")
  guardar(construir(), "fasta-anatomia", 16, 9)
}
