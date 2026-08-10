## Fig. @fig-entropia (Sesión 4, § Escoger matriz)
## Entropía relativa de la serie BLOSUM y su consecuencia práctica.
##
## ---------------------------------------------------------------------------
## DE DÓNDE SALEN LAS ENTROPÍAS, Y POR QUÉ NO SE RECALCULAN
##
## Son los valores que publica el NCBI para BLAST (los mismos que cita la tabla
## del capítulo). NO se recalculan desde la matriz, y conviene decir por qué,
## porque la tentación es fuerte y el resultado sería peor:
##
## La entropía relativa es H = sum_ij q_ij * S_ij, y las q_ij —las frecuencias
## objetivo con que se construyó la matriz— no vienen con la matriz. Se pueden
## reconstruir resolviendo lambda en sum p_i p_j exp(lambda S_ij) = 1 y
## poniendo q_ij = p_i p_j exp(lambda S_ij), pero eso exige elegir un vector de
## fondo p_i y usar los scores YA REDONDEADOS a enteros. Se hizo, con las
## frecuencias de Robinson & Robinson (1991) que usa BLAST:
##
##     matriz      lambda calculado   H calculada   H publicada
##     BLOSUM45        0.2291           0.363          0.3795
##     BLOSUM62        0.3176           0.579          0.6979
##     BLOSUM80        0.3430           0.948          0.9868
##
## El lambda de BLOSUM62 cae EXACTO en el 0.3176 publicado, o sea que el montaje
## es correcto; la H se queda corta entre 0.02 y 0.12 bits porque el redondeo a
## enteros y el vector de fondo no son los originales de los Henikoff. Publicar
## esa H sería reportar una peor estimación de la misma cantidad. Así que se usan
## las cifras del NCBI y la reconstrucción queda como verificación, en la
## función `lambda_verificado()` de abajo, que corre en cada regeneración.
##
## (Biostrings no trae BLOSUM90, así que ésa no se puede ni verificar.)
## ---------------------------------------------------------------------------
##
## Sin título dentro del SVG: el caption vive en el .qmd.
##
## Regenerar:  Rscript figuras/sesion04/04_entropia.R

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

suppressPackageStartupMessages(library(patchwork))


# --- Los datos --------------------------------------------------------------
# Entropía relativa en bits por posición, según el NCBI (parámetros de blastp).
# Coinciden con la tabla del capítulo redondeadas a dos decimales.
entropia <- data.frame(
  matriz = c("BLOSUM45", "BLOSUM62", "BLOSUM80", "BLOSUM90"),
  bits   = c(0.3795, 0.6979, 0.9868, 1.1806),
  stringsAsFactors = FALSE
)

# El umbral es ilustrativo: 50 bits es el orden de magnitud que se suele citar
# para que un alineamiento sea significativo en una base de datos grande.
BITS_OBJETIVO <- 50

entropia$residuos <- BITS_OBJETIVO / entropia$bits
entropia$destacada <- entropia$matriz == "BLOSUM62"   # el default de BLAST
entropia$matriz <- factor(entropia$matriz, levels = entropia$matriz)


# --- Verificación: lambda reconstruido --------------------------------------
# Frecuencias de fondo de Robinson & Robinson (1991), las que usa BLAST.
P_FONDO <- c(A=0.07805, R=0.05129, N=0.04487, D=0.05364, C=0.01925, Q=0.04264,
             E=0.06295, G=0.07377, H=0.02199, I=0.05142, L=0.09019, K=0.05744,
             M=0.02243, F=0.03856, P=0.05203, S=0.07120, T=0.05841, W=0.01330,
             Y=0.03216, V=0.06441)
P_FONDO <- P_FONDO / sum(P_FONDO)

#' lambda de Karlin & Altschul: la raíz de sum_ij p_i p_j exp(l S_ij) = 1.
lambda_verificado <- function(nombre) {
  M <- try(get(utils::data(list = nombre, package = "Biostrings",
                           envir = environment())), silent = TRUE)
  if (inherits(M, "try-error")) return(NA_real_)
  aa <- names(P_FONDO)
  if (!all(aa %in% rownames(M))) return(NA_real_)
  S <- M[aa, aa]; pp <- outer(P_FONDO, P_FONDO)
  uniroot(function(l) sum(pp * exp(l * S)) - 1, c(1e-6, 3), tol = 1e-12)$root
}

# lambda publicado por el NCBI para las matrices sin huecos.
LAMBDA_NCBI <- c(BLOSUM45 = 0.2291, BLOSUM62 = 0.3176, BLOSUM80 = 0.3430)


# --- Los dos paneles --------------------------------------------------------
COLORES <- c(`TRUE` = NARANJA, `FALSE` = AZUL)

panel_entropia <- function(d) {
  ggplot(d, aes(x = matriz, y = bits, fill = destacada)) +
    geom_col(width = 0.62) +
    geom_text(aes(label = sprintf("%.2f", bits)), vjust = -0.5, size = 2.6,
              colour = TEXTO) +
    scale_fill_manual(values = COLORES, guide = "none") +
    scale_y_continuous(limits = c(0, max(d$bits) * 1.18),
                       expand = expansion(0)) +
    labs(x = NULL, y = "Entropía relativa\n(bits por posición)") +
    tema_libro() +
    theme(panel.grid.major.x = element_blank(),
          axis.text.x = element_blank(),
          axis.ticks.x = element_blank(),
          axis.line.x = element_blank())
}

panel_longitud <- function(d) {
  ggplot(d, aes(x = matriz, y = residuos, fill = destacada)) +
    geom_col(width = 0.62) +
    geom_text(aes(label = sprintf("%.0f", residuos)), vjust = -0.5, size = 2.6,
              colour = TEXTO) +
    scale_fill_manual(values = COLORES, guide = "none") +
    scale_y_continuous(limits = c(0, max(d$residuos) * 1.18),
                       expand = expansion(0)) +
    labs(x = NULL,
         y = sprintf("Residuos alineados para\nacumular %d bits", BITS_OBJETIVO)) +
    tema_libro() +
    theme(panel.grid.major.x = element_blank())
}

construir <- function(d) {
  (panel_entropia(d) / panel_longitud(d)) +
    plot_layout(heights = c(1, 1.15)) +
    plot_annotation(
      caption = paste("Entropía relativa según los parámetros de blastp del",
                      "NCBI; los valores varían levemente entre fuentes.\nEl",
                      "umbral de 50 bits es ilustrativo. En naranja, el default",
                      "de BLAST."),
      theme = theme(
        plot.caption = element_text(size = rel(0.73), colour = GRIS,
                                    face = "italic", hjust = 0,
                                    margin = margin(t = 6),
                                    family = familia_base()),
        plot.caption.position = "plot"))
}


if (!interactive()) {
  verif <- vapply(names(LAMBDA_NCBI), lambda_verificado, numeric(1))

  stopifnot(
    # --- Los datos ---
    nrow(entropia) == 4L,
    !is.unsorted(entropia$bits),            # la entropía crece con el número
    all(entropia$bits > 0),
    sum(entropia$destacada) == 1L,
    # la longitud mínima es exactamente el recíproco escalado
    all(abs(entropia$residuos - BITS_OBJETIVO / entropia$bits) < 1e-9),
    # y por lo tanto decrece
    !is.unsorted(rev(entropia$residuos)),

    # --- Lo que afirma el capítulo ---
    # "con BLOSUM45 hacen falta al menos 130 residuos"
    entropia$residuos[entropia$matriz == "BLOSUM45"] > 130,
    # "alineamientos tres veces más largos" entre los extremos de la serie
    max(entropia$residuos) / min(entropia$residuos) > 3,
    # las cifras redondeadas de la tabla del capítulo
    identical(round(entropia$bits, 2), c(0.38, 0.70, 0.99, 1.18)),

    # --- Verificación independiente de lambda ---
    # Si el montaje de Karlin & Altschul es correcto, el lambda reconstruido
    # tiene que caer sobre el publicado. Es lo que valida que estas matrices son
    # las que dicen ser.
    all(abs(verif - LAMBDA_NCBI) < 0.005, na.rm = TRUE)
  )

  message("  entropía relativa y longitud mínima:")
  for (i in seq_len(nrow(entropia))) {
    message(sprintf("    %-9s %6.4f bits/pos  ->  %5.1f residuos para %d bits%s",
                    entropia$matriz[i], entropia$bits[i], entropia$residuos[i],
                    BITS_OBJETIVO,
                    if (entropia$destacada[i]) "   <- default de BLAST" else ""))
  }
  message(sprintf("  razón entre extremos: %.1fx (BLOSUM45 vs BLOSUM90)",
                  max(entropia$residuos) / min(entropia$residuos)))
  message("")
  message("  verificación de lambda (Karlin & Altschul sobre la matriz entera):")
  for (n in names(LAMBDA_NCBI)) {
    message(sprintf("    %-9s reconstruido %.4f   publicado %.4f   dif %+.4f",
                    n, verif[[n]], LAMBDA_NCBI[[n]], verif[[n]] - LAMBDA_NCBI[[n]]))
  }
  message("    BLOSUM90 no está en Biostrings: no se puede verificar")

  escribir_tsv(
    data.frame(matriz = as.character(entropia$matriz),
               bits_por_posicion = entropia$bits,
               bits_objetivo = BITS_OBJETIVO,
               residuos_minimos = round(entropia$residuos, 1),
               lambda_ncbi = unname(LAMBDA_NCBI[as.character(entropia$matriz)]),
               fuente = "NCBI BLAST (parámetros de blastp)",
               stringsAsFactors = FALSE),
    "entropia-matrices")
  guardar(construir(entropia), "entropia-matrices", 14, 12)
}
