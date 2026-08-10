## Fig. @fig-pipe (Sesión 01, práctica, § Pipes: la filosofía modular de UNIX)
## Esquema del pipeline que mide el genoma de lambda:
##
##     grep -v "^>" datos/lambda.fasta | tr -d '\n' | wc -c
##
## No es una figura de datos sino un diagrama de flujo: cajas, flechas y glosas.
## Lo único que se calcula es el número de la última caja, que se lee del FASTA
## para que la figura no pueda desincronizarse del capítulo.
##
## Sin título dentro del SVG: el caption vive en el .qmd.
##
## Regenerar:  Rscript figuras/sesion01/02_pipeline.R

# `_tema.R` vive junto a este script: se ubica el archivo para que
# `Rscript figuras/sesion01/02_pipeline.R` corra desde la raíz del repo.
.ubicar <- function() {
  # Si el script se corrió con source() (RStudio, o desde otro script), el path
  # correcto es el `ofile` que source() deja en su frame. Se busca ESO primero:
  # commandArgs("--file=") apuntaría al script de AFUERA, no a éste.
  for (i in rev(seq_len(sys.nframe()))) {   # de adentro hacia afuera
    o <- sys.frame(i)$ofile
    if (!is.null(o)) return(normalizePath(o, winslash = "/"))
  }
  a <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1]), winslash = "/"))
  stop("no se pudo ubicar el script: correr con Rscript o con source()")
}
source(file.path(dirname(.ubicar()), "_tema.R"))


# --- El número de la última caja -------------------------------------------
# El alias corto lo crea 00_descarga_datos.sh y es el nombre que usa el
# capítulo, así que la figura lee EL MISMO archivo que van a teclear los alumnos.
ARCHIVO <- "lambda.fasta"

# leer_fasta() tira el header y todo lo que no sea letra: exactamente lo que
# hacen `grep -v "^>"` y `tr -d '\n'`. Por eso nchar() es el `wc -c` del final.
SECUENCIA <- leer_fasta(ruta_datos(ARCHIVO))
N_BASES   <- nchar(SECUENCIA)

#' ¿El archivo trae retornos de carro?
#'
#' La figura afirma que ESE pipeline imprime ESE número, y `tr -d '\n'` no borra
#' `\r`: con finales de línea de Windows el shell contaría 1 carácter de más por
#' línea y la figura estaría mintiendo. Se mira sobre los bytes crudos porque
#' readLines() ya traduce CRLF y taparía el problema.
tiene_cr <- function(ruta) {
  any(readBin(ruta, "raw", n = file.size(ruta)) == as.raw(13L))
}


# --- Las etapas de la cadena ------------------------------------------------
# Cinco nodos y cuatro flechas: el archivo, tres comandos y el resultado. Los
# dos extremos son datos (borde punteado); los tres del medio son programas.
etapas <- data.frame(
  orden    = 1:5,
  etiqueta = c("datos/lambda.fasta", "grep -v \"^>\"", "tr -d '\\n'", "wc -c",
               format(N_BASES)),
  tipo     = c("dato", "comando", "comando", "comando", "dato"),
  glosa    = c("", "quita el header", "quita los saltos de línea",
               "cuenta caracteres", ""),
  stringsAsFactors = FALSE
)


# --- Geometría, en milímetros ----------------------------------------------
# Con `guardar(w = 16, h = 6)` y 2 mm de margen a cada lado, el panel mide
# 156 mm de ancho; de los 60 mm de alto, la nota de fuente se lleva 3.5 mm.
# Fijando las escalas a esos rangos, 1 unidad = 1 mm; y como el `size` de
# geom_text también está en mm, el ancho de cada caja se DERIVA del texto que
# lleva adentro en vez de acomodarse a ojo. Si mañana cambia una etiqueta, la
# fila entera se reacomoda sola.
#
# El alto está medido sobre el SVG que sale (la nota es de una línea). Si se
# desfasa, lo único que pasa es que las unidades de y dejan de ser milímetros
# exactos; nada se rompe.
ANCHO_PANEL <- 156
ALTO_PANEL  <- 56.5

TAM_MONO   <- 2.7     # texto de las cajas
TAM_GLOSA  <- 2.1     # glosas y la palabra "stdout"
TAM_PIPE   <- 3.4     # la barra vertical, que tiene que leerse como símbolo
AVANCE     <- 0.6     # ancho de un carácter monoespaciado, en fracción del em
AIRE       <- 3.2     # aire entre el texto y el borde de su caja
ANCHO_MIN  <- 16      # piso: `wc -c` y el resultado son etiquetas de cinco
                      # caracteres y sin piso salen casi cuadrados junto a las
                      # demás, que es lo que rompe la lectura de la fila

Y_EJE     <- 31       # altura de la cadena; deja aire abajo para las glosas
ALTO_CAJA <- 12
Y_GLOSA   <- Y_EJE - ALTO_CAJA / 2 - 4.5
SEPARA    <- 3.4      # separación de las etiquetas respecto de la flecha
RETIRO    <- 1.0      # la flecha no toca la caja, se retira un poco

MONO <- familia_mono()
SANS <- familia_base()

ancho_caja <- pmax(nchar(etapas$etiqueta) * TAM_MONO * AVANCE + 2 * AIRE,
                   ANCHO_MIN)
# El aire sobrante se reparte por igual entre las cuatro flechas.
HUECO <- (ANCHO_PANEL - sum(ancho_caja)) / (nrow(etapas) - 1)

cajas <- transform(
  etapas,
  xmin = cumsum(c(0, head(ancho_caja, -1) + HUECO)),
  ymin = Y_EJE - ALTO_CAJA / 2,
  ymax = Y_EJE + ALTO_CAJA / 2
)
cajas$xmax <- cajas$xmin + ancho_caja
cajas$x    <- (cajas$xmin + cajas$xmax) / 2

# Qué lleva cada flecha.
#
# Ojo con la primera: en `grep -v "^>" datos/lambda.fasta` el archivo es un
# ARGUMENTO de grep, no algo que llegue por una tubería. Ponerle "|" o "stdout"
# enseñaría algo falso justo en la figura que explica los pipes, así que va
# desnuda. Los dos "|" quedan donde están en el comando, ni uno más. La última
# flecha sí es stdout (wc escribe a la terminal) pero tampoco es un pipe.
flechas <- data.frame(
  desde  = 1:4,
  stdout = c(FALSE, TRUE, TRUE, TRUE),
  pipe   = c(FALSE, TRUE, TRUE, FALSE)
)
flechas$x    <- cajas$xmax[flechas$desde] + RETIRO
flechas$xend <- cajas$xmin[flechas$desde + 1] - RETIRO
flechas$xm   <- (flechas$x + flechas$xend) / 2


construir <- function() {
  comandos <- subset(cajas, tipo == "comando")
  datos    <- subset(cajas, tipo == "dato")

  ggplot() +
    # Programas: borde sólido y un relleno tenue, para que la fila de comandos
    # se lea como un bloque y los extremos como lo que entra y lo que sale.
    geom_rect(data = comandos,
              aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
              fill = alpha(AZUL, 0.10), colour = AZUL, linewidth = 0.45) +
    # Datos: borde punteado, sin relleno.
    geom_rect(data = datos,
              aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
              fill = NA, colour = GRIS, linewidth = 0.45, linetype = "dotted") +
    # arrow.fill: sin él la punta cerrada sale hueca (ggplot no hereda el color
    # del trazo para el relleno del polígono).
    geom_segment(data = flechas,
                 aes(x = x, xend = xend, y = Y_EJE, yend = Y_EJE),
                 colour = GRIS, linewidth = 0.4, arrow.fill = GRIS,
                 arrow = arrow(length = unit(1.8, "mm"), type = "closed")) +
    geom_text(data = comandos, aes(x = x, y = Y_EJE, label = etiqueta),
              family = MONO, size = TAM_MONO, colour = AZUL) +
    geom_text(data = datos, aes(x = x, y = Y_EJE, label = etiqueta),
              family = MONO, size = TAM_MONO, colour = TEXTO) +
    geom_text(data = subset(cajas, glosa != ""),
              aes(x = x, y = Y_GLOSA, label = glosa),
              family = SANS, size = TAM_GLOSA, colour = GRIS) +
    geom_text(data = subset(flechas, stdout),
              aes(x = xm, y = Y_EJE + SEPARA), label = "stdout",
              family = SANS, size = TAM_GLOSA, colour = NARANJA) +
    geom_text(data = subset(flechas, pipe),
              aes(x = xm, y = Y_EJE - SEPARA), label = "|",
              family = MONO, size = TAM_PIPE, colour = TEXTO) +
    coord_cartesian(xlim = c(0, ANCHO_PANEL), ylim = c(0, ALTO_PANEL),
                    expand = FALSE, clip = "off") +
    labs(caption = paste("Fuente: NCBI, NC_001416.1 (fago lambda).",
                         "El conteo se recalcula del FASTA al generar la figura.")) +
    theme_void(base_size = 10, base_family = SANS) +
    theme(plot.caption = element_text(size = rel(0.73), colour = GRIS,
                                      face = "italic", hjust = 0,
                                      margin = margin(t = 3)),
          plot.caption.position = "plot",
          # El margen va acá y no en la escala, para que la nota de fuente
          # arranque exactamente donde arranca la primera caja.
          plot.margin = margin(0, 2, 0, 2, "mm"))
}


if (!interactive()) {
  # Ancho medio de un carácter de la fuente del libro, en fracción del em. Sirve
  # sólo para el chequeo de encimado de abajo; es una cota, no una medida.
  AVANCE_SANS <- 0.55
  media_glosa <- nchar(cajas$glosa) * TAM_GLOSA * AVANCE_SANS / 2

  # Las glosas son más anchas que su caja ("quita los saltos de línea" no cabe
  # debajo de `tr -d '\n'`), así que lo que se comprueba es que no se toquen
  # entre ellas. Mismo criterio que la línea del tiempo: si alguien alarga un
  # texto, el script truena en vez de dibujar encimado.
  con_glosa <- which(cajas$glosa != "")
  holgura <- diff(cajas$x[con_glosa]) -
    (head(media_glosa[con_glosa], -1) + tail(media_glosa[con_glosa], -1))

  stopifnot(
    N_BASES == 48502L,                    # tamaño del genoma de lambda
    !grepl("[^ACGT]", SECUENCIA),         # nada fuera del alfabeto de cuatro
    !tiene_cr(ruta_datos(ARCHIVO)),       # sin \r: `tr -d '\n'` no los borra
    identical(cajas$etiqueta[nrow(cajas)], format(N_BASES)),
    HUECO > 2 * RETIRO + 4,               # queda flecha visible entre cajas
    max(cajas$xmax) <= ANCHO_PANEL,       # la fila no se sale del panel
    all(holgura > 1.5)                    # las glosas no se enciman
  )

  message(sprintf("  %s: %d pb (el `wc -c` del pipeline)", ARCHIVO, N_BASES))
  message(sprintf("  %d cajas (%d datos, %d comandos), %d flechas, %d pipes",
                  nrow(cajas), sum(cajas$tipo == "dato"),
                  sum(cajas$tipo == "comando"), nrow(flechas),
                  sum(flechas$pipe)))
  message(sprintf("  hueco entre cajas %.1f mm; holgura mínima entre glosas %.1f mm",
                  HUECO, min(holgura)))
  message(sprintf("  familia monoespaciada: %s", MONO))

  escribir_tsv(etapas, "pipeline")
  guardar(construir(), "pipeline", 16, 6)
}
