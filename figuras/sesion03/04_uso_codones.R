## Fig. @fig-uso-codones (Sesión 3, § El sesgo de uso de codones)
## RSCU de los 61 codones con sentido en tres genomas de GC muy distinto.
##
## ---------------------------------------------------------------------------
## DE DÓNDE SALEN LOS DATOS
##
## La especificación pedía CoCoPUTs o HIVE-CUTs, y explícitamente NO Kazusa (que
## el capítulo critica por nombre en un callout: congelada en 2007). Al 5 de
## agosto de 2026 CoCoPUTs y HIVE-CUTs son el mismo servicio y está caído:
## dnahive.fda.gov resuelve pero no acepta conexiones HTTPS, y
## hive.biochemistry.gwu.edu/review/codon2 sólo redirige ahí. Consultado con el
## autor, se optó por calcular el RSCU de cero a partir de los CDS de RefSeq.
##
## Sale mejor que cualquier tabla precalculada para lo que el capítulo enseña:
## queda anclado a un accession y una fecha, y se regenera con un comando. La
## queja contra Kazusa es justamente que no dice cuándo se actualizó; esta
## figura sí, y lo dice en el .tsv, en el pie y en datos/PROCEDENCIA.tsv.
##
## Los CDS los baja 00_descarga_datos.sh. No se versionan (datos/ está en
## .gitignore); se versionan el script, este .R y el .tsv de resultados.
## ---------------------------------------------------------------------------
##
## OJO CON EL %GC. El que se anota bajo cada organismo es el GC DE LOS CDS, no
## el del genoma completo, porque es el que corresponde a lo que se está
## graficando. En Plasmodium la diferencia es grande (los CDS son bastante menos
## AT-ricos que el resto del genoma) y el pie lo advierte.
##
## Sin título dentro del SVG: el caption vive en el .qmd.
##
## Regenerar:  bash figuras/sesion03/00_descarga_datos.sh   # una vez
##             Rscript figuras/sesion03/04_uso_codones.R

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


# --- Los tres organismos ----------------------------------------------------
# El orden es de menor a mayor GC: la figura se lee de izquierda a derecha como
# un gradiente, que es el punto.
ORGANISMOS <- data.frame(
  archivo = c("plasmodium", "ecoli", "streptomyces"),
  nombre  = c("Plasmodium falciparum", "Escherichia coli K-12",
              "Streptomyces coelicolor"),
  corto   = c("P. falciparum", "E. coli", "S. coelicolor"),
  stringsAsFactors = FALSE
)

DIR_DATOS <- file.path(.DIR_SESION03, "datos")

# --- Filtros de CDS ---------------------------------------------------------
# Un CDS entra al conteo si mide un múltiplo de 3 (si no, no se puede leer por
# codones), si mide al menos 300 nt (los muy cortos son ruido y suelen ser
# anotación dudosa) y si no trae códigos de ambigüedad. Los que se descartan se
# reportan: esconder un filtro es esconder un sesgo.
LARGO_MINIMO <- 300L

leer_codones <- function(corto) {
  ruta <- file.path(DIR_DATOS, paste0(corto, "_cds.fna.gz"))
  if (!file.exists(ruta)) {
    stop(sprintf(paste("falta %s.\nCorre primero:  bash figuras/sesion03/00_descarga_datos.sh",
                       "\n(desde la raíz del repo)"), ruta), call. = FALSE)
  }
  s <- Biostrings::readDNAStringSet(ruta)
  n_total <- length(s)

  usable <- (Biostrings::width(s) %% 3L == 0L) &
            (Biostrings::width(s) >= LARGO_MINIMO) &
            (Biostrings::alphabetFrequency(s, baseOnly = TRUE)[, "other"] == 0L)
  s <- s[usable]

  list(
    conteo  = colSums(Biostrings::trinucleotideFrequency(s, step = 3L)),
    gc      = sum(Biostrings::letterFrequency(s, "GC")) / sum(Biostrings::width(s)),
    n_total = n_total,
    n_usado = length(s),
    nt      = sum(Biostrings::width(s))
  )
}

# --- RSCU -------------------------------------------------------------------
#' RSCU: uso observado de un codón contra lo esperado si todos los sinónimos de
#' ese aminoácido se usaran por igual.
#'
#'     RSCU_ij = n_i * X_ij / sum_j(X_ij)
#'
#' donde n_i es cuántos codones sinónimos tiene el aminoácido i. Vale 1 cuando
#' no hay sesgo, y por construcción vale exactamente 1 para Met y Trp, que
#' tienen un solo codón. Se excluyen los codones de paro: no forman una familia
#' de sinónimos comparable (el gen sólo tiene uno, al final).
rscu <- function(conteo, codigo) {
  d <- codigo[codigo$aa != "*", ]
  d$n_obs <- as.integer(conteo[d$codon])
  total_aa <- tapply(d$n_obs, d$aa, sum)
  n_sin    <- table(d$aa)
  d$rscu <- ifelse(total_aa[d$aa] == 0, NA_real_,
                   as.integer(n_sin[d$aa]) * d$n_obs / total_aa[d$aa])
  d
}


# --- Cálculo ----------------------------------------------------------------
codigo <- tabla_codigo("1")
crudo  <- lapply(ORGANISMOS$archivo, leer_codones)
names(crudo) <- ORGANISMOS$archivo

ORGANISMOS$gc      <- vapply(crudo, function(x) x$gc, numeric(1))
ORGANISMOS$n_total <- vapply(crudo, function(x) x$n_total, numeric(1))
ORGANISMOS$n_usado <- vapply(crudo, function(x) x$n_usado, numeric(1))
ORGANISMOS$nt      <- vapply(crudo, function(x) x$nt, numeric(1))
ORGANISMOS$codones <- vapply(crudo, function(x) sum(x$conteo), numeric(1))

datos <- do.call(rbind, lapply(seq_len(nrow(ORGANISMOS)), function(i) {
  r <- rscu(crudo[[i]]$conteo, codigo)
  r$organismo <- ORGANISMOS$corto[i]
  r$orden_org <- i
  r
}))

# Procedencia, escrita por el script de descarga.
PROCEDENCIA <- file.path(DIR_DATOS, "PROCEDENCIA.tsv")
proc <- if (file.exists(PROCEDENCIA)) {
  read.delim(PROCEDENCIA, stringsAsFactors = FALSE)
} else {
  data.frame(organismo = ORGANISMOS$nombre, assembly = NA, fecha_descarga = NA)
}
FECHA <- if (!is.na(proc$fecha_descarga[1])) proc$fecha_descarga[1] else "sin fecha"


# --- Orden de los codones ---------------------------------------------------
# Por clase química (mismo orden que las figuras 1, 2 y 5), luego por
# aminoácido, luego por CAJA (las dos primeras bases) y dentro de la caja por
# tercera base en U, C, A, G.
#
# Ordenar sólo por tercera base sería un error: Leu, Ser y Arg tienen sus seis
# codones repartidos en DOS cajas (UUR + CUN, UCN + AGY, CGN + AGR), y entonces
# los renglones salen intercalados —UCU, AGU, UCC, AGC...— y se pierde justo el
# patrón de tercera base que la figura quiere mostrar.
datos$clase <- clase_ordenada(datos$clase)
orden_aa <- unique(datos[order(datos$clase, datos$aa), "aa"])
datos$orden_aa <- match(datos$aa, orden_aa)
datos$caja     <- substr(datos$codon, 1, 2)
datos$orden_b3 <- match(chartr("T", "U", datos$b3), ORDEN_BASES)
datos <- datos[order(datos$orden_aa, datos$caja, datos$orden_b3, datos$orden_org), ]

filas <- unique(datos[, c("aa", "nombre", "clase", "codon", "codon_arn",
                          "orden_aa", "caja", "orden_b3")])
filas <- filas[order(filas$orden_aa, filas$caja, filas$orden_b3), ]
filas$i <- seq_len(nrow(filas))

# --- Reparto en tres bloques ------------------------------------------------
# 61 codones en una sola columna de 16 cm de alto darían renglones de 2 mm: no
# se leen. En tres bloques lado a lado quedan renglones de ~4 mm y sobra ancho.
# El corte se hace SIEMPRE en frontera de aminoácido, para no partir una caja.
N_BLOQUES <- 3L
cortes_aa <- tapply(filas$i, filas$orden_aa, max)      # última fila de cada aa
objetivo  <- nrow(filas) / N_BLOQUES
cortes <- vapply(seq_len(N_BLOQUES - 1L), function(k) {
  cortes_aa[which.min(abs(cortes_aa - k * objetivo))]
}, numeric(1))
filas$bloque <- findInterval(filas$i, cortes + 0.5) + 1L
filas$j <- ave(filas$i, filas$bloque, FUN = seq_along)   # renglón dentro del bloque

# Hueco entre cajas de aminoácido: cuántos aminoácidos empezaron antes que éste
# DENTRO de su bloque.
filas$k_aa <- ave(filas$orden_aa, filas$bloque,
                  FUN = function(x) match(x, unique(x)) - 1L)


# --- Geometría, en milímetros -----------------------------------------------
# guardar(w = 16, h = 14) con 2 mm de margen: panel de 156 x 128 mm.
ANCHO_PANEL <- 156
ALTO_PANEL  <- 128

W_AA     <- 12      # columna del aminoácido ("L  Leu")
W_CODON  <- 10      # columna del codón
W_CELDA  <- 8       # cada organismo
W_BLOQUE <- W_AA + W_CODON + nrow(ORGANISMOS) * W_CELDA          # 46
HUECO_BLOQUE <- (ANCHO_PANEL - N_BLOQUES * W_BLOQUE) / (N_BLOQUES - 1)

X_BLOQUE <- (seq_len(N_BLOQUES) - 1L) * (W_BLOQUE + HUECO_BLOQUE)

Y_TOPE   <- 98      # borde superior de la rejilla
H_FILA   <- 3.4
GAP_AA   <- 1.1     # separación entre cajas de aminoácido

Y_GC     <- Y_TOPE + 3     # el %GC, justo sobre las columnas
Y_ORG    <- Y_TOPE + 6.5   # el nombre del organismo, rotado

Y_BARRA  <- 10             # barra de color
H_BARRA  <- 3.5
W_BARRA  <- 56
X_BARRA  <- (ANCHO_PANEL - W_BARRA) / 2
Y_BARRA_TXT <- Y_BARRA - 4

TAM_CODON <- 2.0
TAM_AA    <- 2.0
TAM_GC    <- 1.9
TAM_ORG   <- 2.0
TAM_BARRA <- 1.9

# Tope de la escala de color. RSCU no tiene cota superior (con seis sinónimos
# puede llegar a 6); por encima de este valor se recorta, y el pie dice cuántas
# celdas se recortaron. Recortar en silencio sería mentir sobre el máximo.
RSCU_TOPE <- 2.5

SANS <- familia_base()
MONO <- familia_mono()


# --- Colocación -------------------------------------------------------------
filas$y_top <- Y_TOPE - (filas$j - 1L) * H_FILA - filas$k_aa * GAP_AA
filas$ymin  <- filas$y_top - H_FILA
filas$y     <- (filas$y_top + filas$ymin) / 2
filas$x0    <- X_BLOQUE[filas$bloque]

celdas <- merge(datos[, c("codon", "organismo", "orden_org", "rscu", "n_obs")],
                filas, by = "codon")
celdas$xmin <- celdas$x0 + W_AA + W_CODON + (celdas$orden_org - 1L) * W_CELDA
celdas$xmax <- celdas$xmin + W_CELDA
celdas$rscu_recortado <- pmin(celdas$rscu, RSCU_TOPE)
N_RECORTADAS <- sum(celdas$rscu > RSCU_TOPE, na.rm = TRUE)

# Etiqueta de aminoácido: una por caja, centrada sobre sus filas.
etiq_aa <- do.call(rbind, lapply(split(filas, filas$orden_aa), function(g) {
  data.frame(texto = sprintf("%s  %s", g$aa[1], g$nombre[1]),
             clase = g$clase[1],
             x = g$x0[1] + 1,
             y = mean(c(max(g$y_top), min(g$ymin))),
             stringsAsFactors = FALSE)
}))
etiq_aa$color <- unname(colores_clase[as.character(etiq_aa$clase)])

# Cabeceras: se repiten en los tres bloques.
cabeceras <- do.call(rbind, lapply(seq_len(N_BLOQUES), function(b) {
  data.frame(
    x = X_BLOQUE[b] + W_AA + W_CODON + (seq_len(nrow(ORGANISMOS)) - 0.5) * W_CELDA,
    corto = ORGANISMOS$corto,
    gc    = sprintf("%.0f %%", 100 * ORGANISMOS$gc),
    stringsAsFactors = FALSE
  )
}))

# Barra de color: una tira de rectángulos finos. Cada uno termina donde empieza
# el siguiente (y no a un ancho fijo), porque con `xmin + W/n` quedan costuras
# blancas de una fracción de milímetro entre rectángulo y rectángulo: se ven en
# el SVG como rayas verticales sobre el degradado.
N_BARRA <- 160L
barra <- data.frame(v = seq(0, RSCU_TOPE, length.out = N_BARRA))
barra$xmin <- X_BARRA + (barra$v / RSCU_TOPE) * W_BARRA
barra$xmax <- c(barra$xmin[-1], X_BARRA + W_BARRA)
marcas <- data.frame(v = c(0, 0.5, 1, 1.5, 2, 2.5))
marcas$x <- X_BARRA + (marcas$v / RSCU_TOPE) * W_BARRA
marcas$txt <- ifelse(marcas$v == RSCU_TOPE, paste0("≥ ", marcas$v), as.character(marcas$v))

# El pie va partido a mano: el caption de ggplot no hace wrap solo y, si se
# pasa, se sale del SVG por la derecha sin ningún aviso. ANCHO_PIE es la cota
# que comprueba el stopifnot del final. Los accessions no caben acá y van en el
# .tsv y en datos/PROCEDENCIA.tsv.
ANCHO_PIE <- 112L
PIE <- paste(
  sprintf("RSCU calculado de los CDS de RefSeq, bajados el %s: %s codones de %s CDS.",
          FECHA,
          formatC(sum(ORGANISMOS$codones), big.mark = ",", format = "d"),
          formatC(sum(ORGANISMOS$n_usado), big.mark = ",", format = "d")),
  "Vale 1 si no hay sesgo; Met y Trp valen 1 por definición. Accessions y conteos en uso-codones.tsv.",
  "El %GC es el de los CDS, no el del genoma completo: en P. falciparum el resto del genoma es más AT-rico.",
  if (N_RECORTADAS > 0)
    sprintf("%d de las %d celdas tienen RSCU > %.1f y se dibujan al tope de la escala.",
            N_RECORTADAS, nrow(celdas), RSCU_TOPE)
  else "Ninguna celda llegó al tope de la escala.",
  sep = "\n")


construir <- function() {
  ggplot() +
    # --- El heatmap ---
    geom_rect(data = celdas,
              aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = y_top,
                  fill = rscu_recortado),
              colour = "white", linewidth = 0.2) +

    # --- Codón y aminoácido ---
    geom_text(data = filas, aes(x = x0 + W_AA + 1, y = y, label = codon_arn),
              family = MONO, size = TAM_CODON, colour = TEXTO, hjust = 0) +
    geom_text(data = etiq_aa, aes(x = x, y = y, label = texto, colour = color),
              family = MONO, size = TAM_AA, hjust = 0, show.legend = FALSE) +

    # --- Cabeceras: organismo rotado y %GC ---
    geom_text(data = cabeceras, aes(x = x, y = Y_ORG, label = corto),
              family = SANS, size = TAM_ORG, colour = TEXTO, angle = 90,
              hjust = 0, fontface = "italic") +
    geom_text(data = cabeceras, aes(x = x, y = Y_GC, label = gc),
              family = SANS, size = TAM_GC, colour = GRIS) +

    # --- Barra de color ---
    geom_rect(data = barra,
              aes(xmin = xmin, xmax = xmax, ymin = Y_BARRA,
                  ymax = Y_BARRA + H_BARRA, fill = v), colour = NA) +
    geom_text(data = marcas, aes(x = x, y = Y_BARRA_TXT, label = txt),
              family = SANS, size = TAM_BARRA, colour = GRIS) +
    geom_text(data = data.frame(1),
              aes(x = X_BARRA + W_BARRA / 2, y = Y_BARRA + H_BARRA + 2.6),
              label = "RSCU", family = SANS, size = TAM_BARRA, colour = GRIS) +

    scale_fill_gradient2(low = AZUL, mid = "white", high = NARANJA,
                         midpoint = 1, limits = c(0, RSCU_TOPE),
                         oob = scales::squish, guide = "none") +
    scale_colour_identity() +
    coord_cartesian(xlim = c(0, ANCHO_PANEL), ylim = c(0, ALTO_PANEL),
                    expand = FALSE, clip = "off") +
    labs(caption = PIE) +
    tema_esquema()
}


if (!interactive()) {
  # RSCU de una familia tiene que promediar 1 por construcción. Es la prueba de
  # que la fórmula está bien implementada, y no depende de los datos.
  media_por_familia <- tapply(datos$rscu, paste(datos$organismo, datos$aa), mean)

  # Preferencia de tercera base: la correlación que el capítulo quiere mostrar.
  gc3 <- sapply(ORGANISMOS$corto, function(o) {
    s <- datos[datos$organismo == o, ]
    sum(s$n_obs[s$b3 %in% c("G", "C")]) / sum(s$n_obs)
  })

  stopifnot(
    # --- Los datos ---
    nrow(filas) == 61L,                          # 61 codones con sentido
    !any(filas$aa == "*"),
    nrow(celdas) == 61L * nrow(ORGANISMOS),
    all(ORGANISMOS$n_usado > 3000),              # los tres tienen material de sobra
    all(ORGANISMOS$n_usado <= ORGANISMOS$n_total),

    # --- El RSCU está bien calculado ---
    all(abs(media_por_familia - 1) < 1e-9),      # promedia 1 en cada familia
    all(datos$rscu[datos$aa %in% c("M", "W")] == 1),
    all(datos$rscu >= 0), !anyNA(datos$rscu),

    # --- Lo que la figura afirma ---
    !is.unsorted(ORGANISMOS$gc),                 # ordenados por GC creciente
    diff(range(ORGANISMOS$gc)) > 0.4,            # el contraste es real
    !is.unsorted(gc3),                           # y arrastra la tercera base
    cor(ORGANISMOS$gc, gc3) > 0.99,

    # --- El reparto en bloques ---
    length(unique(filas$bloque)) == N_BLOQUES,
    # ninguna caja de aminoácido queda partida entre dos bloques
    all(tapply(filas$bloque, filas$orden_aa, function(b) length(unique(b))) == 1L),

    # --- Nada se sale del panel ---
    HUECO_BLOQUE > 4,
    max(X_BLOQUE) + W_BLOQUE <= ANCHO_PANEL,
    min(filas$ymin) > Y_BARRA + H_BARRA + 5,
    Y_ORG + 2 * media_ancho(ORGANISMOS$corto, TAM_ORG) <= ALTO_PANEL,
    Y_BARRA_TXT - TAM_BARRA >= 0,
    all(nchar(strsplit(PIE, "\n", fixed = TRUE)[[1]]) <= ANCHO_PIE)
  )

  message("  CDS usados (filtro: múltiplo de 3, >= 300 nt, sin ambigüedad):")
  for (i in seq_len(nrow(ORGANISMOS))) {
    message(sprintf("    %-24s %5.0f de %5.0f CDS (%2.0f %%)  %6.2f Mb  GC(CDS) %.1f %%  GC3 %.1f %%",
                    ORGANISMOS$nombre[i], ORGANISMOS$n_usado[i],
                    ORGANISMOS$n_total[i],
                    100 * ORGANISMOS$n_usado[i] / ORGANISMOS$n_total[i],
                    ORGANISMOS$nt[i] / 1e6, 100 * ORGANISMOS$gc[i], 100 * gc3[i]))
  }
  message(sprintf("  correlación GC(CDS) ~ GC en tercera posición: r = %.4f",
                  cor(ORGANISMOS$gc, gc3)))
  message(sprintf("  procedencia: %s ; descargado el %s",
                  paste(proc$assembly, collapse = ", "), FECHA))
  message(sprintf("  RSCU: rango %.2f a %.2f; %d celdas por encima del tope %.1f",
                  min(datos$rscu), max(datos$rscu), N_RECORTADAS, RSCU_TOPE))
  message("  caja de alanina, para cotejar de un vistazo:")
  ala <- datos[datos$aa == "A", ]
  for (o in ORGANISMOS$corto) {
    s <- ala[ala$organismo == o, ]
    message(sprintf("    %-16s %s", o,
                    paste(sprintf("%s=%.2f", s$codon_arn, s$rscu), collapse = "  ")))
  }

  escribir_tsv(
    data.frame(organismo = datos$organismo,
               codon     = datos$codon,
               codon_arn = datos$codon_arn,
               aa        = datos$aa,
               nombre_aa = datos$nombre,
               clase     = as.character(datos$clase),
               n_obs     = datos$n_obs,
               rscu      = round(datos$rscu, 4),
               gc_cds    = round(ORGANISMOS$gc[datos$orden_org], 4),
               assembly  = proc$assembly[datos$orden_org],
               fecha_descarga = FECHA,
               fuente    = "NCBI RefSeq, CDS; RSCU calculado por 04_uso_codones.R",
               stringsAsFactors = FALSE),
    "uso-codones")
  guardar(construir(), "uso-codones", 16, 14)
}
