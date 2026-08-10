## Fig. composicion-lambda (Sesión 01, práctica) — Composición de bases del fago
## lambda: cuántas A, C, G y T hay en NC_001416.1.
##
## El punto pedagógico es que GC y AT están casi empatados (24 182 contra
## 24 320, 49.9% contra 50.1%). Por eso las barras van coloreadas por pareja
## —A y T en gris, C y G en azul— y no una por una: lo que debe leerse de un
## golpe son los dos bloques, no las cuatro barras sueltas.
##
## Todos los números salen de table() sobre el FASTA. Nada está tecleado.
##
## Sin título dentro del SVG: el caption vive en el .qmd.
##
## Regenerar:  Rscript figuras/sesion01/04_composicion.R

# `_tema.R` vive junto a este script: se ubica el archivo para que
# `Rscript figuras/sesion01/<script>.R` corra desde la raíz del repo.
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

# --- Anclas ----------------------------------------------------------------
# Verdad de campo medida sobre datos/NC_001416.1.fasta. Son las únicas cifras
# escritas a mano en el archivo, y existen sólo para que stopifnot() truene si
# alguien reemplaza el FASTA por otro registro.
#
# OJO: el cuerpo del capítulo dice 24 198 bases G/C. El conteo real del FASTA
# es 24 182. La discrepancia ya está reportada al autor; la figura muestra lo
# que calcula, no lo que dice el texto.
GENOMA        <- "NC_001416.1"
LARGO_ANCLA   <- 48502L
GC_ANCLA      <- 24182L

BASES_CANON <- c("A", "C", "G", "T")   # orden de las barras, fijo


# --- Conteo ----------------------------------------------------------------
#' Tabla de composición del genoma: una fila por carácter presente.
#'
#' Las cuatro canónicas van siempre en el orden A, C, G, T aunque alguna
#' faltara; cualquier carácter extra (N, códigos IUPAC ambiguos) se agrega
#' DESPUÉS, en orden alfabético, para que se vea que está ahí. Esconder una
#' columna de N sería justo el error que la práctica quiere enseñar a no
#' cometer.
#'
#' Nota: leer_fasta() aplica toupper(), así que este chequeo detecta ambigüedad
#' (N, R, Y…) pero no soft-masking. Ninguno de los seis genomas viene
#' enmascarado — está comprobado y documentado en _tema.R.
contar_bases <- function(secuencia) {
  tab <- table(strsplit(secuencia, "", fixed = TRUE)[[1]])

  extras <- setdiff(names(tab), BASES_CANON)
  orden  <- c(BASES_CANON, sort(extras))
  conteo <- as.integer(tab[orden])
  conteo[is.na(conteo)] <- 0L   # una canónica ausente vale 0, no NA

  data.frame(
    base       = factor(orden, levels = orden),
    conteo     = conteo,
    porcentaje = round(100 * conteo / sum(tab), 1),
    stringsAsFactors = FALSE
  )
}

#' Color por base: el par A/T en gris, el par C/G en azul, y cualquier carácter
#' inesperado en naranja para que salte a la vista.
color_de <- function(base) {
  ifelse(base %in% c("A", "T"), GRIS,
         ifelse(base %in% c("C", "G"), AZUL, NARANJA))
}


construir <- function(d) {
  # Las etiquetas van ENCIMA de las barras, así que el panel necesita techo
  # propio: con el expand por defecto el texto de la barra más alta se corta.
  # 12% sobre el máximo alcanza para una línea de texto a 2.8 pt de tamaño.
  techo <- max(d$conteo) * 1.12

  ggplot(d, aes(x = base, y = conteo, fill = base)) +
    geom_col(width = 0.68) +
    geom_text(aes(label = sprintf("%d (%.1f%%)", conteo, porcentaje)),
              vjust = -0.55, size = 2.8, colour = TEXTO) +
    scale_fill_manual(values = setNames(color_de(levels(d$base)),
                                        levels(d$base)),
                      guide = "none") +
    scale_y_continuous(labels = scales::label_number(scale = 1e-3,
                                                     suffix = " k"),
                       limits = c(0, techo),
                       expand = expansion(0)) +
    labs(x = NULL, y = "Número de bases",
         caption = "Fago lambda, NCBI NC_001416.1.") +
    tema_libro() +
    # El eje x es categórico: sus líneas de rejilla no marcan nada.
    theme(panel.grid.major.x = element_blank())
}


if (!interactive()) {
  seq <- leer_fasta(ruta_datos(paste0(GENOMA, ".fasta")))
  d   <- contar_bases(seq)

  extras <- setdiff(as.character(d$base), BASES_CANON)
  if (length(extras)) {
    warning(sprintf(paste("%s trae %d carácter(es) fuera de ACGT: %s.",
                          "Están graficados en naranja; revisar el FASTA."),
                    GENOMA, length(extras), paste(extras, collapse = ", ")),
            call. = FALSE)
  }

  n  <- setNames(d$conteo, as.character(d$base))
  gc <- n[["C"]] + n[["G"]]

  stopifnot(sum(d$conteo) == LARGO_ANCLA,   # el genoma completo
            gc == GC_ANCLA)                 # C + G, no el 24198 del capítulo

  message(sprintf("  %s: %d pb", GENOMA, sum(d$conteo)))
  message(sprintf("  A = %d  C = %d  G = %d  T = %d",
                  n[["A"]], n[["C"]], n[["G"]], n[["T"]]))
  message(sprintf("  GC = %d (%.1f%%)   AT = %d (%.1f%%)",
                  gc, 100 * gc / sum(d$conteo),
                  sum(d$conteo) - gc, 100 * (sum(d$conteo) - gc) / sum(d$conteo)))
  if (length(extras)) {
    message(sprintf("  ATENCIÓN: caracteres fuera de ACGT -> %s",
                    paste(sprintf("%s = %d", extras, n[extras]), collapse = ", ")))
  } else {
    message("  cero caracteres fuera de ACGT")
  }

  escribir_tsv(d, "composicion-lambda")
  guardar(construir(d), "composicion-lambda", 12, 8)
}
