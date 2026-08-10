## Fig. @fig-grantham (Sesión 4, § Cobrando la promesa)
## BLOSUM62 contra la distancia de Grantham, para los 190 pares distintos.
##
## Es la figura que abre el capítulo y la que cobra la promesa de la sesión
## anterior: los números de la matriz no son arbitrarios.
##
## ---------------------------------------------------------------------------
## DE DÓNDE SALEN LOS DOS EJES
##
## BLOSUM62: `data(BLOSUM62)` de Biostrings. No se transcribe: son 400 números.
## Grantham: paquete `grantham` (CRAN), objeto `grantham_distances_matrix`, que
## es la tabla original de Grantham 1974. No hizo falta bajar ninguna tabla.
##
## Los 20 canónicos se sacan con aminoacidos_canonicos(), que quita también la
## **J**; ver la nota en _tema.R (con J son 21 y la diagonal deja de ir de +4 a
## +11).
## ---------------------------------------------------------------------------
##
## POR QUÉ 190 PARES Y NO 210
##
## Se excluye la diagonal. Una identidad no es una sustitución, y Grantham vale
## 0 para las veinte, así que incluirlas mete un grumo de puntos en x = 0 con y
## alta que infla la correlación sin agregar información: con diagonal r pasa de
## -0.66 a -0.75. La especificación pedía "los 190 pares distintos" y es lo
## correcto, pero conviene saber que ahí está buena parte de la diferencia con
## el -0.72 que citaba el capítulo. Ver FIGURAS.md.
##
## Sin título dentro del SVG: el caption vive en el .qmd.
##
## Regenerar:  Rscript figuras/sesion04/01_blosum_grantham.R

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

suppressPackageStartupMessages(library(grantham))
suppressPackageStartupMessages(library(ggrepel))


# --- Los datos --------------------------------------------------------------
M <- blosum62()
d <- pares_aa(M)

# Grantham 1974, del paquete. Se pasa a código de una letra para poder cruzarlo
# con BLOSUM62.
G <- grantham::grantham_distances_matrix
dimnames(G) <- list(grantham::as_one_letter(rownames(G)),
                    grantham::as_one_letter(colnames(G)))
G <- G[rownames(M), colnames(M)]

d$grantham <- mapply(function(i, j) G[i, j], d$aa1, d$aa2)
d$par <- paste0(d$aa1, "/", d$aa2)

R_PEARSON  <- cor(d$grantham, d$blosum)
R_SPEARMAN <- cor(d$grantham, d$blosum, method = "spearman")

# La especificación pedía parar si el coeficiente no sale cerca de -0.7. Sale
# -0.66, que redondea a -0.7 pero NO es el -0.72 que citaba el capítulo (ese
# valor corresponde a incluir la diagonal, o a BLOSUM50/PAM250). Se avisó, se
# corrigió el capítulo, y acá queda la cota que impide que pase inadvertido si
# alguien cambia la fuente de una de las dos medidas.
if (!(R_PEARSON > -0.80 && R_PEARSON < -0.55)) {
  stop(sprintf(paste("La correlación salió %.3f, fuera del rango esperado",
                     "(-0.80, -0.55).\nAlgo cambió en BLOSUM62 o en la tabla de",
                     "Grantham: revisar antes de regenerar."), R_PEARSON),
       call. = FALSE)
}


# --- Etiquetas --------------------------------------------------------------
# Cinco y no más: con más, ggrepel empieza a tirar líneas largas y la nube deja
# de leerse. Las cinco están elegidas para que cada una diga algo distinto y
# para que tres de ellas aparezcan también en el texto del capítulo.
ETIQUETAS <- c(
  "I/L",   # el conservativo clásico: la distancia de Grantham MÍNIMA (5)
  "E/K",   # el que rompe la intuición: cargas opuestas y score positivo
  "D/L",   # el ejemplo del capítulo: alifático contra ácido, el peor score
  "C/W",   # la distancia de Grantham MÁXIMA (215)
  "A/C"    # el que más se sale de la recta: muy distante y sin embargo neutro
)
d$etiqueta <- ifelse(d$par %in% ETIQUETAS, d$par, NA_character_)

# --- Recta y anotación ------------------------------------------------------
ajuste <- lm(blosum ~ grantham, data = d)

TXT_R <- sprintf("r de Pearson = %.2f", R_PEARSON)
TXT_N <- sprintf("%d pares  ·  R² = %.2f", nrow(d), summary(ajuste)$r.squared)


construir <- function(d) {
  ggplot(d, aes(x = grantham, y = blosum)) +
    geom_hline(yintercept = 0, colour = GRIS, linewidth = 0.3,
               linetype = "dashed") +
    geom_smooth(method = "lm", se = FALSE, colour = AZUL, linewidth = 0.6,
                formula = y ~ x) +
    geom_point(aes(colour = misma_clase), size = 1.4, alpha = 0.8) +
    ggrepel::geom_text_repel(
      aes(label = etiqueta), na.rm = TRUE, size = 2.4, colour = TEXTO,
      family = familia_base(), min.segment.length = 0, segment.colour = GRIS,
      segment.size = 0.3, box.padding = 0.5, seed = 7) +
    annotate("text", x = Inf, y = Inf, label = paste(TXT_R, TXT_N, sep = "\n"),
             hjust = 1.05, vjust = 1.3, size = 2.6, colour = TEXTO,
             family = familia_base(), lineheight = 1.1) +
    scale_colour_manual(
      values = c(`TRUE` = NARANJA, `FALSE` = alpha(GRIS, 0.75)),
      labels = c(`TRUE` = "misma clase química", `FALSE` = "clases distintas"),
      breaks = c("TRUE", "FALSE"), name = NULL) +
    scale_y_continuous(breaks = seq(-4, 4, 2)) +
    labs(x = "Distancia de Grantham (diferencia fisicoquímica)",
         y = "Score de BLOSUM62",
         caption = paste("190 pares de aminoácidos. Grantham (1974);",
                         "BLOSUM62 (Henikoff & Henikoff, 1992).")) +
    tema_libro() +
    theme(legend.position = "bottom", legend.margin = margin(t = 0))
}


if (!interactive()) {
  faltantes <- setdiff(ETIQUETAS, d$par)

  stopifnot(
    # --- Los datos ---
    nrow(M) == 20L, ncol(M) == 20L,
    isSymmetric(M),
    !any(rownames(M) %in% AMBIGUOS),        # ni B, ni Z, ni X, ni J
    nrow(d) == 190L,                        # los pares distintos, sin diagonal
    !any(d$aa1 == d$aa2),
    all(d$grantham > 0),                    # sin diagonal, ninguna es 0
    isSymmetric(G), all(diag(G) == 0),

    # --- Lo que el capítulo afirma sobre la diagonal ---
    min(diag(M)) == 4L, max(diag(M)) == 11L,

    # --- La correlación ---
    R_PEARSON < 0,                          # negativa, como debe
    coef(ajuste)[["grantham"]] < 0,         # y la recta baja
    length(faltantes) == 0L,                # las cinco etiquetas existen
    length(ETIQUETAS) <= 5L
  )

  message(sprintf("  BLOSUM62: %d x %d ; diagonal de %+d a %+d",
                  nrow(M), ncol(M), min(diag(M)), max(diag(M))))
  message(sprintf("  %d pares distintos; Grantham de %g a %g; BLOSUM de %+d a %+d",
                  nrow(d), min(d$grantham), max(d$grantham),
                  min(d$blosum), max(d$blosum)))
  message("")
  message(sprintf("  *** Pearson  r = %+.4f   (el capítulo decía ~ -0.72)", R_PEARSON))
  message(sprintf("  *** Spearman r = %+.4f", R_SPEARMAN))
  message(sprintf("      R^2 = %.3f ; pendiente = %.4f score por unidad Grantham",
                  summary(ajuste)$r.squared, coef(ajuste)[["grantham"]]))
  message("")
  message("  Para referencia, con otras convenciones:")
  M210 <- M
  idx <- which(upper.tri(M210, diag = TRUE), arr.ind = TRUE)
  r210 <- cor(G[idx], M210[idx])
  message(sprintf("      incluyendo la diagonal (210 pares): r = %+.4f", r210))
  sin_c <- subset(d, aa1 != "C" & aa2 != "C")
  message(sprintf("      sin cisteína (%d pares):            r = %+.4f",
                  nrow(sin_c), cor(sin_c$grantham, sin_c$blosum)))
  message("")
  message(sprintf("  pares intra-clase: %d de %d (%.0f %%)",
                  sum(d$misma_clase), nrow(d), 100 * mean(d$misma_clase)))
  message("  etiquetados:")
  for (e in ETIQUETAS) {
    q <- d[d$par == e, ]
    message(sprintf("    %-5s BLOSUM %+2d  Grantham %3g", q$par, q$blosum, q$grantham))
  }

  escribir_tsv(d[, c("aa1", "aa2", "blosum", "grantham", "misma_clase")],
               "blosum-grantham")
  guardar(construir(d), "blosum-grantham", 16, 11)
}
