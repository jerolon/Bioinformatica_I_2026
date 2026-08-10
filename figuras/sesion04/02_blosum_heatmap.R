## Fig. @fig-matriz (Sesión 4, § Cuatro números que rompen la intuición)
## BLOSUM62 completa, con los aminoácidos ordenados por grupo fisicoquímico.
##
## El orden ES la figura. En orden alfabético los 400 números se ven como ruido;
## agrupados, aparecen bloques claros en la diagonal —los alifáticos entre sí,
## los ácidos entre sí— y se ve de golpe que la matriz tiene estructura. El
## script mide las dos cosas y el stopifnot exige que el orden agrupado tenga
## más contraste diagonal que el alfabético.
##
## ---------------------------------------------------------------------------
## DOS AGRUPACIONES QUE NO COINCIDEN, Y ES A PROPÓSITO
##
## El ORDEN de filas y columnas es el que pedía la especificación:
##     I V L F M W Y C | A G P S T | N Q H | K R | D E
## que es la agrupación estructural con la que se suele mostrar BLOSUM, y la
## que hace salir los bloques.
##
## La FRANJA DE COLOR de los márgenes usa `clases_aa` de la sesión 3, como
## también pedía la especificación, para que las tres sesiones se lean como una
## familia. Las dos agrupaciones no son la misma: Y es "polar" en la sesión 3 y
## cae en el bloque alifático-aromático de acá; C y G son "especiales" y quedan
## repartidos; H es "básico" y cae con N y Q.
##
## Se dejó así en vez de forzarlas a coincidir porque la discrepancia es real y
## es informativa: qué tan parecidos son dos aminoácidos depende de qué
## propiedad se mire, y ninguna de las dos clasificaciones es LA correcta. Los
## bloques de la diagonal salen igual.
## ---------------------------------------------------------------------------
##
## Sin título dentro del SVG: el caption vive en el .qmd.
##
## Regenerar:  Rscript figuras/sesion04/02_blosum_heatmap.R

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


# --- El orden ---------------------------------------------------------------
GRUPOS <- list(
  "alifáticos y aromáticos" = c("I", "V", "L", "F", "M", "W", "Y", "C"),
  "pequeños"                = c("A", "G", "P", "S", "T"),
  "polares"                 = c("N", "Q", "H"),
  "básicos"                 = c("K", "R"),
  "ácidos"                  = c("D", "E")
)
ORDEN <- unlist(GRUPOS, use.names = FALSE)


# --- Los datos --------------------------------------------------------------
M <- blosum62()[ORDEN, ORDEN]

celdas <- expand.grid(fila = ORDEN, col = ORDEN, stringsAsFactors = FALSE)
celdas$score <- mapply(function(i, j) M[i, j], celdas$fila, celdas$col)
celdas$i <- match(celdas$fila, ORDEN)
celdas$j <- match(celdas$col,  ORDEN)


# --- Geometría, en milímetros -----------------------------------------------
# guardar(w = 18, h = 16) con 2 mm de margen: panel de 176 x 152 mm.
ANCHO_PANEL <- 176
ALTO_PANEL  <- 152

N <- length(ORDEN)

# La celda es CUADRADA, y con 20 filas la altura es lo que manda: el panel mide
# 152 mm de alto y hay que descontar los rótulos de grupo, las letras, la franja
# y la barra de color. De ahí sale el lado, no de repartir el ancho.
LADO <- 5.9                       # 20 x 5.9 = 118 mm

W_FRANJA   <- 3                   # franja de clase química, pegada a la rejilla
SEP_FRANJA <- 1.2
SEP_LETRA  <- 2.4

# La rejilla va centrada a lo ancho: sobran 58 mm que se reparten en dos
# márgenes de 29, y en el izquierdo caben de sobra la franja y las letras.
X_REJILLA <- (ANCHO_PANEL - N * LADO) / 2
X_FIN     <- X_REJILLA + N * LADO

Y_TOPE    <- 136
Y_REJILLA <- Y_TOPE - N * LADO

Y_GRUPOS <- 149                   # nombres de los grupos, arriba del todo

Y_BARRA <- 10                     # barra de color de los scores
H_BARRA <- 3.5
W_BARRA <- 52
X_BARRA <- X_REJILLA
Y_BARRA_TXT <- Y_BARRA - 3.4

Y_LEY <- 3                        # leyenda de clases químicas, al pie
W_SWATCH <- 4.5; H_SWATCH <- 3

TAM_SCORE <- 1.8
TAM_LETRA <- 2.3
TAM_GRUPO <- 2.0
TAM_BARRA <- 1.9
TAM_LEY   <- 1.9

SANS <- familia_base()
MONO <- familia_mono()

# Tope de la escala. BLOSUM62 va de -4 a +11, pero el +11 es sólo W/W: con la
# escala estirada hasta 11 todo el resto queda casi blanco. Se recorta a 6 y se
# avisa en el pie cuántas celdas quedaron al tope.
TOPE <- 6


# --- Colocación -------------------------------------------------------------
# Fila 1 arriba: se cuenta desde Y_TOPE hacia abajo.
celdas$xmin <- X_REJILLA + (celdas$j - 1L) * LADO
celdas$xmax <- celdas$xmin + LADO
celdas$ymax <- Y_TOPE - (celdas$i - 1L) * LADO
celdas$ymin <- celdas$ymax - LADO
celdas$x <- (celdas$xmin + celdas$xmax) / 2
celdas$y <- (celdas$ymin + celdas$ymax) / 2
celdas$score_recortado <- pmin(celdas$score, TOPE)
N_TOPE <- sum(celdas$score > TOPE)

# Letras de los ejes.
ejes <- data.frame(
  aa = ORDEN,
  x  = X_REJILLA + (seq_len(N) - 0.5) * LADO,
  y  = Y_TOPE    - (seq_len(N) - 0.5) * LADO,
  clase = unname(clases_aa[ORDEN]),
  stringsAsFactors = FALSE
)
ejes$color <- unname(colores_clase[ejes$clase])

# Separadores entre grupos: van en las fronteras acumuladas.
cortes <- cumsum(lengths(GRUPOS))
sep_x <- X_REJILLA + cortes * LADO
sep_y <- Y_TOPE    - cortes * LADO

# Etiqueta de cada grupo, sobre la rejilla.
ini <- c(0, head(cortes, -1))
grupos_rot <- data.frame(
  etiqueta = names(GRUPOS),
  x = X_REJILLA + (ini + lengths(GRUPOS) / 2) * LADO,
  stringsAsFactors = FALSE
)

# Barra de color de los scores.
barra <- data.frame(v = seq(min(celdas$score), TOPE, length.out = 160))
barra$xmin <- X_BARRA + (barra$v - min(barra$v)) / diff(range(barra$v)) * W_BARRA
barra$xmax <- c(barra$xmin[-1], X_BARRA + W_BARRA)
marcas <- data.frame(v = c(-4, -2, 0, 2, 4, 6))
marcas$x <- X_BARRA + (marcas$v - min(barra$v)) / diff(range(barra$v)) * W_BARRA
marcas$txt <- ifelse(marcas$v == TOPE, paste0("≥ ", TOPE), as.character(marcas$v))

# Leyenda de clases químicas (las de la sesión 3), al pie y centrada.
clases_presentes <- NIVELES_CLASE[NIVELES_CLASE %in% ejes$clase]
ley <- data.frame(clase = clases_presentes, stringsAsFactors = FALSE)
ley$ancho <- W_SWATCH + 1.4 + 2 * media_ancho(ley$clase, TAM_LEY)
ley$x <- cumsum(c(0, head(ley$ancho + 4, -1)))
ley$x <- ley$x + (ANCHO_PANEL - (sum(ley$ancho) + 4 * (nrow(ley) - 1))) / 2

PIE <- paste(
  sprintf(paste("BLOSUM62 completa. Aminoácidos ordenados por grupo",
                "fisicoquímico: ese orden es lo que hace visibles los bloques",
                "de la diagonal.")),
  sprintf(paste("La franja de los márgenes usa las clases químicas de la sesión",
                "3, que no coinciden del todo con los grupos del orden.",
                if (N_TOPE > 0) sprintf("%d celdas superan +%d.", N_TOPE, TOPE) else "")),
  sep = "\n")


construir <- function() {
  ggplot() +
    # --- Los 400 scores ---
    geom_rect(data = celdas,
              aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax,
                  fill = score_recortado),
              colour = "white", linewidth = 0.25) +
    geom_text(data = celdas, aes(x = x, y = y, label = score),
              family = SANS, size = TAM_SCORE, colour = TEXTO) +

    # --- Separadores de grupo, gruesos ---
    geom_segment(data = data.frame(x = sep_x[-length(sep_x)]),
                 aes(x = x, xend = x, y = Y_REJILLA, yend = Y_TOPE),
                 colour = TEXTO, linewidth = 0.7) +
    geom_segment(data = data.frame(y = sep_y[-length(sep_y)]),
                 aes(x = X_REJILLA, xend = X_FIN, y = y, yend = y),
                 colour = TEXTO, linewidth = 0.7) +
    annotate("rect", xmin = X_REJILLA, xmax = X_FIN,
             ymin = Y_REJILLA, ymax = Y_TOPE,
             fill = NA, colour = TEXTO, linewidth = 0.7) +

    # --- Franja de clase química en los dos márgenes ---
    geom_rect(data = ejes,
              aes(xmin = x - LADO / 2, xmax = x + LADO / 2,
                  ymin = Y_TOPE + SEP_FRANJA,
                  ymax = Y_TOPE + SEP_FRANJA + W_FRANJA, fill = NULL),
              fill = ejes$color, colour = "white", linewidth = 0.2) +
    geom_rect(data = ejes,
              aes(xmin = X_REJILLA - SEP_FRANJA - W_FRANJA,
                  xmax = X_REJILLA - SEP_FRANJA,
                  ymin = y - LADO / 2, ymax = y + LADO / 2, fill = NULL),
              fill = ejes$color, colour = "white", linewidth = 0.2) +

    # --- Letras de los ejes ---
    geom_text(data = ejes,
              aes(x = x, y = Y_TOPE + SEP_FRANJA + W_FRANJA + SEP_LETRA,
                  label = aa),
              family = MONO, size = TAM_LETRA, colour = TEXTO, vjust = 0) +
    geom_text(data = ejes,
              aes(x = X_REJILLA - SEP_FRANJA - W_FRANJA - SEP_LETRA, y = y,
                  label = aa),
              family = MONO, size = TAM_LETRA, colour = TEXTO, hjust = 1) +

    # --- Nombres de los grupos, arriba del todo ---
    geom_text(data = grupos_rot,
              aes(x = x, y = Y_GRUPOS, label = etiqueta),
              family = SANS, size = TAM_GRUPO, colour = GRIS, vjust = 1) +

    # --- Barra de color de los scores ---
    geom_rect(data = barra,
              aes(xmin = xmin, xmax = xmax, ymin = Y_BARRA,
                  ymax = Y_BARRA + H_BARRA, fill = v), colour = NA) +
    geom_text(data = marcas, aes(x = x, y = Y_BARRA_TXT, label = txt),
              family = SANS, size = TAM_BARRA, colour = GRIS) +
    geom_text(data = data.frame(1),
              aes(x = X_BARRA, y = Y_BARRA + H_BARRA + 2.4),
              label = "Score de BLOSUM62", family = SANS, size = TAM_BARRA,
              colour = GRIS, hjust = 0) +

    # --- Leyenda de clases químicas ---
    geom_rect(data = ley,
              aes(xmin = x, xmax = x + W_SWATCH,
                  ymin = Y_LEY - H_SWATCH / 2, ymax = Y_LEY + H_SWATCH / 2),
              fill = unname(colores_clase[ley$clase]), colour = NA) +
    geom_text(data = ley, aes(x = x + W_SWATCH + 1.4, y = Y_LEY, label = clase),
              family = SANS, size = TAM_LEY, colour = TEXTO, hjust = 0) +

    scale_fill_gradient2(low = AZUL, mid = "white", high = NARANJA,
                         midpoint = 0, limits = c(min(celdas$score), TOPE),
                         oob = scales::squish, guide = "none") +
    coord_cartesian(xlim = c(0, ANCHO_PANEL), ylim = c(0, ALTO_PANEL),
                    expand = FALSE, clip = "off") +
    labs(caption = PIE) +
    tema_esquema()
}


if (!interactive()) {
  # ¿De verdad el orden agrupado hace más visible la estructura? Se mide con el
  # contraste entre los scores de dentro del grupo y los de fuera, y se compara
  # contra el orden alfabético. Si el orden agrupado no gana, esta figura no
  # tiene razón de ser y el stopifnot lo dice.
  grupo_de <- setNames(rep(names(GRUPOS), lengths(GRUPOS)), ORDEN)
  fuera_diag <- subset(celdas, fila != col)
  mismo_grupo <- grupo_de[fuera_diag$fila] == grupo_de[fuera_diag$col]
  contraste_grupo <- mean(fuera_diag$score[mismo_grupo]) -
                     mean(fuera_diag$score[!mismo_grupo])

  # El mismo contraste, pero definiendo los "grupos" como bloques contiguos de
  # igual tamaño sobre el orden ALFABÉTICO: el control.
  alf <- sort(ORDEN)
  bloque_alf <- setNames(rep(seq_along(GRUPOS), lengths(GRUPOS)), alf)
  mismo_alf <- bloque_alf[fuera_diag$fila] == bloque_alf[fuera_diag$col]
  contraste_alf <- mean(fuera_diag$score[mismo_alf]) -
                   mean(fuera_diag$score[!mismo_alf])

  stopifnot(
    # --- Los datos ---
    length(ORDEN) == 20L, !anyDuplicated(ORDEN),
    setequal(ORDEN, rownames(blosum62())),
    nrow(celdas) == 400L,
    isSymmetric(M),
    all(diag(M) >= 4L),

    # --- Lo que la figura afirma ---
    contraste_grupo > 0,                    # dentro del grupo se puntúa mejor
    contraste_grupo > 2 * contraste_alf,    # y mucho mejor que en orden alfabético

    # --- Nada se sale del panel ---
    X_REJILLA > 0, X_FIN <= ANCHO_PANEL,
    Y_REJILLA > 0,
    # letras y franja de arriba, bajo los rótulos de grupo
    Y_TOPE + SEP_FRANJA + W_FRANJA + SEP_LETRA + TAM_LETRA <= Y_GRUPOS - TAM_GRUPO,
    Y_GRUPOS <= ALTO_PANEL,
    # franja y letras de la izquierda, dentro del margen
    X_REJILLA - SEP_FRANJA - W_FRANJA - SEP_LETRA -
      2 * max(media_ancho(ORDEN, TAM_LETRA, AVANCE_MONO)) >= 0,
    # barra de color y leyenda, bajo la rejilla y sin encimarse
    Y_BARRA + H_BARRA + 2.4 + TAM_BARRA < Y_REJILLA,
    Y_BARRA_TXT - TAM_BARRA > Y_LEY + H_SWATCH / 2,
    Y_LEY - H_SWATCH / 2 >= 0,
    min(ley$x) >= 0, max(ley$x + ley$ancho) <= ANCHO_PANEL,
    X_BARRA + W_BARRA <= ANCHO_PANEL,
    TAM_SCORE < LADO - 1
  )

  message(sprintf("  BLOSUM62 ordenada en %d grupos: %s", length(GRUPOS),
                  paste(sprintf("%s (%d)", names(GRUPOS), lengths(GRUPOS)),
                        collapse = ", ")))
  message(sprintf("  scores de %+d a %+d; %d celdas por encima de +%d (se recortan)",
                  min(celdas$score), max(celdas$score), N_TOPE, TOPE))
  message(sprintf("  contraste dentro/fuera de grupo: %+.2f puntos", contraste_grupo))
  message(sprintf("  el mismo contraste con bloques alfabéticos: %+.2f puntos",
                  contraste_alf))
  message("  -> el orden agrupado hace visible una estructura que el alfabético no")

  guardar(construir(), "blosum62-heatmap", 18, 16)
}
