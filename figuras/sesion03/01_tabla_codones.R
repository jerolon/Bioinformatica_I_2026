## Fig. @fig-tabla-codones (Sesión 3, § La tabla no es aleatoria)
## Los 64 codones coloreados por clase química del aminoácido.
##
## ---------------------------------------------------------------------------
## POR QUÉ ESTA DISPOSICIÓN Y NO facet_wrap(~ b3)
##
## El único criterio de éxito de esta figura es que se vea que LA SEGUNDA
## POSICIÓN MANDA. Eso se ve si, y sólo si, cada valor de la segunda base es una
## columna continua de arriba abajo: dieciséis celdas del mismo color seguidas.
##
## Se probaron las dos opciones de la especificación:
##
##   facet_wrap(~ b3)   parte la tabla en cuatro paneles de 4x4. Cada columna
##                      queda de cuatro celdas y se repite cuatro veces con
##                      marcos en medio. El bloque de color se rompe justo en la
##                      dirección en la que había que leerlo. Descartada.
##
##   b1 x b3 anidados   la disposición clásica del libro de texto: 16 filas
##   en el eje y        (primera base afuera, tercera adentro) por 4 columnas
##                      (segunda base). La columna de la U mide 16 celdas y el
##                      naranja de los hidrofóbicos se ve de un golpe. Ésta.
##
## Con 18 cm de ancho cada columna mide 39 mm, así que en cada celda cabe el
## codón, la letra y el nombre de tres letras en un solo renglón.
## ---------------------------------------------------------------------------
##
## La tabla NO está tecleada: sale de Biostrings::getGeneticCode("1"). Se
## muestra con U porque el capítulo habla de ARNm; el `codon` con T sigue en el
## .tsv, que es como se guarda en los archivos.
##
## Sin título dentro del SVG: el caption vive en el .qmd.
##
## Regenerar:  Rscript figuras/sesion03/01_tabla_codones.R

.ubicar <- function() {
  for (i in rev(seq_len(sys.nframe()))) {   # de adentro hacia afuera
    o <- sys.frame(i)$ofile
    if (!is.null(o)) return(normalizePath(o, winslash = "/"))
  }
  a <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1]), winslash = "/"))
  stop("no se pudo ubicar el script: correr con Rscript o con source()")
}
source(file.path(dirname(.ubicar()), "_codigo.R"))


# --- Los datos --------------------------------------------------------------
d <- tabla_codigo("1")

# --- Geometría, en milímetros -----------------------------------------------
# guardar(w = 18, h = 12) con 2 mm de margen a los lados: panel de 176 x 110 mm.
ANCHO_PANEL <- 176
ALTO_PANEL  <- 110

X_REJILLA <- 13                 # borde izquierdo de la rejilla
W_COL     <- 39                 # ancho de columna (4 columnas = 156 mm)
N_COL     <- length(ORDEN_BASES)
X_FIN     <- X_REJILLA + N_COL * W_COL

Y_REJILLA <- 22                 # borde inferior
H_FILA    <- 4.75               # 16 filas = 76 mm
N_FILA    <- 16
Y_TOPE    <- Y_REJILLA + N_FILA * H_FILA

Y_CABEZA  <- Y_TOPE + 3.5       # U C A G sobre las columnas
Y_TITULO  <- Y_TOPE + 8.5       # "Segunda base"

Y_LLAVE   <- Y_REJILLA - 2.5    # llave bajo la rejilla
PROF_LLAVE <- 3
Y_NOTA    <- Y_REJILLA - 10

Y_LEYENDA <- 4

# Desplazamientos dentro de cada celda, desde su borde izquierdo.
DX_CODON  <- 4                  # codón, alineado a la izquierda
DX_LETRA  <- 18                 # letra de una sola letra, centrada
DX_NOMBRE <- 22                 # nombre de tres letras, alineado a la izquierda

TAM_CODON  <- 2.3
TAM_LETRA  <- 2.7
TAM_NOMBRE <- 2.1
TAM_EJE    <- 2.6
TAM_TITULO <- 2.5
TAM_LEY    <- 2.2
TAM_NOTA   <- 2.3

SANS <- familia_base()
MONO <- familia_mono()


# --- Colocación de las 64 celdas --------------------------------------------
# Columna: segunda base. Fila: primera base (afuera) y tercera base (adentro),
# las dos en el orden canónico U, C, A, G y contando desde ARRIBA.
i_col <- match(chartr("T", "U", d$b2), ORDEN_BASES)
i_b1  <- match(chartr("T", "U", d$b1), ORDEN_BASES)
i_b3  <- match(chartr("T", "U", d$b3), ORDEN_BASES)
i_fila <- (i_b1 - 1L) * length(ORDEN_BASES) + i_b3      # 1..16, de arriba abajo

celdas <- transform(
  d,
  xmin = X_REJILLA + (i_col - 1L) * W_COL,
  ymax = Y_TOPE    - (i_fila - 1L) * H_FILA
)
celdas$xmax  <- celdas$xmin + W_COL
celdas$ymin  <- celdas$ymax - H_FILA
celdas$y     <- (celdas$ymin + celdas$ymax) / 2
celdas$clase <- clase_ordenada(celdas$clase)
celdas$relleno <- unname(colores_clase[as.character(celdas$clase)])
celdas$tinta   <- texto_sobre(celdas$relleno)
# Los codones de paro no llevan nombre de tres letras: "Paro" ya está en la
# leyenda y en la celda sólo estorbaría.
celdas$etiqueta_nombre <- ifelse(celdas$aa == "*", "", celdas$nombre)
celdas$letra <- ifelse(celdas$aa == "*", "–", celdas$aa)   # guión para paro

# --- Rótulos de los ejes ----------------------------------------------------
cabeceras <- data.frame(
  base = ORDEN_BASES,
  x    = X_REJILLA + (seq_along(ORDEN_BASES) - 0.5) * W_COL
)

# Primera base: una etiqueta por grupo de cuatro filas, centrada en el grupo.
prim <- data.frame(
  base = ORDEN_BASES,
  y    = Y_TOPE - (seq_along(ORDEN_BASES) - 0.5) * 4 * H_FILA
)
# Tercera base: se repite dentro de cada grupo, al margen derecho.
terc <- data.frame(
  base = rep(ORDEN_BASES, times = 4),
  y    = Y_TOPE - (seq_len(N_FILA) - 0.5) * H_FILA
)

# Separadores gruesos entre los cuatro grupos de primera base.
separadores <- data.frame(y = Y_TOPE - (0:4) * 4 * H_FILA)

llave_col <- llave(X_REJILLA, X_FIN, Y_LLAVE, PROF_LLAVE, arriba = FALSE)
NOTA <- "la columna —la segunda base— determina la clase química"

# --- Leyenda ----------------------------------------------------------------
# Se reparte a lo ancho midiendo cada etiqueta, para que quede pareja sin
# acomodar posiciones a mano.
W_SWATCH <- 4.5
H_SWATCH <- 3
SEP_TXT  <- 1.6
SEP_ITEM <- 6

ley <- data.frame(clase = NIVELES_CLASE, stringsAsFactors = FALSE)
ley$ancho <- W_SWATCH + SEP_TXT + 2 * media_ancho(ley$clase, TAM_LEY)
ley$x     <- cumsum(c(0, head(ley$ancho + SEP_ITEM, -1)))
ley$x     <- ley$x + (ANCHO_PANEL - (sum(ley$ancho) + SEP_ITEM * (nrow(ley) - 1))) / 2
ley$relleno <- unname(colores_clase[ley$clase])


construir <- function() {
  ggplot() +
    # --- Las 64 celdas ---
    geom_rect(data = celdas,
              aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax,
                  fill = clase),
              colour = "white", linewidth = 0.25) +
    geom_text(data = celdas, aes(x = xmin + DX_CODON, y = y, label = codon_arn,
                                 colour = tinta),
              family = MONO, size = TAM_CODON, hjust = 0, show.legend = FALSE) +
    geom_text(data = celdas, aes(x = xmin + DX_LETRA, y = y, label = letra,
                                 colour = tinta),
              family = SANS, size = TAM_LETRA, fontface = "bold",
              show.legend = FALSE) +
    geom_text(data = celdas, aes(x = xmin + DX_NOMBRE, y = y,
                                 label = etiqueta_nombre, colour = tinta),
              family = SANS, size = TAM_NOMBRE, hjust = 0, alpha = 0.85,
              show.legend = FALSE) +

    # --- Separadores entre grupos de primera base ---
    geom_segment(data = separadores,
                 aes(x = X_REJILLA, xend = X_FIN, y = y, yend = y),
                 colour = "white", linewidth = 0.8) +

    # --- Rótulos ---
    geom_text(data = cabeceras, aes(x = x, y = Y_CABEZA, label = base),
              family = MONO, size = TAM_EJE, colour = TEXTO) +
    geom_text(data = data.frame(1),
              aes(x = (X_REJILLA + X_FIN) / 2, y = Y_TITULO),
              label = "Segunda base", family = SANS, size = TAM_TITULO,
              colour = GRIS) +
    geom_text(data = prim, aes(x = X_REJILLA - 4, y = y, label = base),
              family = MONO, size = TAM_EJE, colour = TEXTO) +
    geom_text(data = data.frame(1), aes(x = 3.5, y = (Y_REJILLA + Y_TOPE) / 2),
              label = "Primera base", family = SANS, size = TAM_TITULO,
              colour = GRIS, angle = 90) +
    geom_text(data = terc, aes(x = X_FIN + 2.5, y = y, label = base),
              family = MONO, size = TAM_NOMBRE, colour = GRIS, hjust = 0) +
    geom_text(data = data.frame(1),
              aes(x = ANCHO_PANEL - 1, y = (Y_REJILLA + Y_TOPE) / 2),
              label = "Tercera base", family = SANS, size = TAM_TITULO,
              colour = GRIS, angle = 90) +

    # --- La llave que dice de qué va la figura ---
    geom_path(data = llave_col, aes(x = x, y = y),
              colour = GRIS, linewidth = 0.45, lineend = "round") +
    geom_text(data = data.frame(1),
              aes(x = (X_REJILLA + X_FIN) / 2, y = Y_NOTA), label = NOTA,
              family = SANS, size = TAM_NOTA, colour = TEXTO) +

    # --- Leyenda horizontal, dibujada a mano ---
    geom_rect(data = ley,
              aes(xmin = x, xmax = x + W_SWATCH,
                  ymin = Y_LEYENDA - H_SWATCH / 2, ymax = Y_LEYENDA + H_SWATCH / 2,
                  fill = clase),
              colour = NA) +
    geom_text(data = ley, aes(x = x + W_SWATCH + SEP_TXT, y = Y_LEYENDA,
                              label = clase),
              family = SANS, size = TAM_LEY, colour = TEXTO, hjust = 0) +

    scale_fill_manual(values = colores_clase, guide = "none") +
    scale_colour_identity() +
    coord_cartesian(xlim = c(0, ANCHO_PANEL), ylim = c(0, ALTO_PANEL),
                    expand = FALSE, clip = "off") +
    labs(caption = paste("Código estándar (tabla 1 del NCBI), vía",
                         "Biostrings::getGeneticCode(). Los codones se muestran",
                         "en ARN; en los archivos van con T.")) +
    tema_esquema()
}


if (!interactive()) {
  # ¿De verdad la columna determina la clase? Se mide en vez de afirmarlo: para
  # cada segunda base, qué fracción de sus 16 codones cae en la clase mayoritaria
  # de esa columna. Si esta figura deja de tener sentido, este número lo dice.
  pureza <- sapply(ORDEN_BASES, function(b) {
    cl <- celdas$clase[chartr("T", "U", celdas$b2) == b]
    max(table(cl)) / length(cl)
  })
  # Lo mismo por FILA, para tener con qué comparar.
  pureza_fila <- sapply(ORDEN_BASES, function(b) {
    cl <- celdas$clase[chartr("T", "U", celdas$b1) == b]
    max(table(cl)) / length(cl)
  })

  ancho_codon  <- 2 * media_ancho(celdas$codon_arn, TAM_CODON, AVANCE_MONO)
  ancho_nombre <- 2 * media_ancho(celdas$nombre,    TAM_NOMBRE)

  stopifnot(
    # --- Los datos ---
    nrow(d) == 64L,
    sum(d$aa == "*") == 3L,                       # UAA, UAG, UGA
    identical(sort(d$codon_arn[d$aa == "*"]), c("UAA", "UAG", "UGA")),
    length(unique(d$aa[d$aa != "*"])) == 20L,
    all(!grepl("T", d$codon_arn)),                # se muestra en ARN

    # --- La rejilla está completa y sin celdas encimadas ---
    nrow(celdas) == 64L,
    length(unique(paste(i_col, i_fila))) == 64L,
    max(i_fila) == N_FILA, min(i_fila) == 1L,

    # --- El texto cabe en su celda ---
    DX_CODON + ancho_codon < DX_LETRA - 1,
    all(DX_NOMBRE + ancho_nombre < W_COL - 1),
    TAM_LETRA < H_FILA - 1,

    # --- Nada se sale del panel ---
    X_FIN + 6 <= ANCHO_PANEL,
    Y_TITULO + TAM_TITULO <= ALTO_PANEL,
    min(llave_col$y) > Y_NOTA + TAM_NOTA,
    Y_NOTA - TAM_NOTA > Y_LEYENDA + H_SWATCH,
    min(ley$x) >= 0, max(ley$x + ley$ancho) <= ANCHO_PANEL,

    # --- Lo que la figura afirma ---
    # La columna tiene que ser MÁS homogénea que la fila; si no, la figura
    # estaría enseñando algo que no está ahí.
    mean(pureza) > mean(pureza_fila)
  )

  message("  tabla 1: 64 codones, 20 aminoácidos, 3 codones de paro")
  message("  homogeneidad por COLUMNA (segunda base), fracción en la clase dominante:")
  for (b in ORDEN_BASES) {
    cl <- celdas$clase[chartr("T", "U", celdas$b2) == b]
    message(sprintf("    %s -> %4.0f %%  (%s)", b, 100 * pureza[[b]],
                    names(which.max(table(cl)))))
  }
  message(sprintf("  media por columna: %.0f %%   vs. media por fila (primera base): %.0f %%",
                  100 * mean(pureza), 100 * mean(pureza_fila)))

  escribir_tsv(d[, c("codon", "codon_arn", "aa", "nombre", "clase",
                     "b1", "b2", "b3")],
               "tabla-codones")
  guardar(construir(), "tabla-codones", 18, 12)
}
