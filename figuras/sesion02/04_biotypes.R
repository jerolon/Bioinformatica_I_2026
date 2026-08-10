## Fig. @fig-biotypes (Sesión 2-3, § Ponerle nombre a los tipos)
## Genes humanos anotados por biotype, en barras horizontales.
##
## El punto pedagógico es el contraste: los genes codificantes de proteína NO
## son la mayoría. Por eso su barra va en naranja y las demás en azul, y por eso
## el orden es de mayor a menor y no el orden "natural" que uno esperaría (los
## codificantes primero).
##
## ---------------------------------------------------------------------------
## RELEASE
##
## Las cifras son de GENCODE Release 48 (GRCh38), y coinciden EXACTAMENTE con
## las del cuerpo del capítulo (verificado contra
## https://www.gencodegenes.org/human/stats_48.html).
##
## Al 5 de agosto de 2026 el release vigente ya es el 50, con cifras distintas:
##
##     categoría                    v48       v50
##     genes totales             78,686    78,733
##     codificantes de proteína  19,435    19,442
##     lncRNA                    35,901    35,885
##     pseudogenes procesados    10,643    10,634
##     RNA pequeños               7,563     7,608
##     pseudogenes no procesados  3,549     3,535
##     pseudogenes unitarios        266       296
##     transcritos totales      385,669   644,292
##
## No se actualiza porque el capítulo cita v48 en el texto corrido y en el
## Ejercicio 6. Figura y texto tienen que decir lo mismo; si se pasa a v50 hay
## que cambiar los dos a la vez. Las cifras de v50 están abajo, comentadas, para
## que el cambio sea una edición y no una investigación.
## ---------------------------------------------------------------------------
##
## Sin título dentro del SVG: el caption vive en el .qmd.
##
## Regenerar:  Rscript figuras/sesion02/04_biotypes.R

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


# --- Los datos --------------------------------------------------------------
# GENCODE Release 48 (GRCh38). Ver la nota de arriba sobre el release vigente.
biotypes <- data.frame(
  clase = c("lncRNA", "Codificantes de proteína", "Pseudogenes procesados",
            "RNA pequeños no codificantes", "Pseudogenes no procesados",
            "Segmentos IG/TR codificantes", "Pseudogenes unitarios"),
  n     = c(35901, 19435, 10643, 7563, 3549, 412, 266),
  stringsAsFactors = FALSE
)
release <- "GENCODE v48 (GRCh38)"

# Release 50, para el día que se actualice el capítulo:
#   n <- c(35885, 19442, 10634, 7608, 3535, 412, 296)
#   release <- "GENCODE v50 (GRCh38)"

DESTACADA <- "Codificantes de proteína"

# Anclas del capítulo, para que stopifnot truene si alguien edita una cifra en
# un lado y no en el otro.
TOTAL_GENES     <- 78686L   # "hay 78,686 genes anotados en el humano"
PSEUDOGENES     <- 14695L   # "14,695 son pseudogenes"
TRANSCRITOS     <- 385669L  # "los transcritos totales son 385,669"

# OJO con esta cifra: no está graficada y hace falta para cuadrar la anterior.
# El total de pseudogenes de GENCODE (14,695) NO es la suma de los tres tipos
# que enumera el capítulo:
#     10,643 + 3,549 + 266 = 14,458,  faltan 237
# Los 237 que faltan son los pseudogenes de segmentos IG/TR, que GENCODE lista
# en un renglón aparte (junto a los 412 codificantes, ésos sí graficados).
# O sea que la lista del capítulo es correcta pero no exhaustiva: son los tres
# tipos que importan conceptualmente, no las cuatro categorías del release.
PSEUDOGENES_IGTR <- 237L


# --- Preparación ------------------------------------------------------------
biotypes <- biotypes[order(biotypes$n, decreasing = TRUE), ]
biotypes$clase <- factor(biotypes$clase, levels = rev(biotypes$clase))
biotypes$destacada <- as.character(biotypes$clase) == DESTACADA
biotypes$etiqueta  <- miles(biotypes$n)

# Techo del eje: las etiquetas van al final de cada barra y necesitan sitio.
# 14 % sobre el máximo alcanza para "35,901" a 2.8 pt.
TECHO <- max(biotypes$n) * 1.14


construir <- function(d) {
  ggplot(d, aes(x = n, y = clase, fill = destacada)) +
    geom_col(width = 0.66) +
    geom_text(aes(label = etiqueta, colour = destacada),
              hjust = -0.18, size = 2.8, show.legend = FALSE) +
    scale_fill_manual(values = c(`FALSE` = AZUL, `TRUE` = NARANJA),
                      guide = "none") +
    scale_colour_manual(values = c(`FALSE` = TEXTO, `TRUE` = NARANJA),
                        guide = "none") +
    scale_x_continuous(labels = fmt_conteo, limits = c(0, TECHO),
                       expand = expansion(0)) +
    labs(x = "Número de genes anotados", y = NULL,
         caption = paste0("Fuente: ", release,
                          ". Las cifras cambian en cada release.")) +
    tema_libro() +
    # El eje y es categórico: sus líneas de rejilla no marcan nada.
    theme(panel.grid.major.y = element_blank())
}


if (!interactive()) {
  d <- biotypes

  n <- setNames(d$n, as.character(d$clase))
  # Los tres tipos que enumera el capítulo...
  pseudogenes_3 <- n[["Pseudogenes procesados"]] + n[["Pseudogenes no procesados"]] +
                   n[["Pseudogenes unitarios"]]
  # ...más los de IG/TR, que es lo que da el total del release.
  pseudogenes <- pseudogenes_3 + PSEUDOGENES_IGTR

  stopifnot(
    # --- Los datos ---
    nrow(d) == 7L,
    all(d$n > 0),
    !is.unsorted(rev(d$n)),                  # ordenadas de mayor a menor
    sum(d$destacada) == 1L,                  # exactamente una barra en naranja

    # --- Lo que el capítulo afirma sobre esta tabla ---
    # "hay casi el doble de genes de lncRNA" que de codificantes
    n[["lncRNA"]] > 1.8 * n[["Codificantes de proteína"]],
    # "casi tantos pseudogenes como genes codificantes"
    pseudogenes == PSEUDOGENES,
    abs(pseudogenes - n[["Codificantes de proteína"]]) < 0.3 * n[["Codificantes de proteína"]],
    # y los codificantes NO son la categoría más grande
    which.max(d$n) != which(d$destacada),

    # --- Las etiquetas caben ---
    TECHO > max(d$n),
    grepl(",", d$etiqueta[which.max(d$n)], fixed = TRUE)   # separador de miles
  )

  # El total del capítulo (78,686) no es la suma de estas siete categorías:
  # GENCODE cuenta aparte los pseudogenes de segmentos IG/TR (237) y algunas
  # clases residuales. Se reporta la diferencia en vez de esconderla.
  message(sprintf("  %s", release))
  for (i in seq_len(nrow(d))) {
    message(sprintf("    %-30s %8s%s", d$clase[i], d$etiqueta[i],
                    if (d$destacada[i]) "   <- naranja" else ""))
  }
  message(sprintf("  suma de las 7 categorías graficadas: %s", miles(sum(d$n))))
  message(sprintf("  + pseudogenes IG/TR (no graficados): %s  ->  %s",
                  miles(PSEUDOGENES_IGTR), miles(sum(d$n) + PSEUDOGENES_IGTR)))
  message(sprintf("  total de genes que cita el capítulo: %s  (faltan %s en clases residuales)",
                  miles(TOTAL_GENES),
                  miles(TOTAL_GENES - sum(d$n) - PSEUDOGENES_IGTR)))
  message(sprintf("  pseudogenes: %s (los 3 tipos del capítulo) + %s (IG/TR) = %s",
                  miles(pseudogenes_3), miles(PSEUDOGENES_IGTR), miles(pseudogenes)))
  message(sprintf("  lncRNA / codificantes = %.2f",
                  n[["lncRNA"]] / n[["Codificantes de proteína"]]))
  message(sprintf("  transcritos totales del release (no graficados): %s",
                  miles(TRANSCRITOS)))

  escribir_tsv(
    data.frame(clase = as.character(d$clase), n = d$n, release = release,
               stringsAsFactors = FALSE),
    "genes-por-biotype")
  guardar(construir(d), "genes-por-biotype", 16, 9)
}
