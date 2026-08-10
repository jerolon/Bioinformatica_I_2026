## Configuración compartida de las CUATRO figuras de la Sesión 4,
## Matrices de sustitución.
##
## A diferencia de los _tema.R de las sesiones 2 y 3, éste NO sourcea estilo.R
## directamente: sourcea `figuras/sesion03/_codigo.R`, que a su vez trae
## estilo.R. La razón es la especificación: "reutiliza clases_aa y
## colores_clase de figuras/sesion03/_codigo.R para que las tres sesiones se
## lean como una sola familia visual". Duplicar esas dos tablas acá sería
## garantizar que algún día se desincronicen.
##
## Lo único que hay que deshacer es el destino de la salida: sesion03/_tema.R
## define guardar() y escribir_tsv() apuntando a figuras/sesion03/. Se
## redefinen abajo, después del source, para que escriban en sesion04/.
##
## Uso, desde cualquier working directory:
##     source(".../figuras/sesion04/_tema.R")   # los scripts lo hacen solos

.ubicar_tema <- function() {
  for (i in rev(seq_len(sys.nframe()))) {   # de adentro hacia afuera
    o <- sys.frame(i)$ofile
    if (!is.null(o)) return(normalizePath(o, winslash = "/"))
  }
  a <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1]), winslash = "/"))
  stop("no se pudo ubicar _tema.R: correr con Rscript o con source()")
}

.DIR_SESION04 <- dirname(.ubicar_tema())
source(file.path(dirname(.DIR_SESION04), "sesion03", "_codigo.R"))

# De sesion03/_codigo.R llegan: la paleta (AZUL, AZUL_CLARO, NARANJA, MORADO,
# VERDE, GRIS, TEXTO), tema_libro(), tema_esquema(), clases_aa, colores_clase,
# NIVELES_CLASE, nombres_aa, clase_ordenada(), y los helpers de dibujo
# (media_ancho, llave, circulo, aclarar, texto_sobre, AVANCE_*).

suppressPackageStartupMessages(library(Biostrings))

# --- Salida: se reapunta a sesion04/ ---------------------------------------
.guardar_pulgadas <- .guardar_pulgadas   # el de estilo.R, ya capturado por sesion03

guardar <- function(p, nombre, w = 16, h = 10) {
  .guardar_pulgadas(p, nombre, subdir = "sesion04",
                    ancho = w / CM_POR_PULGADA, alto = h / CM_POR_PULGADA)
}

escribir_tsv <- function(df, nombre) {
  ruta <- file.path(.DIR_SESION04, paste0(nombre, ".tsv"))
  write.table(df, ruta, sep = "\t", row.names = FALSE, quote = FALSE,
              fileEncoding = "UTF-8")
  message(sprintf("  escrito figuras/sesion04/%s.tsv", nombre))
  invisible(ruta)
}


# --- BLOSUM62 y los 20 aminoácidos canónicos --------------------------------
#' Los 20 aminoácidos canónicos, tal como los nombra Biostrings.
#'
#' OJO: `setdiff(rownames(BLOSUM62), c("B","Z","X","*"))` NO da 20, da 21. La
#' matriz de Biostrings incluye además **J** (Xle: "Leu o Ile"), que es un
#' código de ambigüedad como B y Z, no un aminoácido. Si se cuela, la diagonal
#' deja de ir de +4 a +11 —J/J vale +3— y el capítulo diría algo falso. Hay que
#' quitarlo explícitamente.
AMBIGUOS <- c("B", "Z", "X", "J", "*")

aminoacidos_canonicos <- function(M) sort(setdiff(rownames(M), AMBIGUOS))

#' BLOSUM62 recortada a los 20 canónicos, en orden alfabético.
blosum62 <- function() {
  M <- get(utils::data("BLOSUM62", package = "Biostrings",
                       envir = environment()))
  aa <- aminoacidos_canonicos(M)
  stopifnot(length(aa) == 20L)
  M[aa, aa]
}

#' Los 190 pares distintos i<j, como data.frame.
#' Se excluye la diagonal a propósito: una identidad no es una sustitución, y
#' Grantham vale 0 para todas ellas. Ver la nota en 01_blosum_grantham.R.
pares_aa <- function(M) {
  aa  <- rownames(M)
  idx <- which(upper.tri(M), arr.ind = TRUE)
  d <- data.frame(aa1 = aa[idx[, "row"]], aa2 = aa[idx[, "col"]],
                  stringsAsFactors = FALSE)
  d$blosum      <- M[idx]
  d$clase1      <- unname(clases_aa[d$aa1])
  d$clase2      <- unname(clases_aa[d$aa2])
  d$misma_clase <- d$clase1 == d$clase2
  d[order(d$aa1, d$aa2), ]
}
