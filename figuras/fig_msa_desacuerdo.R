## Fig. @fig-desacuerdo (Sesión 9, § El alineamiento es una estimación,
## no un dato): acuerdo entre Clustal Omega y MAFFT L-INS-i, y confianza
## por letra de MUSCLE5, a lo largo de LGR5 humano, para los 50
## receptores LGR de la práctica de la sesión 9.
##
## Generada: 2026-09-18 · R 4.6.0 (2026-04-24 ucrt) · ggplot2 4.0.3 ·
## svglite 2.2.2. Alineamientos: clustalo 1.2.4, mafft 7.526 (L-INS-i),
## muscle 5.1 (-stratified, 16 réplicas), corrida del 2026-09-17.
##
## ---------------------------------------------------------------------------
## ESTA FIGURA VA EN UN LIBRO Y SUS NÚMEROS TIENEN QUE SER REALES.
##
## Entradas, en figuras/datos/ (carpeta fuera de git, como todos los datos):
##   lgr_clustalo.aln     Clustal Omega de familia_lgr.faa  (práctica, ej. 1)
##   lgr_mafft.fasta      MAFFT L-INS-i de familia_lgr.faa  (práctica, ej. 1)
##   lgr_confianza.afa    letter confidence de MUSCLE5      (práctica, ej. 8)
## Son exactamente los productos de
## contenido/03-alineamientos/sesion09-practica.qmd; el instructor los tiene
## ya calculados en la clave de la práctica (familia_clustalo.aln,
## familia_mafft.fasta y confianza.afa de la familia lgr). Si falta alguno,
## el script SE DETIENE con un error que dice cuál. Prohibido inventar datos
## sintéticos.
##
## El cálculo del acuerdo es el mismo de practicas/scripts/acuerdo_por_columna.py
## (fracción de pares de residuos de cada columna de Clustal Omega que sigue
## junta en MAFFT); aquí se reporta por posición de la referencia, que es
## como lo analizan los alumnos.
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

AZUL    <- TEAL     # acuerdo / confianza altos
NARANJA <- AMBAR    # acuerdo / confianza bajos

DIR_DATOS <- file.path(DIR_FIGURAS, "datos")
DIR_LOG   <- file.path(DIR_FIGURAS, "log")

REF <- "LGR5_human"
# Anatomía de LGR5 humano (907 aa), la misma tabla de la práctica.
DOMINIOS <- data.frame(
  dominio = c("LRR", "bisagra", "7TM", "cola C"),
  inicio  = c(1, 455, 574, 821),
  fin     = c(454, 573, 820, 907)
)

ruta_clustal <- file.path(DIR_DATOS, "lgr_clustalo.aln")
ruta_mafft   <- file.path(DIR_DATOS, "lgr_mafft.fasta")
ruta_lc      <- file.path(DIR_DATOS, "lgr_confianza.afa")

faltan <- c(ruta_clustal, ruta_mafft, ruta_lc)
faltan <- faltan[!file.exists(faltan)]
if (length(faltan)) {
  stop("DETENIDO: faltan en figuras/datos/: ",
       paste(basename(faltan), collapse = ", "),
       ". Son los productos de la práctica de la sesión 9 para la familia ",
       "lgr (ejercicios 1 y 8), o los archivos de su clave. Sin datos ",
       "reales no se genera esta figura: va en el libro y está prohibido ",
       "inventar datos sintéticos.", call. = FALSE)
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
lc  <- leer_fasta(ruta_lc)

# Mismo conjunto de secuencias, cada alineamiento rectangular, y la
# secuencia sin gaps idéntica en los dos. Si algo de eso falla, los
# archivos no son alineamientos del mismo FASTA y no hay figura.
stopifnot(length(clu) >= 2, setequal(names(clu), names(maf)))
stopifnot(length(unique(nchar(clu))) == 1, length(unique(nchar(maf))) == 1)
stopifnot(REF %in% names(clu), REF %in% names(lc))
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

# --- De columnas a posiciones de la referencia ------------------------------
cols_ref <- which(strsplit(clu[[REF]], "")[[1]] != "-")   # columna de cada residuo
L_ref    <- length(cols_ref)
lc_ref   <- strsplit(gsub("-", "", lc[[REF]]), "")[[1]]
stopifnot(L_ref == max(DOMINIOS$fin), length(lc_ref) == L_ref,
          all(grepl("^[0-9]$", lc_ref)))

pos <- data.frame(pos     = seq_len(L_ref),
                  acuerdo = acuerdo[cols_ref],
                  lc      = as.integer(lc_ref))
pos$dominio <- cut(pos$pos, breaks = c(DOMINIOS$inicio, L_ref + 1),
                   labels = DOMINIOS$dominio, right = FALSE)

# --- Log para el pie de figura ----------------------------------------------
dir.create(DIR_LOG, showWarnings = FALSE)
con_acuerdo <- acuerdo[!is.na(acuerdo)]
por_dom <- vapply(split(pos, pos$dominio), function(d) {
  sprintf("%s: acuerdo %.2f, LC %.2f", d$dominio[1],
          mean(d$acuerdo, na.rm = TRUE), mean(d$lc))
}, character(1))
log_lineas <- c(
  sprintf("fecha: %s", format(Sys.Date())),
  sprintf("secuencias: %d", nseq),
  sprintf("columnas Clustal Omega: %d", ncol_clu),
  sprintf("columnas MAFFT: %d", ncol_maf),
  sprintf("columnas con acuerdo < 0.5: %d de %d con dato (%d NA)",
          sum(con_acuerdo < 0.5), length(con_acuerdo), sum(is.na(acuerdo))),
  sprintf("referencia: %s, %d posiciones", REF, L_ref),
  paste0("por dominio: ", paste(por_dom, collapse = "; "))
)
writeLines(log_lineas, file.path(DIR_LOG, "msa_desacuerdo.txt"))
message(paste0("  ", log_lineas, collapse = "\n"))

# --- La figura --------------------------------------------------------------
# Dos tiras sobre la misma escala 0-1: el acuerdo entre los dos programas y
# el LC de MUSCLE5 (0-9) dividido entre 9. Arriba, la anatomía de LGR5.
tiras <- rbind(
  data.frame(pos = pos$pos, y = 2, valor = pos$acuerdo),
  data.frame(pos = pos$pos, y = 1, valor = pos$lc / 9)
)

p <- ggplot(tiras, aes(x = pos, y = y, fill = valor)) +
  geom_tile(height = 0.84) +
  annotate("segment", x = DOMINIOS$inicio, xend = DOMINIOS$fin,
           y = 2.72, yend = 2.72, colour = GRIS, linewidth = 0.6) +
  annotate("segment", x = c(DOMINIOS$inicio, DOMINIOS$fin),
           xend = c(DOMINIOS$inicio, DOMINIOS$fin),
           y = 2.64, yend = 2.80, colour = GRIS, linewidth = 0.6) +
  annotate("text", x = (DOMINIOS$inicio + DOMINIOS$fin) / 2, y = 2.98,
           label = DOMINIOS$dominio, colour = TEXTO, size = 3.1,
           family = familia_base()) +
  scale_fill_gradient(low = NARANJA, high = AZUL, limits = c(0, 1),
                      breaks = c(0, 0.5, 1), na.value = "grey85") +
  scale_x_continuous(expand = c(0, 0), breaks = c(1, seq(100, 900, 100))) +
  scale_y_continuous(breaks = c(1, 2), limits = c(0.55, 3.15),
                     expand = c(0, 0),
                     labels = c("confianza\nMUSCLE5",
                                "acuerdo Clustal\nOmega vs MAFFT")) +
  labs(x = "posición en LGR5 humano (aa)", y = NULL) +
  tema_lgc() +
  theme(axis.ticks.y = element_blank(),
        axis.line.y  = element_blank(),
        panel.grid.major = element_blank(),   # tema_lgc() la define: hay que apagarla por nombre
        legend.key.height = unit(9, "pt"),
        panel.background = element_rect(fill = "transparent", colour = NA),
        plot.background  = element_rect(fill = "transparent", colour = NA))

guardar(p, "msa_desacuerdo", subdir = "svg", ancho = 7, alto = 2.3)
