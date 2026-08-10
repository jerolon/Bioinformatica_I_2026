## Fig. @fig-gc-genomas (Sesión 01, práctica) — Contenido de GC de seis genomas,
## calculado de los FASTA que el alumno acaba de bajar a datos/.
##
## El punto pedagógico: el GC no es una constante de la vida. Va de ~32 % en un
## patógeno de genoma reducido a ~51 % en E. coli, y el fago lambda del capítulo
## (naranja) cae justo en medio. Nada de esto se cita de una tabla: sale de
## contar C y G en los mismos archivos de la práctica.
##
## Sin título dentro del SVG: el caption vive en el .qmd.
##
## Regenerar:  Rscript figuras/sesion01/05_gc_genomas.R

# `_tema.R` vive junto a este script; se ubica el archivo para que
# `Rscript figuras/sesion01/<script>.R` corra desde la raíz del repo.
.ubicar <- function() {
  # Si el script se corrió con source(), el path correcto es el `ofile` que
  # source() deja en su frame; commandArgs("--file=") apuntaría al script de
  # AFUERA. Por eso se busca el ofile primero, de adentro hacia afuera.
  for (i in rev(seq_len(sys.nframe()))) {
    o <- sys.frame(i)$ofile
    if (!is.null(o)) return(normalizePath(o, winslash = "/"))
  }
  a <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1]), winslash = "/"))
  stop("no se pudo ubicar el script: correr con Rscript o con source()")
}
source(file.path(dirname(.ubicar()), "_tema.R"))

# --- Los seis genomas -------------------------------------------------------
# Nombre que se dibuja -> accession de RefSeq. El orden de este vector no
# importa: la figura reordena por GC.
#
# NOTA: NC_000908.2 llega del NCBI con el nombre "Mycoplasmoides genitalium
# G37". El género se renombró (Mycoplasma -> Mycoplasmoides) después de que el
# capítulo se escribió. La etiqueta usa el nombre del capítulo para que figura y
# texto digan lo mismo; si algún día se actualiza el capítulo, se actualizan los
# dos a la vez.
genomas <- c(
  "Mycoplasma genitalium"  = "NC_000908.2",
  "SARS-CoV-2"             = "NC_045512.2",
  "Fago phiX174"           = "NC_001422.1",
  "Levadura, cromosoma I"  = "NC_001133.9",
  "Fago lambda"            = "NC_001416.1",
  "Escherichia coli K-12"  = "NC_000913.3"
)

DESTACADO <- "NC_001416.1"   # lambda: el genoma del capítulo, va en naranja

# --- Anclas -----------------------------------------------------------------
# Medidas sobre los FASTA reales de datos/ (grep -v '^>' | tr -d | wc -c).
# No alimentan la figura: sólo sirven para que el script truene si un FASTA se
# bajó truncado o si el NCBI publicó una versión nueva del ensamble.
LONG_REF <- c("NC_001416.1" =   48502, "NC_001422.1" =    5386,
              "NC_045512.2" =   29903, "NC_000908.2" =  580076,
              "NC_000913.3" = 4641652, "NC_001133.9" =  230218)
GC_REF   <- c("NC_001416.1" = 49.86, "NC_001422.1" = 44.76,
              "NC_045512.2" = 37.97, "NC_000908.2" = 31.69,
              "NC_000913.3" = 50.79, "NC_001133.9" = 39.27)
TOL_GC   <- 0.05   # puntos porcentuales


#' Composición de un FASTA de un solo registro.
#'
#' Se cuenta con table() sobre los caracteres y no con un gsub("[^GC]", "")
#' porque así queda contado, de paso, lo que NO es ACGT. Importa: si un genoma
#' trajera N (los ensambles con huecos los traen), el GC sobre la longitud total
#' quedaría sesgado hacia abajo y la figura no lo delataría. Ninguno de estos
#' seis los trae, y el bloque final lo comprueba en vez de suponerlo.
componer <- function(acc) {
  s <- leer_fasta(ruta_datos(paste0(acc, ".fasta")))
  n <- table(strsplit(s, "", fixed = TRUE)[[1]])
  cuenta <- function(b) if (b %in% names(n)) as.integer(n[[b]]) else 0L
  acgt <- vapply(c("A", "C", "G", "T"), cuenta, integer(1))
  data.frame(
    accession = acc,
    longitud  = nchar(s),
    gc        = acgt[["C"]] + acgt[["G"]],
    otras     = nchar(s) - sum(acgt),
    stringsAsFactors = FALSE
  )
}


#' Tamaño de genoma en la unidad que lo deja legible.
#'
#' En pb crudos un "4641652" junto a un "5386" no se compara de un vistazo; el
#' orden de magnitud sí. El corte en 100 kb es para no gastar un decimal donde
#' no aporta (580 kb) ni perderlo donde sí (5.4 kb).
fmt_tamano <- function(pb) {
  vapply(pb, function(x) {
    if (x >= 1e6) return(sprintf("%.1f Mb", x / 1e6))
    if (x >= 1e5) return(sprintf("%.0f kb", x / 1e3))
    sprintf("%.1f kb", x / 1e3)
  }, character(1))
}


calcular <- function() {
  d <- do.call(rbind, lapply(genomas, componer))
  d$nombre  <- names(genomas)
  d$gc_pct  <- 100 * d$gc / d$longitud
  d         <- d[order(d$gc_pct), ]           # ascendente: así sale también el .tsv
  d$etiqueta <- sprintf("%s (%s)", d$nombre, fmt_tamano(d$longitud))
  d$color    <- ifelse(d$accession == DESTACADO, NARANJA, AZUL)
  rownames(d) <- NULL
  d
}


construir <- function(d) {
  # El nivel 1 de un factor cae ABAJO en el eje y de ggplot. Se invierte el
  # orden ascendente para que la figura se lea de menor a mayor GC en el sentido
  # en que se lee todo lo demás: de arriba hacia abajo.
  d$etiqueta <- factor(d$etiqueta, levels = rev(d$etiqueta))

  ggplot(d, aes(x = gc_pct, y = etiqueta, fill = color)) +
    geom_col(width = 0.68) +
    geom_text(aes(label = sprintf("%.1f%%", gc_pct)),
              hjust = 0, nudge_x = 0.7, size = 3.1, colour = TEXTO) +
    # El color ya viene resuelto en la columna: no hay categoría que mapear ni
    # leyenda que esconder.
    scale_fill_identity() +
    # Sin holgura a la izquierda (las barras nacen en cero, que es el origen
    # honesto para un porcentaje) y 13 % a la derecha para las etiquetas.
    scale_x_continuous(expand = expansion(mult = c(0, 0.13))) +
    labs(x = "Contenido de GC (%)", y = NULL,
         caption = "Calculado de las secuencias RefSeq indicadas. Fecha de descarga en datos/.") +
    tema_libro() +
    theme(panel.grid.major.y = element_blank(),
          axis.line.y  = element_blank(),
          axis.ticks.y = element_blank(),
          plot.margin  = margin(4, 8, 4, 4))
}


if (!interactive()) {
  d <- calcular()

  stopifnot(
    "faltan genomas o hay repetidos" =
      nrow(d) == length(genomas) && !anyDuplicated(d$accession),
    "alguna longitud no cuadra con la verdad de campo" =
      all(d$longitud == LONG_REF[d$accession]),
    "algún GC se desvía más de la tolerancia" =
      all(abs(d$gc_pct - GC_REF[d$accession]) <= TOL_GC),
    "llegó al menos un carácter fuera de ACGT" = all(d$otras == 0),
    "las barras no quedaron ordenadas por GC" = !is.unsorted(d$gc_pct),
    "lambda no está entre los genomas graficados" = DESTACADO %in% d$accession
  )

  message("  GC contado sobre datos/*.fasta (C+G / longitud):")
  for (i in seq_len(nrow(d))) {
    message(sprintf("  %-22s %-12s %9d pb   GC %5.2f %%   (ref %5.2f)",
                    d$nombre[i], d$accession[i], d$longitud[i],
                    d$gc_pct[i], GC_REF[d$accession[i]]))
  }
  message(sprintf("  rango de GC: %.1f %% a %.1f %% (%.1f puntos de diferencia)",
                  min(d$gc_pct), max(d$gc_pct), max(d$gc_pct) - min(d$gc_pct)))

  # Dos decimales en el .tsv, no uno: es el archivo con el que se coteja la
  # figura contra el texto del capítulo, y a una cifra no se distinguiría un
  # 49.86 de un 49.9 mal redondeado.
  escribir_tsv(data.frame(nombre    = d$nombre,
                          accession = d$accession,
                          longitud  = d$longitud,
                          gc_pct    = round(d$gc_pct, 2)),
               "gc-genomas")

  # El nombre de salida es el de la FIGURA, no el del script: el .qmd la incrusta
  # como figuras/sesion01/gc-genomas.svg.
  guardar(construir(d), "gc-genomas", 16, 9)
}
