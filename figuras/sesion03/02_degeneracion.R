## Fig. @fig-degeneracion (Sesión 3, § Degeneración)
## Cuántos codones tiene cada aminoácido en el código estándar.
##
## Los conteos NO están tecleados: salen de table() sobre la tabla 1 de
## Biostrings. El capítulo afirma un reparto concreto —tres aminoácidos con
## seis, cinco con cuatro, uno con tres, nueve con dos, dos con uno— y el
## stopifnot del final lo comprueba contra lo calculado. Si algún día cambia la
## tabla del NCBI, esta figura truena en vez de contradecir al texto en silencio.
##
## Sin título dentro del SVG: el caption vive en el .qmd.
##
## Regenerar:  Rscript figuras/sesion03/02_degeneracion.R

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


# --- Lo que afirma el capítulo ----------------------------------------------
# "Tres aminoácidos tienen seis codones cada uno: leucina, serina y arginina.
#  Cinco tienen cuatro (valina, prolina, treonina, alanina, glicina) y forman
#  las cajas donde la tercera posición da igual. Isoleucina es el único con
#  tres. Nueve tienen dos. Y dos aminoácidos tienen uno solo: metionina y
#  triptófano."
REPARTO_ESPERADO <- c(`1` = 2L, `2` = 9L, `3` = 1L, `4` = 5L, `6` = 3L)
SEIS_CODONES   <- c("L", "R", "S")
CUATRO_CODONES <- c("A", "G", "P", "T", "V")
UN_CODON       <- c("M", "W")     # los que el capítulo resalta: sin colchón


# --- Los datos --------------------------------------------------------------
d <- tabla_codigo("1")
d <- d[d$aa != "*", ]

conteo <- as.data.frame(table(d$aa), stringsAsFactors = FALSE)
names(conteo) <- c("aa", "n")
conteo$clase   <- unname(clases_aa[conteo$aa])
conteo$nombre  <- unname(nombres_aa[conteo$aa])
# Etiqueta del eje y: "L  Leu", como pedía la especificación.
conteo$etiqueta <- sprintf("%s  %s", conteo$aa, conteo$nombre)
conteo$solo     <- conteo$aa %in% UN_CODON

# Orden: de mayor a menor; a igual número de codones, alfabético por letra, para
# que el resultado sea estable entre corridas.
conteo <- conteo[order(-conteo$n, conteo$aa), ]
conteo$etiqueta <- factor(conteo$etiqueta, levels = rev(conteo$etiqueta))
conteo$clase    <- clase_ordenada(conteo$clase)

TECHO <- max(conteo$n) * 1.18     # sitio para la etiqueta al final de la barra

NOTA_SOLOS <- sprintf("%s tienen un solo codón: cualquier mutación los cambia",
                      paste(nombres_aa[UN_CODON], collapse = " y "))


construir <- function(d) {
  ggplot(d, aes(x = n, y = etiqueta, fill = clase)) +
    # Las barras de un solo codón llevan borde: son el punto del texto.
    geom_col(aes(colour = solo, linewidth = solo), width = 0.7) +
    geom_text(aes(label = n), hjust = -0.5, size = 2.7, colour = TEXTO) +
    # La anotación va en el hueco entre las dos últimas barras, que son M y W.
    # x = 1.35 la despega del extremo de esas barras (que valen 1) y a esa
    # altura no hay ninguna otra barra que alcance: queda un renglón limpio.
    annotate("text", x = 1.35, y = 1.5, label = NOTA_SOLOS, hjust = 0,
             size = 2.4, colour = TEXTO, family = familia_base()) +
    scale_fill_manual(values = colores_clase, name = NULL) +
    scale_colour_manual(values = c(`FALSE` = NA, `TRUE` = TEXTO), guide = "none") +
    scale_linewidth_manual(values = c(`FALSE` = 0, `TRUE` = 0.6), guide = "none") +
    scale_x_continuous(limits = c(0, TECHO), breaks = 0:6,
                       expand = expansion(0)) +
    labs(x = "Número de codones sinónimos", y = NULL) +
    tema_libro() +
    theme(axis.text.y = element_text(family = familia_mono(), hjust = 0),
          panel.grid.major.y = element_blank(),
          legend.position = "bottom",
          legend.margin = margin(t = 2)) +
    guides(fill = guide_legend(nrow = 1, byrow = TRUE,
                               override.aes = list(colour = NA, linewidth = 0)))
}


if (!interactive()) {
  reparto <- table(conteo$n)

  stopifnot(
    # --- Los datos ---
    nrow(conteo) == 20L,                       # los 20 aminoácidos
    sum(conteo$n) == 61L,                      # 61 codones con sentido
    !is.unsorted(rev(conteo$n)),               # ordenado de mayor a menor

    # --- El reparto que afirma el capítulo, categoría por categoría ---
    identical(as.integer(reparto[names(REPARTO_ESPERADO)]),
              unname(REPARTO_ESPERADO)),
    identical(sort(conteo$aa[conteo$n == 6L]), SEIS_CODONES),
    identical(sort(conteo$aa[conteo$n == 4L]), CUATRO_CODONES),
    identical(sort(conteo$aa[conteo$n == 1L]), UN_CODON),
    identical(conteo$aa[conteo$n == 3L], "I"),  # isoleucina, el único con tres
    sum(conteo$solo) == 2L,

    # --- Los cinco de cuatro codones son las cajas de tercera posición libre ---
    # (que es lo que dice el capítulo al presentarlos)
    all(vapply(CUATRO_CODONES, function(a) {
      cs <- d$codon[d$aa == a]
      length(unique(substr(cs, 1, 2))) == 1L    # comparten las dos primeras bases
    }, logical(1)))
  )

  message("  codones por aminoácido (tabla 1):")
  for (i in seq_len(nrow(conteo))) {
    message(sprintf("    %-8s %d%s", conteo$etiqueta[i], conteo$n[i],
                    if (conteo$solo[i]) "   <- un solo codón" else ""))
  }
  message(sprintf("  reparto: %s",
                  paste(sprintf("%s aa con %s codones", reparto, names(reparto)),
                        collapse = ", ")))
  message(sprintf("  total de codones con sentido: %d", sum(conteo$n)))

  escribir_tsv(conteo[, c("aa", "nombre", "n", "clase")], "degeneracion")
  guardar(construir(conteo), "degeneracion", 14, 12)
}
