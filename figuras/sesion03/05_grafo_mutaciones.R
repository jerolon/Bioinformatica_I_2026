## Fig. @fig-grafo (Sesión 3, § El puente)
## Aminoácidos que están a UNA mutación de distancia.
##
## Es la figura que cierra el capítulo y la que conecta con la sesión de
## matrices de sustitución. Dos aminoácidos se conectan si existe algún par de
## codones suyos que difiera en un solo nucleótido; el peso de la arista es
## cuántos pares de codones distintos los conectan.
##
## ---------------------------------------------------------------------------
## POR QUÉ NO SALE CON layout = "fr"
##
## La especificación pedía probar Fruchterman-Reingold y, si los grupos químicos
## no se separaban, agrupar a mano por clase. No se separan, y hay una razón
## medible: el grafo tiene 75 aristas de las 190 posibles (39 % de densidad) y
## sólo el 29 % de ellas es intra-clase. Un layout por fuerzas sobre un grafo así
## de denso y así de poco modular da una maraña; se probó. Con los sectores por
## clase, en cambio, las aristas intra-clase son cuerdas cortas pegadas al
## borde y las inter-clase cruzan el centro, así que la proporción entre unas y
## otras se lee de un vistazo, que es justo lo que la figura tiene que decir.
##
## igraph se usa para construir el grafo y medir densidad y modularidad; el
## dibujo va en ggplot2 sobre coordenadas en milímetros (ggraph no está
## instalado y no vale la pena arrastrar la dependencia para un layout que de
## todos modos hay que calcular a mano).
## ---------------------------------------------------------------------------
##
## OJO CON EL NÚMERO DEL PIE. El 29 % suelto se lee como "poco" y contradice al
## capítulo. El pie lo compara contra el nulo de códigos barajados (Freeland &
## Hurst), que es lo que le da sentido: 23 % de media, y el código real supera
## al 98.5 % de ellos. El sesgo es real y modesto, y así hay que contarlo.
##
## Sin título dentro del SVG: el caption vive en el .qmd.
##
## Regenerar:  Rscript figuras/sesion03/05_grafo_mutaciones.R

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

suppressPackageStartupMessages(library(igraph))

# El nulo se remuestrea; con semilla fija el SVG sale byte a byte igual al
# regenerar, que es la regla de esta carpeta.
set.seed(20240603)
N_PERMUTACIONES <- 20000L


# --- El grafo ---------------------------------------------------------------
d  <- tabla_codigo("1")
sp <- d[d$aa != "*", ]        # los codones de paro no son un aminoácido

# Todos los pares de codones con sentido a distancia de Hamming 1.
pares <- utils::combn(sp$codon, 2)
pos_dif <- apply(pares, 2, function(p) {
  w <- which(strsplit(p[1], "")[[1]] != strsplit(p[2], "")[[1]])
  if (length(w) == 1L) w else NA_integer_
})
ok  <- !is.na(pos_dif)
P   <- pares[, ok, drop = FALSE]
POS <- pos_dif[ok]

asignacion <- setNames(sp$aa, sp$codon)

#' Fracción de cambios NO sinónimos que conservan la clase química.
#' Se pasa la asignación codón -> aa como argumento para poder aplicarla también
#' a los códigos barajados del nulo.
frac_intra <- function(asig) {
  a1 <- asig[P[1, ]]; a2 <- asig[P[2, ]]
  ns <- a1 != a2
  mean(clases_aa[a1[ns]] == clases_aa[a2[ns]])
}

aa1_c <- asignacion[P[1, ]]
aa2_c <- asignacion[P[2, ]]
no_sin <- aa1_c != aa2_c

# Aristas: un renglón por par de aminoácidos, con el número de caminos.
clave <- paste(pmin(aa1_c[no_sin], aa2_c[no_sin]),
               pmax(aa1_c[no_sin], aa2_c[no_sin]))
tab <- table(clave)
aristas <- data.frame(
  aa1  = sub(" .*", "", names(tab)),
  aa2  = sub(".* ", "", names(tab)),
  peso = as.integer(tab),
  stringsAsFactors = FALSE
)
aristas$misma_clase <- clases_aa[aristas$aa1] == clases_aa[aristas$aa2]

g <- igraph::graph_from_data_frame(aristas[, c("aa1", "aa2")],
                                   directed = FALSE,
                                   vertices = data.frame(name = sort(unique(sp$aa))))
igraph::E(g)$weight <- aristas$peso

# --- Las cifras del pie -----------------------------------------------------
FRAC_ARISTA <- mean(aristas$misma_clase)                              # por arista
FRAC_CAMINO <- sum(aristas$peso[aristas$misma_clase]) / sum(aristas$peso)

# Nulo de Freeland & Hurst: se conserva la estructura de bloques de sinónimos
# del código y se permuta qué aminoácido va en cada bloque. Es el nulo correcto:
# uno que barajara codones sueltos destruiría la degeneración y compararía
# contra códigos que no son códigos.
bloques <- split(sp$codon, sp$aa)
nulo <- replicate(N_PERMUTACIONES, {
  perm <- sample(names(bloques))
  frac_intra(setNames(rep(perm, lengths(bloques)), unlist(bloques)))
})
NULO_MEDIA <- mean(nulo)
P_VALOR    <- mean(nulo >= FRAC_CAMINO)
PERCENTIL  <- mean(nulo < FRAC_CAMINO)


# --- Geometría, en milímetros -----------------------------------------------
# guardar(w = 16, h = 14) con 2 mm de margen: panel de 156 x 132 mm.
ANCHO_PANEL <- 156
ALTO_PANEL  <- 132

CX <- 78; CY <- 80          # centro del anillo
R  <- 40                    # radio donde viven los nodos
R_ETIQ <- R + 10            # rótulos de clase, por fuera

HUECO_SECTOR <- 11          # grados de separación entre clases

Y_LEYENDA <- 24
Y_NOTA    <- 14

TAM_LETRA <- 2.8
TAM_CLASE <- 2.3
TAM_LEY   <- 2.1
TAM_NOTA  <- 2.2

SANS <- familia_base()

# --- Colocación por sectores ------------------------------------------------
# Un sector por clase, con ancho proporcional a cuántos aminoácidos tiene, y los
# nodos repartidos parejo dentro del sector. Se recorre NIVELES_CLASE para que
# el orden alrededor del círculo sea el mismo de la leyenda de las figuras 1 y 2.
n_codones <- table(sp$aa)
clases_presentes <- NIVELES_CLASE[NIVELES_CLASE %in% clases_aa[names(n_codones)]]

nodos <- do.call(rbind, lapply(clases_presentes, function(cl) {
  aas <- sort(names(n_codones)[clases_aa[names(n_codones)] == cl])
  data.frame(aa = aas, clase = cl, stringsAsFactors = FALSE)
}))
nodos$n <- as.integer(n_codones[nodos$aa])

n_clases   <- length(clases_presentes)
grados_utiles <- 360 - n_clases * HUECO_SECTOR
paso_nodo  <- grados_utiles / nrow(nodos)

tam_clase <- table(factor(nodos$clase, levels = clases_presentes))
ini_sector <- cumsum(c(0, head(as.integer(tam_clase) * paso_nodo + HUECO_SECTOR, -1)))
names(ini_sector) <- clases_presentes

idx_en_clase <- ave(seq_len(nrow(nodos)), nodos$clase, FUN = seq_along)
nodos$angulo <- ini_sector[nodos$clase] + (idx_en_clase - 0.5) * paso_nodo + HUECO_SECTOR / 2
nodos$x <- CX + R * cos(nodos$angulo * pi / 180)
nodos$y <- CY + R * sin(nodos$angulo * pi / 180)

# Radio del nodo: el ÁREA es proporcional al número de codones, así que el radio
# va con la raíz. Con radio proporcional a n, un aminoácido de 6 codones se vería
# seis veces más grande de lo que le toca.
nodos$r <- 2.4 + 0.85 * sqrt(nodos$n)

circulos <- do.call(rbind, lapply(seq_len(nrow(nodos)), function(i) {
  transform(circulo(nodos$x[i], nodos$y[i], nodos$r[i], id = i),
            clase = nodos$clase[i])
}))
circulos$clase <- clase_ordenada(circulos$clase)
nodos$tinta <- texto_sobre(unname(colores_clase[nodos$clase]))

# Rótulo de cada clase, en la bisectriz de su sector.
ang_clase <- ini_sector + as.integer(tam_clase) * paso_nodo / 2 + HUECO_SECTOR / 2
rot_clase <- data.frame(
  clase = clases_presentes,
  x = CX + R_ETIQ * cos(ang_clase * pi / 180),
  y = CY + R_ETIQ * sin(ang_clase * pi / 180),
  stringsAsFactors = FALSE
)

# --- Aristas ----------------------------------------------------------------
pos <- setNames(seq_len(nrow(nodos)), nodos$aa)
seg <- transform(
  aristas,
  x    = nodos$x[pos[aristas$aa1]], y    = nodos$y[pos[aristas$aa1]],
  xend = nodos$x[pos[aristas$aa2]], yend = nodos$y[pos[aristas$aa2]]
)
# Se recortan contra el borde de los dos nodos: así ninguna línea entra en un
# círculo y las letras quedan limpias.
recortar <- function(s) {
  dx <- s$xend - s$x; dy <- s$yend - s$y
  L  <- sqrt(dx^2 + dy^2)
  r1 <- nodos$r[pos[s$aa1]]; r2 <- nodos$r[pos[s$aa2]]
  transform(s,
            x = s$x + dx * r1 / L,       y = s$y + dy * r1 / L,
            xend = s$xend - dx * r2 / L, yend = s$yend - dy * r2 / L)
}
seg <- recortar(seg)

# --- Leyenda y pie ----------------------------------------------------------
W_SWATCH <- 4.5; H_SWATCH <- 3; SEP_TXT <- 1.6; SEP_ITEM <- 6
ley <- data.frame(clase = clases_presentes, stringsAsFactors = FALSE)
ley$ancho <- W_SWATCH + SEP_TXT + 2 * media_ancho(ley$clase, TAM_LEY)
ley$x <- cumsum(c(0, head(ley$ancho + SEP_ITEM, -1)))
ley$x <- ley$x + (ANCHO_PANEL - (sum(ley$ancho) + SEP_ITEM * (nrow(ley) - 1))) / 2

NOTA <- sprintf(paste("El %.0f %% de las %d conexiones une aminoácidos de la",
                      "misma clase química (%.0f %% contando cada camino)."),
                100 * FRAC_ARISTA, nrow(aristas), 100 * FRAC_CAMINO)

# El pie va partido a mano en tres renglones. El caption de ggplot no hace wrap
# solo: si se deja en una línea, se sale del SVG por la derecha y no hay aviso.
# ANCHO_PIE es la cota que comprueba el stopifnot del final.
ANCHO_PIE <- 108L
PIE <- paste(
  "Aristas: pares de aminoácidos a un solo cambio de nucleótido. El grosor es cuántos caminos los conectan;",
  "el tamaño del nodo, su número de codones. Un tercio parece poco, pero en códigos barajados al azar esa",
  sprintf("fracción vale %.0f %% de media: el código real supera al %.1f %% de ellos (%s permutaciones).",
          100 * NULO_MEDIA, 100 * PERCENTIL,
          formatC(N_PERMUTACIONES, big.mark = ",")),
  sep = "\n")


construir <- function() {
  ggplot() +
    # --- Aristas: primero las grises, para que las naranjas queden encima ---
    geom_segment(data = subset(seg, !misma_clase),
                 aes(x = x, xend = xend, y = y, yend = yend, linewidth = peso),
                 colour = alpha(GRIS, 0.30), lineend = "round") +
    geom_segment(data = subset(seg, misma_clase),
                 aes(x = x, xend = xend, y = y, yend = yend, linewidth = peso),
                 colour = NARANJA, lineend = "round") +

    # --- Nodos ---
    geom_polygon(data = circulos, aes(x = x, y = y, group = id, fill = clase),
                 colour = "white", linewidth = 0.35) +
    geom_text(data = nodos, aes(x = x, y = y, label = aa, colour = tinta),
              family = SANS, size = TAM_LETRA, fontface = "bold") +
    geom_text(data = rot_clase, aes(x = x, y = y, label = clase),
              family = SANS, size = TAM_CLASE, colour = GRIS) +

    # --- Leyenda y nota ---
    geom_rect(data = ley,
              aes(xmin = x, xmax = x + W_SWATCH,
                  ymin = Y_LEYENDA - H_SWATCH / 2, ymax = Y_LEYENDA + H_SWATCH / 2,
                  fill = clase), colour = NA) +
    geom_text(data = ley, aes(x = x + W_SWATCH + SEP_TXT, y = Y_LEYENDA,
                              label = clase),
              family = SANS, size = TAM_LEY, colour = TEXTO, hjust = 0) +
    geom_text(data = data.frame(1), aes(x = ANCHO_PANEL / 2, y = Y_NOTA),
              label = NOTA, family = SANS, size = TAM_NOTA, colour = NARANJA) +

    scale_fill_manual(values = colores_clase, guide = "none") +
    scale_colour_identity() +
    scale_linewidth_continuous(range = c(0.25, 1.5), guide = "none") +
    coord_cartesian(xlim = c(0, ANCHO_PANEL), ylim = c(0, ALTO_PANEL),
                    expand = FALSE, clip = "off") +
    labs(caption = PIE) +
    tema_esquema()
}


if (!interactive()) {
  dens <- igraph::edge_density(g)
  mod  <- igraph::modularity(g, membership = as.integer(factor(clases_aa[igraph::V(g)$name])))
  esperado_azar <- sum(choose(table(clases_aa[nodos$aa]), 2)) / choose(20, 2)

  m_ley  <- media_ancho(ley$clase, TAM_LEY)
  m_nota <- media_ancho(NOTA, TAM_NOTA)

  stopifnot(
    # --- El grafo ---
    nrow(nodos) == 20L,                       # los 20 aminoácidos, sin paros
    !any(nodos$aa == "*"),
    sum(nodos$n) == 61L,
    igraph::vcount(g) == 20L,
    igraph::ecount(g) == nrow(aristas),
    all(aristas$peso >= 1L),
    all(aristas$aa1 != aristas$aa2),          # sin lazos
    !any(duplicated(paste(pmin(aristas$aa1, aristas$aa2),
                          pmax(aristas$aa1, aristas$aa2)))),
    igraph::is_connected(g),                  # se llega de cualquier aa a otro

    # --- Lo que afirma el pie ---
    FRAC_CAMINO > esperado_azar,              # hay sesgo, no sólo tamaños de clase
    FRAC_CAMINO > NULO_MEDIA,
    P_VALOR < 0.05,                           # y es significativo
    # ...y a la vez NO es mayoría: el pie tiene que decirlo comparando, no solo.
    FRAC_ARISTA < 0.5,

    # --- El anillo ---
    length(unique(round(nodos$angulo, 6))) == 20L,       # sin nodos encimados
    max(nodos$r) < 2 * R * sin(pi * paso_nodo / 360),    # los círculos no se tocan
    min(nodos$x - nodos$r) > 0, max(nodos$x + nodos$r) < ANCHO_PANEL,
    min(nodos$y - nodos$r) > Y_LEYENDA + H_SWATCH,
    max(nodos$y + nodos$r) < ALTO_PANEL,

    # --- Nada se sale del panel ---
    min(ley$x) >= 0, max(ley$x + ley$ancho) <= ANCHO_PANEL,
    ANCHO_PANEL / 2 - m_nota >= 0,
    Y_NOTA + TAM_NOTA < Y_LEYENDA - H_SWATCH,
    # los rótulos de clase van por fuera del anillo y tampoco pueden invadir
    min(rot_clase$y) > Y_LEYENDA + H_SWATCH,
    max(rot_clase$y) < ALTO_PANEL,
    # el pie no hace wrap solo: cada renglón tiene que caber a lo ancho
    all(nchar(strsplit(PIE, "\n", fixed = TRUE)[[1]]) <= ANCHO_PIE)
  )

  message(sprintf("  %d nodos, %d aristas (densidad %.2f, %d de %d posibles)",
                  igraph::vcount(g), nrow(aristas), dens, nrow(aristas), choose(20, 2)))
  message(sprintf("  caminos mutacionales no sinónimos: %d; sinónimos: %d",
                  sum(no_sin), sum(!no_sin)))
  message("")
  message("  FRACCIÓN INTRA-CLASE")
  message(sprintf("    por arista única            %5.1f %%  (%d de %d)",
                  100 * FRAC_ARISTA, sum(aristas$misma_clase), nrow(aristas)))
  message(sprintf("    por camino mutacional       %5.1f %%  (%d de %d)",
                  100 * FRAC_CAMINO, sum(aristas$peso[aristas$misma_clase]),
                  sum(aristas$peso)))
  message(sprintf("    esperado por tamaño de clase %5.1f %%", 100 * esperado_azar))
  message(sprintf("    nulo de códigos barajados   %5.1f %%  (n = %s)",
                  100 * NULO_MEDIA, formatC(N_PERMUTACIONES, big.mark = ",")))
  message(sprintf("    P(nulo >= real) = %.4f  ->  supera al %.1f %% de los códigos",
                  P_VALOR, 100 * PERCENTIL))
  message(sprintf("    modularidad de las clases sobre el grafo: %.3f", mod))
  message("")
  message("  Nota: el capítulo dice que las conexiones caen 'preferentemente'")
  message("  dentro de cada clase. En términos absolutos son un tercio; lo que")
  message("  es cierto es que son MÁS de lo que tocaría al azar. El pie de la")
  message("  figura lo dice así para no contradecir al texto ni exagerarlo.")

  escribir_tsv(aristas[order(-aristas$peso, aristas$aa1, aristas$aa2), ],
               "grafo-mutaciones")
  guardar(construir(), "grafo-mutaciones", 16, 14)
}
