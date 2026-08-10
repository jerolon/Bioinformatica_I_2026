## El código genético y las clases químicas de los aminoácidos.
## Lo comparten las cinco figuras de la Sesión 3.
##
## REGLA DE ESTE ARCHIVO: la tabla de codones NO se teclea. Sale de
## Biostrings::getGeneticCode(), que a su vez viene de las tablas del NCBI. Acá
## sólo se teclean las clases químicas, que son una decisión pedagógica y no un
## dato que se pueda derivar.
##
## Lo carga _tema.R? No: al revés. Este archivo sourcea _tema.R, así que a los
## scripts les basta con `source(".../_codigo.R")`.

.ubicar_codigo <- function() {
  for (i in rev(seq_len(sys.nframe()))) {   # de adentro hacia afuera
    o <- sys.frame(i)$ofile
    if (!is.null(o)) return(normalizePath(o, winslash = "/"))
  }
  a <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1]), winslash = "/"))
  stop("no se pudo ubicar _codigo.R: correr con Rscript o con source()")
}
source(file.path(dirname(.ubicar_codigo()), "_tema.R"))

suppressPackageStartupMessages(library(Biostrings))


# --- Clases químicas --------------------------------------------------------
# Agrupación estándar de libro de texto. No es LA clasificación (hay varias, y
# Gly y Cys caen en distintos lados según el autor); es la que usa el capítulo,
# y las cinco figuras tienen que usar la misma o dejan de leerse juntas.
clases_aa <- c(
  A = "Hidrofóbico", V = "Hidrofóbico", L = "Hidrofóbico", I = "Hidrofóbico",
  M = "Hidrofóbico", F = "Hidrofóbico", W = "Hidrofóbico", P = "Hidrofóbico",
  G = "Especial",    C = "Especial",
  S = "Polar",       T = "Polar",       Y = "Polar",
  N = "Polar",       Q = "Polar",
  D = "Ácido",       E = "Ácido",
  K = "Básico",      R = "Básico",      H = "Básico",
  `*` = "Paro"
)

# Orden de los niveles: fija el orden de la leyenda en las cinco figuras.
NIVELES_CLASE <- c("Hidrofóbico", "Polar", "Ácido", "Básico", "Especial", "Paro")

# Colores por clase. La especificación proponía hex propios; acá se cablean a la
# paleta del libro (ver el encabezado de _tema.R). El mapeo conserva la
# intención de cada color: hidrofóbico al naranja, polar al verde, ácido al
# azul, básico al morado, y los dos "no aminoácido" a grises.
#
# "Especial" y "Paro" no son clases químicas de verdad, son las dos bolsas de
# resto, y por eso van en gris y negro y no en un quinto tono: no compiten por
# atención con las cuatro que sí significan algo.
#
# El gris de "Especial" se mezcla con blanco de forma OPACA (aclarar) y no con
# alpha(). Con alpha() el color queda claro en pantalla pero col2rgb() sigue
# leyendo el gris oscuro de abajo, así que texto_sobre() elegía texto blanco
# para un relleno casi blanco y Cys y Gly se volvían ilegibles.
colores_clase <- c(
  "Hidrofóbico" = NARANJA,
  "Polar"       = VERDE,
  "Ácido"       = AZUL,
  "Básico"      = MORADO,
  "Especial"    = aclarar(GRIS, 0.45),
  "Paro"        = TEXTO
)

# Nombre de tres letras. Sólo para etiquetar; no se deriva de nada.
nombres_aa <- c(
  A = "Ala", R = "Arg", N = "Asn", D = "Asp", C = "Cys", Q = "Gln", E = "Glu",
  G = "Gly", H = "His", I = "Ile", L = "Leu", K = "Lys", M = "Met", F = "Phe",
  P = "Pro", S = "Ser", T = "Thr", W = "Trp", Y = "Tyr", V = "Val",
  `*` = "Paro"
)


# --- La tabla ---------------------------------------------------------------
#' Tabla de un código genético del NCBI, como data.frame de 64 filas.
#'
#' @param id id de tabla del NCBI en texto: "1" estándar, "2" mitocondrial de
#'   vertebrados, "11" bacteriano...
#'
#' Biostrings devuelve los codones en DNA (con T). Se conserva `codon` con T,
#' que es como se guardan en los archivos, y se agrega `codon_arn` con U, que
#' es como se enseña. Las figuras muestran `codon_arn`: el capítulo habla de
#' ARNm.
tabla_codigo <- function(id = "1") {
  gc <- Biostrings::getGeneticCode(id)
  d <- data.frame(
    codon = names(gc),
    aa    = as.character(gc),
    stringsAsFactors = FALSE
  )
  d$b1        <- substr(d$codon, 1, 1)
  d$b2        <- substr(d$codon, 2, 2)
  d$b3        <- substr(d$codon, 3, 3)
  d$codon_arn <- chartr("T", "U", d$codon)
  d$clase     <- unname(clases_aa[d$aa])
  d$nombre    <- unname(nombres_aa[d$aa])

  stopifnot(nrow(d) == 64L,               # 64 codones, ni uno más
            !anyNA(d$clase),              # toda letra tiene clase
            !anyNA(d$nombre),
            all(nchar(d$codon) == 3L))
  d
}

# Orden de las bases en las figuras. U, C, A, G es el orden canónico de la
# tabla de libro de texto, y NO es el alfabético que devolvería Biostrings.
ORDEN_BASES     <- c("U", "C", "A", "G")
ORDEN_BASES_DNA <- c("T", "C", "A", "G")

#' Convierte una columna de bases en factor con el orden canónico.
#' `arn = TRUE` además traduce T -> U.
base_ordenada <- function(x, arn = TRUE) {
  if (arn) x <- chartr("T", "U", x)
  factor(x, levels = if (arn) ORDEN_BASES else ORDEN_BASES_DNA)
}

#' Factor de clase con el orden de leyenda compartido, quedándose sólo con las
#' clases presentes (las figuras sin codones de paro no deben mostrar "Paro").
clase_ordenada <- function(x) {
  factor(x, levels = NIVELES_CLASE[NIVELES_CLASE %in% unique(x)])
}
