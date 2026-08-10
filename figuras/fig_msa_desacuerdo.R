## Fig. @fig-desacuerdo (Sesión 9, § El alineamiento es una estimación,
## no un dato): tira de acuerdo por columna entre los alineamientos de
## Clustal Omega y MAFFT de la familia de globinas de la práctica.
##
## Script escrito: 2026-08-09 · R 4.6.0 (2026-04-24 ucrt) ·
## ggplot2 4.0.3 · svglite 2.2.2 · clustalo/mafft: pendiente (ver abajo;
## al generar los alineamientos, sus versiones quedan en
## figuras/log/msa_desacuerdo.txt y hay que copiarlas a este encabezado).
##
## ---------------------------------------------------------------------------
## ESTA FIGURA VA EN UN LIBRO Y SUS NÚMEROS TIENEN QUE SER REALES.
##
## Entrada primaria: figuras/datos/familia.fasta (globinas de UniProt,
## CC BY 4.0, el mismo archivo de la práctica de la sesión 8). Si ya
## existen figuras/datos/familia_clustalo.aln y familia_mafft.fasta se
## usan tal cual; si solo está el FASTA y clustalo y mafft están en el
## PATH, se generan con exactamente los comandos del capítulo. Si no hay
## ni alineamientos ni forma de generarlos, el script SE DETIENE con un
## error que dice qué falta. Prohibido inventar datos sintéticos.
##
## NOTA SOBRE EL TEMA: igual que en fig_msa_escalamiento.R, se usa
## figuras/estilo.R (no existe figuras/_tema.R en este repo) y los alias
## AZUL/NARANJA se definen acá.
## ---------------------------------------------------------------------------
##
## Regenerar:  Rscript figuras/fig_msa_desacuerdo.R   (desde la raíz)

.ubicar <- function() {
  for (i in rev(seq_len(sys.nframe()))) {
    o <- sys.frame(i)$ofile
    if (!is.null(o)) return(normalizePath(o, winslash = "/"))
  }
  a <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  if (length(a)) {
    return(normalizePath(sub("^--file=", "", a[1]), winslash = "/"))
  }
  stop("no se pudo ubicar el script: correr con Rscript o con source()")
}
source(file.path(dirname(.ubicar()), "estilo.R"))

AZUL    <- TEAL     # acuerdo alto
NARANJA <- AMBAR    # acuerdo bajo

DIR_DATOS <- file.path(DIR_FIGURAS, "datos")
DIR_LOG   <- file.path(DIR_FIGURAS, "log")

ruta_fasta   <- file.path(DIR_DATOS, "familia.fasta")
ruta_clustal <- file.path(DIR_DATOS, "familia_clustalo.aln")
ruta_mafft   <- file.path(DIR_DATOS, "familia_mafft.fasta")

# --- Conseguir los alineamientos -------------------------------------------
version_clustalo <- NA_character_
version_mafft    <- NA_character_

if (!file.exists(ruta_clustal) || !file.exists(ruta_mafft)) {
  if (!file.exists(ruta_fasta)) {
    stop("DETENIDO: falta figuras/datos/familia.fasta (las globinas de la ",
         "práctica de la sesión 8) y tampoco están los alineamientos ",
         "familia_clustalo.aln / familia_mafft.fasta. Sin datos reales no ",
         "se genera esta figura: va en el libro y está prohibido inventar ",
         "datos sintéticos. Colocar el FASTA (o los alineamientos ya ",
         "hechos) en figuras/datos/ y volver a correr.", call. = FALSE)
  }
  clustalo <- Sys.which("clustalo")
  mafft    <- Sys.which("mafft")
  if (clustalo == "" || mafft == "") {
    stop("DETENIDO: figuras/datos/familia.fasta existe pero faltan los ",
         "binarios en el PATH (clustalo: ",
         if (clustalo == "") "NO" else clustalo, "; mafft: ",
         if (mafft == "") "NO" else mafft, "). Generar los alineamientos ",
         "con los comandos del capítulo (sección Práctica, paso 1) y ",
         "dejarlos en figuras/datos/, o correr este script donde los ",
         "binarios existan (el ambiente conda `msa` de ken).",
         call. = FALSE)
  }
  # Exactamente los comandos del capítulo (sin el guidetree, que la
  # figura no usa).
  version_clustalo <- system2(clustalo, "--version", stdout = TRUE)[1]
  version_mafft    <- paste(
    system2(mafft, "--version", stdout = TRUE, stderr = TRUE),
    collapse = " ")
  message("  generando familia_clustalo.aln con clustalo ", version_clustalo)
  status <- system2(clustalo, c("-i", shQuote(ruta_fasta),
                                "-o", shQuote(ruta_clustal),
                                "--outfmt=clu", "--force"))
  stopifnot(status == 0)
  message("  generando familia_mafft.fasta con ", version_mafft)
  status <- system2(mafft, c("--localpair", "--maxiterate", "1000",
                             shQuote(ruta_fasta)),
                    stdout = ruta_mafft)
  stopifnot(status == 0)
}

# --- Parsear (base R: sin dependencias nuevas) ------------------------------
leer_clustal <- function(ruta) {
  lineas <- readLines(ruta, warn = FALSE)
  lineas <- lineas[!grepl("^CLUSTAL", lineas)]
  seqs <- list()
  for (ln in lineas) {
    if (!nzchar(trimws(ln))) next
    if (grepl("^\\s", ln)) next            # línea de conservación (* : .)
    campos <- strsplit(trimws(ln), "\\s+")[[1]]
    if (length(campos) < 2) next
    trozo <- campos[2]
    if (!grepl("^[A-Za-z-]+$", trozo)) next
    nom <- campos[1]
    seqs[[nom]] <- paste0(
      if (is.null(seqs[[nom]])) "" else seqs[[nom]], trozo)
  }
  unlist(seqs)
}

leer_fasta <- function(ruta) {
  lineas <- readLines(ruta, warn = FALSE)
  idx <- which(grepl("^>", lineas))
  stopifnot(length(idx) > 0)
  fin <- c(idx[-1] - 1, length(lineas))
  seqs <- vapply(seq_along(idx), function(k) {
    paste(lineas[(idx[k] + 1):fin[k]], collapse = "")
  }, character(1))
  names(seqs) <- sub("\\s.*$", "", sub("^>", "", lineas[idx]))
  seqs
}

clu <- leer_clustal(ruta_clustal)
maf <- leer_fasta(ruta_mafft)

# Mismo conjunto de secuencias, cada alineamiento rectangular, y la
# secuencia sin gaps idéntica en los dos. Si algo de eso falla, los
# archivos no son alineamientos del mismo FASTA y no hay figura.
stopifnot(length(clu) >= 2, setequal(names(clu), names(maf)))
stopifnot(length(unique(nchar(clu))) == 1, length(unique(nchar(maf))) == 1)
maf <- maf[names(clu)]
for (nom in names(clu)) {
  a <- toupper(gsub("-", "", clu[[nom]]))
  b <- toupper(gsub("-", "", maf[[nom]]))
  if (!identical(a, b)) {
    stop("la secuencia sin gaps de '", nom, "' difiere entre los dos ",
         "alineamientos: no son alineamientos del mismo FASTA", call. = FALSE)
  }
}

# --- Acuerdo por columna ----------------------------------------------------
# M[i, c]: columna de MAFFT donde cae el residuo que la secuencia i tiene
# en la columna c de Clustal Omega; NA si ahí hay gap.
nseq     <- length(clu)
ncol_clu <- nchar(clu[[1]])
ncol_maf <- nchar(maf[[1]])

M <- matrix(NA_integer_, nrow = nseq, ncol = ncol_clu)
for (i in seq_len(nseq)) {
  nom <- names(clu)[i]
  letras_clu <- strsplit(clu[[nom]], "")[[1]]
  es_residuo <- letras_clu != "-"
  r <- cumsum(es_residuo)                  # número de residuo en cada columna
  letras_maf <- strsplit(maf[[nom]], "")[[1]]
  cols_maf <- which(letras_maf != "-")     # columna de MAFFT del residuo r
  M[i, es_residuo] <- cols_maf[r[es_residuo]]
}

acuerdo <- vapply(seq_len(ncol_clu), function(c) {
  v <- M[, c]
  v <- v[!is.na(v)]
  n <- length(v)
  if (n < 2) return(NA_real_)              # menos de dos residuos: NA
  sum(choose(table(v), 2)) / choose(n, 2)  # pares co-alineados / pares totales
}, numeric(1))

# --- Log para el pie de figura ----------------------------------------------
dir.create(DIR_LOG, showWarnings = FALSE)
con_acuerdo <- acuerdo[!is.na(acuerdo)]
log_lineas <- c(
  sprintf("fecha: %s", format(Sys.Date())),
  sprintf("secuencias: %d", nseq),
  sprintf("columnas Clustal Omega: %d", ncol_clu),
  sprintf("columnas MAFFT: %d", ncol_maf),
  sprintf("acuerdo promedio: %.3f", mean(con_acuerdo)),
  sprintf("columnas con acuerdo < 0.5: %.1f%% (%d de %d con dato; %d NA)",
          100 * mean(con_acuerdo < 0.5), sum(con_acuerdo < 0.5),
          length(con_acuerdo), sum(is.na(acuerdo))),
  sprintf("clustalo: %s", version_clustalo),
  sprintf("mafft: %s", version_mafft)
)
writeLines(log_lineas, file.path(DIR_LOG, "msa_desacuerdo.txt"))
message(paste0("  ", log_lineas, collapse = "\n"))

# --- La figura --------------------------------------------------------------
df <- data.frame(columna = seq_len(ncol_clu), acuerdo = acuerdo)

p <- ggplot(df, aes(x = columna, y = 1, fill = acuerdo)) +
  geom_tile() +
  scale_fill_gradient(low = NARANJA, high = AZUL, limits = c(0, 1),
                      na.value = "grey85", name = "acuerdo") +
  scale_x_continuous(expand = c(0, 0)) +
  scale_y_continuous(expand = c(0, 0)) +
  labs(x = "columna (Clustal Omega)", y = NULL) +
  tema_lgc() +
  theme(axis.text.y  = element_blank(),
        axis.ticks.y = element_blank(),
        axis.line.y  = element_blank(),
        panel.grid   = element_blank(),
        panel.background = element_rect(fill = "transparent", colour = NA),
        plot.background  = element_rect(fill = "transparent", colour = NA))

guardar(p, "msa_desacuerdo", subdir = "svg", ancho = 7, alto = 1.8)
