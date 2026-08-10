## Fig. @fig-mito (Sesión 3, § El código no es universal)
## Estándar (tabla 1) contra mitocondrial de vertebrados (tabla 2).
##
## El mensaje visual es "casi todo igual, cuatro casillas distintas, y con eso
## basta". Por eso la rejilla es la misma de la figura 1 pero apagada a gris, y
## sólo los cuatro codones que cambian llevan color.
##
## Las diferencias se CALCULAN con un merge de las dos tablas. No hay ninguna
## lista de codones tecleada: si Biostrings cambiara de convención, el script
## truena en el stopifnot en vez de dibujar algo falso.
##
## Sin título dentro del SVG: el caption vive en el .qmd.
##
## Regenerar:  Rscript figuras/sesion03/03_estandar_vs_mito.R

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
# "UGA no es paro sino triptófano, AGA y AGG dejan de ser arginina y funcionan
#  como paro, y AUA codifica metionina en lugar de isoleucina. Cuatro codones
#  cambiados respecto al estándar."
CODONES_ESPERADOS <- c("AGA", "AGG", "ATA", "TGA")   # en DNA, ordenados
N_TABLAS_NCBI <- 33


# --- Los datos --------------------------------------------------------------
t1 <- tabla_codigo("1")
t2 <- tabla_codigo("2")

dif <- merge(t1, t2, by = "codon", suffixes = c("_std", "_mito"))
dif <- dif[dif$aa_std != dif$aa_mito, ]
dif <- dif[order(dif$codon), ]

# Si esto no da cuatro, la versión de Biostrings usa otra convención y la figura
# (y el capítulo) estarían diciendo algo falso. Se para acá, con un mensaje que
# explique qué pasó, en vez de dibujar.
if (nrow(dif) != 4L || !identical(dif$codon, CODONES_ESPERADOS)) {
  stop(sprintf(paste("Se esperaban exactamente 4 codones distintos (%s) y",
                     "salieron %d (%s).\nLa versión instalada de Biostrings usa",
                     "otra convención para las tablas 1 y 2:\nrevisar antes de",
                     "regenerar la figura y el texto del capítulo."),
               paste(CODONES_ESPERADOS, collapse = ", "),
               nrow(dif), paste(dif$codon, collapse = ", ")),
       call. = FALSE)
}

# Etiqueta de cada cambio: "UGA   Paro -> Trp".
dif$de    <- unname(nombres_aa[dif$aa_std])
dif$a     <- unname(nombres_aa[dif$aa_mito])
dif$texto <- sprintf("%s   %s → %s", dif$codon_arn_std, dif$de, dif$a)


# --- Geometría, en milímetros -----------------------------------------------
# Misma rejilla que la figura 1, para que las dos se lean como la misma tabla.
# guardar(w = 18, h = 12): panel de 176 x 110 mm.
ANCHO_PANEL <- 176
ALTO_PANEL  <- 110

X_REJILLA <- 13
W_COL     <- 30                 # más angosta que en la fig. 1: acá no hay nombre
N_COL     <- length(ORDEN_BASES)
X_FIN     <- X_REJILLA + N_COL * W_COL

Y_REJILLA <- 16
H_FILA    <- 4.4
N_FILA    <- 16
Y_TOPE    <- Y_REJILLA + N_FILA * H_FILA

Y_CABEZA  <- Y_TOPE + 3.5
Y_TITULO  <- Y_TOPE + 8.5

# La lista de los cuatro cambios, a la derecha y centrada sobre la rejilla.
#
# SIN LÍNEAS GUÍA a las casillas, a propósito. Se probaron: tres de las cuatro
# salen cortas y limpias (AGA, AGG y UGA viven en la última columna), pero AUA
# está en la primera y su guía cruza la tabla entera en diagonal, pasando por
# encima de una docena de casillas. Con guías en tres de cuatro la figura se ve
# inconsistente; con las cuatro, sucia. Y no hacen falta: cuatro casillas
# naranjas contra sesenta grises no cuestan trabajo de encontrar.
X_LISTA    <- X_FIN + 10
PASO_LISTA <- 6.5

Y_NOTA    <- 6

DX_CODON <- 3.5
DX_LETRA <- 21

TAM_CODON  <- 2.2
TAM_LETRA  <- 2.5
TAM_EJE    <- 2.4
TAM_TITULO <- 2.4
TAM_LISTA  <- 2.5
TAM_NOTA   <- 2.2

SANS <- familia_base()
MONO <- familia_mono()

# Gris de fondo para las 60 casillas que no cambian. Opaco (no alpha) por lo
# mismo que en _codigo.R: para que texto_sobre() mida lo que se ve.
GRIS_APAGADO  <- aclarar(GRIS, 0.16)
TINTA_APAGADA <- aclarar(GRIS, 0.85)


# --- Colocación, idéntica a la de la figura 1 -------------------------------
i_col  <- match(chartr("T", "U", t1$b2), ORDEN_BASES)
i_b1   <- match(chartr("T", "U", t1$b1), ORDEN_BASES)
i_b3   <- match(chartr("T", "U", t1$b3), ORDEN_BASES)
i_fila <- (i_b1 - 1L) * length(ORDEN_BASES) + i_b3

celdas <- transform(
  t1,
  xmin = X_REJILLA + (i_col - 1L) * W_COL,
  ymax = Y_TOPE    - (i_fila - 1L) * H_FILA
)
celdas$xmax <- celdas$xmin + W_COL
celdas$ymin <- celdas$ymax - H_FILA
celdas$y    <- (celdas$ymin + celdas$ymax) / 2

celdas$cambia <- celdas$codon %in% dif$codon
# El aminoácido que se muestra es el ESTÁNDAR; la flecha de la derecha dice a
# qué cambia. Mostrar el mitocondrial acá haría la figura ilegible.
celdas$letra  <- ifelse(celdas$aa == "*", "–", celdas$aa)

apagadas  <- subset(celdas, !cambia)
marcadas  <- subset(celdas,  cambia)
marcadas$aa_mito <- dif$aa_mito[match(marcadas$codon, dif$codon)]
marcadas$letra_mito <- ifelse(marcadas$aa_mito == "*", "–", marcadas$aa_mito)

# La lista, centrada verticalmente sobre la rejilla.
lista <- dif
lista$y <- (Y_REJILLA + Y_TOPE) / 2 +
           ((nrow(lista) - 1) / 2 - (seq_len(nrow(lista)) - 1L)) * PASO_LISTA

cabeceras <- data.frame(base = ORDEN_BASES,
                        x = X_REJILLA + (seq_along(ORDEN_BASES) - 0.5) * W_COL)
prim <- data.frame(base = ORDEN_BASES,
                   y = Y_TOPE - (seq_along(ORDEN_BASES) - 0.5) * 4 * H_FILA)
separadores <- data.frame(y = Y_TOPE - (0:4) * 4 * H_FILA)

NOTA <- sprintf(paste("Tabla 2 del NCBI. Existen %d tablas de traducción.",
                      "Las %d casillas restantes son idénticas a la estándar."),
                N_TABLAS_NCBI, 64L - nrow(dif))


construir <- function() {
  ggplot() +
    # --- Las 60 casillas que no cambian: gris, apagadas ---
    geom_rect(data = apagadas,
              aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
              fill = GRIS_APAGADO, colour = "white", linewidth = 0.25) +
    geom_text(data = apagadas, aes(x = xmin + DX_CODON, y = y, label = codon_arn),
              family = MONO, size = TAM_CODON, colour = TINTA_APAGADA, hjust = 0) +
    geom_text(data = apagadas, aes(x = xmin + DX_LETRA, y = y, label = letra),
              family = SANS, size = TAM_LETRA, colour = TINTA_APAGADA) +

    # --- Las cuatro que sí ---
    geom_rect(data = marcadas,
              aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
              fill = alpha(NARANJA, 0.22), colour = NARANJA, linewidth = 0.7) +
    geom_text(data = marcadas, aes(x = xmin + DX_CODON, y = y, label = codon_arn),
              family = MONO, size = TAM_CODON, colour = NARANJA, fontface = "bold",
              hjust = 0) +
    geom_text(data = marcadas, aes(x = xmin + DX_LETRA, y = y, label = letra),
              family = SANS, size = TAM_LETRA, colour = NARANJA,
              fontface = "bold") +

    # --- Separadores entre grupos de primera base ---
    geom_segment(data = separadores,
                 aes(x = X_REJILLA, xend = X_FIN, y = y, yend = y),
                 colour = "white", linewidth = 0.8) +

    # --- Lista de los cuatro cambios ---
    geom_text(data = lista, aes(x = X_LISTA, y = y, label = texto),
              family = MONO, size = TAM_LISTA, colour = NARANJA, hjust = 0) +

    # --- Rótulos de la rejilla ---
    geom_text(data = cabeceras, aes(x = x, y = Y_CABEZA, label = base),
              family = MONO, size = TAM_EJE, colour = GRIS) +
    geom_text(data = data.frame(1), aes(x = (X_REJILLA + X_FIN) / 2, y = Y_TITULO),
              label = "Segunda base", family = SANS, size = TAM_TITULO,
              colour = GRIS) +
    geom_text(data = prim, aes(x = X_REJILLA - 4, y = y, label = base),
              family = MONO, size = TAM_EJE, colour = GRIS) +
    geom_text(data = data.frame(1), aes(x = 3.5, y = (Y_REJILLA + Y_TOPE) / 2),
              label = "Primera base", family = SANS, size = TAM_TITULO,
              colour = GRIS, angle = 90) +

    geom_text(data = data.frame(1), aes(x = X_REJILLA, y = Y_NOTA), label = NOTA,
              family = SANS, size = TAM_NOTA, colour = GRIS, hjust = 0) +

    coord_cartesian(xlim = c(0, ANCHO_PANEL), ylim = c(0, ALTO_PANEL),
                    expand = FALSE, clip = "off") +
    labs(caption = paste("Diferencias calculadas comparando las tablas 1 y 2 del",
                         "NCBI vía Biostrings, no transcritas a mano.")) +
    tema_esquema()
}


if (!interactive()) {
  m_lista <- media_ancho(lista$texto, TAM_LISTA, AVANCE_MONO)
  m_nota  <- media_ancho(NOTA, TAM_NOTA)

  stopifnot(
    # --- Lo que la figura afirma ---
    nrow(dif) == 4L,
    identical(dif$codon, CODONES_ESPERADOS),
    identical(dif$codon_arn_std, c("AGA", "AGG", "AUA", "UGA")),
    # dirección de cada cambio, una por una
    dif$aa_std[dif$codon == "TGA"] == "*" && dif$aa_mito[dif$codon == "TGA"] == "W",
    dif$aa_std[dif$codon == "AGA"] == "R" && dif$aa_mito[dif$codon == "AGA"] == "*",
    dif$aa_std[dif$codon == "AGG"] == "R" && dif$aa_mito[dif$codon == "AGG"] == "*",
    dif$aa_std[dif$codon == "ATA"] == "I" && dif$aa_mito[dif$codon == "ATA"] == "M",
    # el balance de paros: la tabla 2 pierde UGA y gana AGA y AGG
    sum(t1$aa == "*") == 3L, sum(t2$aa == "*") == 4L,
    nrow(apagadas) == 60L, nrow(marcadas) == 4L,

    # --- Nada se sale del panel, nada se encima ---
    X_FIN < X_LISTA,
    all(X_LISTA + 2 * m_lista <= ANCHO_PANEL),
    min(lista$y) > Y_NOTA + TAM_NOTA + 2,
    max(lista$y) < Y_TOPE,
    Y_TITULO + TAM_TITULO <= ALTO_PANEL,
    X_REJILLA + 2 * m_nota <= ANCHO_PANEL,
    DX_CODON + 2 * media_ancho(celdas$codon_arn, TAM_CODON, AVANCE_MONO)[1] < DX_LETRA,
    DX_LETRA < W_COL - 2
  )

  message(sprintf("  diferencias entre tabla 1 y tabla 2: %d codones", nrow(dif)))
  for (i in seq_len(nrow(dif))) {
    message(sprintf("    %s   %-4s -> %-4s", dif$codon_arn_std[i], dif$de[i], dif$a[i]))
  }
  message(sprintf("  codones de paro: %d en la tabla 1, %d en la tabla 2",
                  sum(t1$aa == "*"), sum(t2$aa == "*")))
  message(sprintf("  casillas idénticas: %d de 64", nrow(apagadas)))

  escribir_tsv(
    data.frame(codon      = dif$codon,
               codon_arn  = dif$codon_arn_std,
               aa_estandar = dif$aa_std,   nombre_estandar = dif$de,
               aa_mito     = dif$aa_mito,  nombre_mito     = dif$a,
               stringsAsFactors = FALSE),
    "estandar-vs-mito")
  guardar(construir(), "estandar-vs-mito", 18, 12)
}
