## Fig. @fig-gc-genomas (Sesión 5, Ejercicio 9)
## Contenido de GC en los seis genomas de la práctica.
##
## NADA está tecleado: longitudes y GC se calculan de los FASTA con Biostrings.
## Las longitudes que cita la tabla del capítulo quedan como ANCLAS en
## LARGOS_CAPITULO, y el stopifnot truena si alguna no cuadra. Es el chequeo que
## pedía la especificación.
##
## letterFrequency(x, "GC") cuenta mayúsculas Y minúsculas, que es la costumbre
## que el ejercicio 3 pide agarrar. Ninguno de estos seis viene enmascarado
## (comprobado), así que aquí da igual; el día que toque un eucarionte, no.
##
## Sin título dentro del SVG: el caption vive en el .qmd.
##
## Regenerar:  bash figuras/sesion05/00_datos.sh   # una vez
##             Rscript figuras/sesion05/03_gc_genomas.R

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


# --- Los seis genomas -------------------------------------------------------
genomas <- c(
  "Mycoplasma genitalium" = "NC_000908.2",
  "SARS-CoV-2"            = "NC_045512.2",
  "Levadura, cromosoma I" = "NC_001133.9",
  "Fago phiX174"          = "NC_001422.1",
  "Fago lambda"           = "NC_001416.1",
  "Escherichia coli K-12" = "NC_000913.3"
)

# La tabla del Ejercicio 9. Son anclas, no insumos: la figura usa lo calculado.
LARGOS_CAPITULO <- c(NC_001422.1 = 5386L, NC_045512.2 = 29903L,
                     NC_001416.1 = 48502L, NC_001133.9 = 230218L,
                     NC_000908.2 = 580076L, NC_000913.3 = 4641652L)

# El GC que cita la solución del ejercicio, para cotejar.
GC_CAPITULO <- c(NC_000908.2 = 31.7, NC_045512.2 = 38.0,
                 NC_001416.1 = 49.9, NC_000913.3 = 50.8)

DESTACADO <- "NC_001416.1"        # lambda, el genoma del capítulo


# --- Cálculo ----------------------------------------------------------------
#' ¿Viene soft-masked? Cuenta minúsculas en las líneas de secuencia.
#'
#' Hay que mirar el ARCHIVO, no el DNAString: al leer, Biostrings normaliza a
#' mayúsculas (el alfabeto de DNAString sólo tiene mayúsculas), así que el
#' soft-masking se pierde y desde el objeto es indetectable.
#'
#' Vale la pena entender qué implica eso, porque es justo el archivo 5 del
#' ejercicio 5: leer con Biostrings hace lo CORRECTO con un genoma enmascarado
#' —cuenta todas las bases— mientras que `tr -cd 'GC'` en la terminal descarta
#' las minúsculas en silencio. La biblioteca acierta donde el pipeline falla.
minusculas_en <- function(ruta) {
  l <- readLines(ruta, warn = FALSE)
  sum(vapply(gregexpr("[acgtn]", l[!grepl("^>", l)]),
             function(m) if (m[1] == -1L) 0L else length(m), integer(1)))
}

d <- do.call(rbind, lapply(seq_along(genomas), function(i) {
  s <- leer_genoma(genomas[i])
  data.frame(
    nombre = names(genomas)[i],
    accession = unname(genomas[i]),
    largo = length(s),
    gc = gc_pct(s),
    minusculas = minusculas_en(ruta_fasta(genomas[i])),
    stringsAsFactors = FALSE
  )
}))

d <- d[order(d$gc), ]
d$destacado <- d$accession == DESTACADO
d$etiqueta  <- sprintf("%s (%s)", d$nombre, fmt_largo(d$largo))
d$etiqueta  <- factor(d$etiqueta, levels = d$etiqueta)

TECHO <- max(d$gc) * 1.16


construir <- function(d) {
  ggplot(d, aes(x = gc, y = etiqueta, fill = destacado)) +
    geom_col(width = 0.66) +
    geom_text(aes(label = sprintf("%.1f %%", gc), colour = destacado),
              hjust = -0.18, size = 2.7, show.legend = FALSE) +
    scale_fill_manual(values = c(`FALSE` = AZUL, `TRUE` = NARANJA),
                      guide = "none") +
    scale_colour_manual(values = c(`FALSE` = TEXTO, `TRUE` = NARANJA),
                        guide = "none") +
    scale_x_continuous(limits = c(0, TECHO), expand = expansion(0),
                       breaks = seq(0, 50, 10)) +
    labs(x = "Contenido de GC (%)", y = NULL,
         caption = "Calculado de las secuencias RefSeq indicadas.") +
    tema_libro() +
    theme(panel.grid.major.y = element_blank())
}


if (!interactive()) {
  d$esperado <- LARGOS_CAPITULO[d$accession]
  cuadra <- d$largo == d$esperado

  stopifnot(
    # --- Los datos ---
    nrow(d) == 6L,
    !anyNA(d$esperado),
    # el chequeo que pedía la especificación: las seis longitudes
    all(cuadra),
    !is.unsorted(d$gc),                    # ordenadas de menor a mayor
    sum(d$destacado) == 1L,
    all(d$gc > 25 & d$gc < 60),

    # --- Lo que afirma la solución del ejercicio 9 ---
    all(abs(d$gc[match(names(GC_CAPITULO), d$accession)] - GC_CAPITULO) < 0.1),
    # "el rango va de Mycoplasma a E. coli"
    d$accession[1] == "NC_000908.2",
    d$accession[nrow(d)] == "NC_000913.3",

    # --- Ninguno viene enmascarado ---
    all(d$minusculas == 0)
  )

  message("  seis genomas, calculados de los FASTA:")
  for (i in seq_len(nrow(d))) {
    message(sprintf("    %-24s %-13s %9s pb   GC %5.2f %%   %s",
                    d$nombre[i], d$accession[i],
                    format(d$largo[i], big.mark = ","), d$gc[i],
                    ifelse(cuadra[i], "longitud ok", "<<< NO CUADRA")))
  }
  message(sprintf("  rango de GC: %.2f %% a %.2f %%", min(d$gc), max(d$gc)))
  message("  ninguno viene soft-masked (cero minúsculas en los seis)")

  escribir_tsv(d[, c("nombre", "accession", "largo", "gc")], "gc-genomas")
  guardar(construir(d), "gc-genomas", 16, 9)
}
