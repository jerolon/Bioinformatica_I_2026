## Fig. @fig-jerarquia (Sesión 2-3, § Del locus a la proteína)
## Del locus genómico a la proteína: cinco niveles, cinco secuencias distintas.
##
## Esquema puro, sin datos: no hay ningún gen real detrás. Lo que SÍ se calcula
## es la geometría. Las longitudes de los cinco niveles se derivan unas de otras
## y no se acomodan a ojo:
##
##   pre-mRNA = del inicio del exón 1 al final del exón 3 (sin promotor ni flanco)
##   mRNA     = suma de los tres exones
##   CDS      = subintervalo del mRNA, dibujado en la MISMA x que en el nivel de
##              arriba (que es justo lo que la figura tiene que decir)
##   proteína = CDS / 3, porque tres nucleótidos son un residuo
##
## De ahí sale también la columna de la derecha, que es un mini gráfico de
## barras con el número relativo de monómeros por nivel. No está tecleada: se
## mide sobre el dibujo. Por eso se ve que van encogiendo.
##
## La columna compara MONÓMEROS, no milímetros de molécula: 78 nucleótidos
## contra 7 residuos. Es la comparación honesta entre alfabetos distintos.
##
## Sin título dentro del SVG: el caption vive en el .qmd.
##
## Regenerar:  Rscript figuras/sesion02/01_jerarquia.R

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


# --- Lo que afirma la figura ------------------------------------------------
# Único lugar donde se teclean los nombres y las etiquetas de tipo. La columna
# `tipo` es el punto conceptual del capítulo: qué existe en la célula y qué es
# un intervalo que alguien definió sobre otra secuencia.
NIVELES <- data.frame(
  orden  = 1:5,
  nombre = c("Locus genómico", "Pre-mRNA", "mRNA maduro", "CDS", "Proteína"),
  tipo   = c("físico\n(cromosoma)", "físico,\ntransitorio", "físico",
             "constructo\n(un intervalo)", "físico"),
  stringsAsFactors = FALSE
)

# Los tres procesos que separan un nivel del siguiente. El paso 3 -> 4 NO está
# acá a propósito: entre el mRNA y la CDS no pasa nada en la célula. Es una
# definición, y por eso se dibuja como llave punteada y no como flecha.
PROCESOS <- data.frame(
  desde   = c(1L, 2L, 4L),
  hacia   = c(2L, 3L, 5L),
  proceso = c("transcripción", "splicing, cap y poliA", "traducción"),
  stringsAsFactors = FALSE
)

DEFINICION <- "un subintervalo del mRNA,\nno otra molécula"


# --- Geometría, en milímetros -----------------------------------------------
# Con guardar(w = 16, h = 12) y 2 mm de margen a los lados, el panel mide
# 156 mm de ancho; de los 120 mm de alto, la nota de fuente se lleva ~4 mm.
# Fijando las escalas a ese rango, 1 unidad = 1 mm, y como el `size` de
# geom_text también está en mm los anchos de texto se comparan contra los
# huecos. Mismo truco que figuras/sesion01/06_git_zonas.R.
ANCHO_PANEL <- 156
ALTO_PANEL  <- 116

X_NOM_DER  <- 28     # los nombres, alineados a la derecha, terminan acá
X_BARRA    <- 30     # el dibujo empieza acá
X_TAG      <- 111    # la etiqueta físico/constructo, alineada a la izquierda
X_MINI     <- 132    # la mini barra de la columna de longitud relativa
ANCHO_MINI <- 16     # su ancho al 100%
X_PCT      <- 156    # el porcentaje, alineado a la derecha

Y_FILA  <- c(104, 82, 60, 38, 16)   # centro de cada nivel, de arriba a abajo
ALTO_B  <- 7                        # alto de las barras
RETIRO  <- 1.2                      # las flechas no tocan las barras

X_FLECHA <- 62      # columna donde bajan las flechas de proceso
X_ETIQ_P <- 65      # sus etiquetas, a la derecha de la flecha

TAM_NOMBRE <- 2.5
TAM_TAG    <- 2.0
TAM_PROC   <- 2.1
TAM_MINI   <- 1.9
TAM_SUB    <- 1.8   # sub-etiquetas dentro del dibujo (exón, 5' UTR, cap...)
TAM_CDS    <- 2.0

SANS <- familia_base()

# --- Nivel 1: el locus ------------------------------------------------------
# Todo lo demás se deriva de acá. Los exones van creciendo (10, 12, 14) sólo
# para que se vea que no son iguales.
PROMOTOR <- c(X_BARRA, X_BARRA + 6)          # 30 .. 36, gris, fuera del gen
EXONES   <- data.frame(x0 = c(38, 62, 88), x1 = c(48, 74, 102))
FLANCO   <- c(102, 108)                      # 3' flanqueante, gris

INTRONES <- data.frame(x0 = EXONES$x1[-nrow(EXONES)],
                       x1 = EXONES$x0[-1])

# --- Nivel 2: el pre-mRNA ---------------------------------------------------
# La unidad de transcripción: del inicio del exón 1 al final del último.
PRE_INI <- min(EXONES$x0)
PRE_FIN <- max(EXONES$x1)

# --- Nivel 3: el mRNA maduro ------------------------------------------------
# Los exones pegados, alineados a la izquierda del dibujo.
LARGO_EXONICO <- sum(EXONES$x1 - EXONES$x0)
MRNA <- c(X_BARRA, X_BARRA + LARGO_EXONICO)

UTR5 <- 6    # 5' UTR
UTR3 <- 8    # 3' UTR
CDS  <- c(MRNA[1] + UTR5, MRNA[2] - UTR3)

R_CAP     <- 1.3                       # el cap, un círculo chico al inicio
POLIA_FIN <- MRNA[2] + 8               # la cola poliA, una onda al final

# --- Nivel 5: la proteína ---------------------------------------------------
# Tres nucleótidos por residuo. Sale corta, y ese es exactamente el punto.
NT_POR_AA <- 3
PROT <- c(CDS[1], CDS[1] + (CDS[2] - CDS[1]) / NT_POR_AA)
PASO_HATCH <- 1.2                      # separadores que marcan "cambió el alfabeto"

# --- Longitud relativa (columna de la derecha) ------------------------------
# Se MIDE sobre el dibujo, no se teclea.
largo_dibujado <- c(FLANCO[2] - PROMOTOR[1],   # el locus, promotor y flanco incluidos
                    PRE_FIN - PRE_INI,
                    MRNA[2] - MRNA[1],
                    CDS[2] - CDS[1],
                    PROT[2] - PROT[1])
frac <- largo_dibujado / largo_dibujado[1]


# --- Ensamblado de las barras ----------------------------------------------
banda <- function(x0, x1, i, ...) {
  data.frame(xmin = x0, xmax = x1, ymin = Y_FILA[i] - ALTO_B / 2,
             ymax = Y_FILA[i] + ALTO_B / 2, ...)
}

# Cajas grises: promotor y flanco. Van MÁS BAJAS que los exones a propósito:
# no se transcriben, y si tuvieran la misma altura el flanco se leería como un
# cuarto exón pegado al final del gen.
ALTO_GRIS <- 5
grises <- rbind(banda(PROMOTOR[1], PROMOTOR[2], 1),
                banda(FLANCO[1],   FLANCO[2],   1))
grises$ymin <- Y_FILA[1] - ALTO_GRIS / 2
grises$ymax <- Y_FILA[1] + ALTO_GRIS / 2

# Exones del locus (nivel 1) y del pre-mRNA (nivel 2).
exones_12 <- rbind(
  do.call(rbind, lapply(seq_len(nrow(EXONES)),
                        function(k) banda(EXONES$x0[k], EXONES$x1[k], 1))),
  do.call(rbind, lapply(seq_len(nrow(EXONES)),
                        function(k) banda(EXONES$x0[k], EXONES$x1[k], 2)))
)

# Intrones: línea delgada, no caja.
intrones_12 <- rbind(
  data.frame(x = INTRONES$x0, xend = INTRONES$x1, y = Y_FILA[1], yend = Y_FILA[1]),
  data.frame(x = INTRONES$x0, xend = INTRONES$x1, y = Y_FILA[2], yend = Y_FILA[2])
)

# Nivel 3: UTR en azul claro, CDS en naranja.
mrna <- rbind(
  transform(banda(MRNA[1], CDS[1],  3), parte = "UTR"),
  transform(banda(CDS[1],  CDS[2],  3), parte = "CDS"),
  transform(banda(CDS[2],  MRNA[2], 3), parte = "UTR")
)

cap <- circulo(MRNA[1], Y_FILA[3], R_CAP)

# La cola poliA: una onda, para que se lea como "y sigue".
onda_x <- seq(MRNA[2], POLIA_FIN, length.out = 60)
polia <- data.frame(
  x = onda_x,
  y = Y_FILA[3] + 1.1 * sin((onda_x - MRNA[2]) / (POLIA_FIN - MRNA[2]) * 4 * pi)
)

# Nivel 4: la CDS sola, en la MISMA x que arriba.
cds_sola <- banda(CDS[1], CDS[2], 4)

# La llave punteada que la conecta con su tramo del mRNA: dos verticales, una
# por extremo. No es una flecha porque no es un proceso.
conectores <- data.frame(
  x    = c(CDS[1], CDS[2]),
  y    = Y_FILA[3] - ALTO_B / 2,
  xend = c(CDS[1], CDS[2]),
  yend = Y_FILA[4] + ALTO_B / 2
)

# Nivel 5: la proteína.
prot <- banda(PROT[1], PROT[2], 5)
hatch <- data.frame(x = seq(PROT[1] + PASO_HATCH, PROT[2] - PASO_HATCH / 2,
                            by = PASO_HATCH))
hatch$y    <- Y_FILA[5] - ALTO_B / 2
hatch$yend <- Y_FILA[5] + ALTO_B / 2

# --- Flechas de proceso -----------------------------------------------------
procesos <- transform(
  PROCESOS,
  y    = Y_FILA[PROCESOS$desde] - ALTO_B / 2 - RETIRO,
  yend = Y_FILA[PROCESOS$hacia] + ALTO_B / 2 + RETIRO
)
procesos$ym <- (procesos$y + procesos$yend) / 2

# --- Columna de longitud relativa -------------------------------------------
mini <- data.frame(
  xmin = X_MINI, xmax = X_MINI + ANCHO_MINI * frac,
  ymin = Y_FILA - 1.4, ymax = Y_FILA + 1.4,
  pct  = sprintf("%.0f %%", 100 * frac)
)
# El 9 % de la proteína se redondearía a "9 %" y se leería como un entero
# cómodo; se deja con un decimal para que no parezca cifra redonda.
mini$pct[5] <- sprintf("%.1f %%", 100 * frac[5])

# --- Sub-etiquetas del dibujo -----------------------------------------------
Y_ARR <- ALTO_B / 2 + 2.2    # separación de las etiquetas sobre la barra
Y_ABA <- ALTO_B / 2 + 2.4    #   ... y bajo la barra

sub_arriba <- rbind(
  data.frame(x = mean(unlist(EXONES[1, ])), y = Y_FILA[1] + Y_ARR, txt = "exón"),
  data.frame(x = MRNA[1] - 1.5,             y = Y_FILA[3] + Y_ARR, txt = "cap"),
  data.frame(x = (MRNA[2] + POLIA_FIN) / 2, y = Y_FILA[3] + Y_ARR, txt = "poliA")
)
sub_abajo <- rbind(
  data.frame(x = mean(PROMOTOR),            y = Y_FILA[1] - Y_ABA, txt = "promotor"),
  data.frame(x = mean(unlist(INTRONES[1, ])), y = Y_FILA[1] - Y_ABA, txt = "intrón"),
  data.frame(x = mean(FLANCO),              y = Y_FILA[1] - Y_ABA, txt = "flanco"),
  data.frame(x = (MRNA[1] + CDS[1]) / 2,    y = Y_FILA[3] - Y_ABA, txt = "5' UTR"),
  data.frame(x = (CDS[2] + MRNA[2]) / 2,    y = Y_FILA[3] - Y_ABA, txt = "3' UTR")
)


construir <- function() {
  ggplot() +
    # --- Nivel 1 y 2: promotor, flanco, intrones, exones ---
    geom_rect(data = grises,
              aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
              fill = alpha(GRIS, 0.22), colour = GRIS, linewidth = 0.3) +
    geom_segment(data = intrones_12, aes(x = x, xend = xend, y = y, yend = yend),
                 colour = AZUL, linewidth = 0.35) +
    geom_rect(data = exones_12,
              aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
              fill = AZUL, colour = AZUL, linewidth = 0.3) +

    # --- Nivel 3: el mRNA maduro, con cap y poliA ---
    geom_path(data = polia, aes(x = x, y = y), colour = AZUL, linewidth = 0.35) +
    geom_rect(data = mrna,
              aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax,
                  fill = parte),
              colour = NA) +
    geom_polygon(data = cap, aes(x = x, y = y),
                 fill = AZUL, colour = AZUL, linewidth = 0.3) +
    geom_text(data = data.frame(x = mean(CDS), y = Y_FILA[3]),
              aes(x = x, y = y), label = "CDS", family = SANS,
              size = TAM_CDS, colour = "white") +

    # --- Nivel 4: la CDS aislada, en la misma x ---
    geom_segment(data = conectores,
                 aes(x = x, xend = xend, y = y, yend = yend),
                 colour = NARANJA, linewidth = 0.35, linetype = "dotted") +
    geom_rect(data = cds_sola,
              aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
              fill = NARANJA, colour = NARANJA, linewidth = 0.3) +

    # --- Nivel 5: la proteína. Otro alfabeto, otra trama ---
    geom_rect(data = prot,
              aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
              fill = VERDE, colour = VERDE, linewidth = 0.3) +
    geom_segment(data = hatch, aes(x = x, xend = x, y = y, yend = yend),
                 colour = "white", linewidth = 0.3) +

    # --- Flechas de proceso ---
    # arrow.fill: sin él la punta cerrada sale hueca.
    geom_segment(data = procesos,
                 aes(x = X_FLECHA, xend = X_FLECHA, y = y, yend = yend),
                 colour = GRIS, linewidth = 0.45, arrow.fill = GRIS,
                 arrow = arrow(length = unit(1.8, "mm"), type = "closed")) +
    geom_text(data = procesos, aes(x = X_ETIQ_P, y = ym, label = proceso),
              family = SANS, size = TAM_PROC, colour = GRIS, hjust = 0) +
    geom_text(data = data.frame(y = mean(Y_FILA[3:4])),
              aes(x = X_ETIQ_P, y = y), label = DEFINICION,
              family = SANS, size = TAM_PROC, colour = NARANJA, hjust = 0,
              lineheight = 1.05) +

    # --- Nombres, etiquetas de tipo y sub-etiquetas ---
    geom_text(data = NIVELES, aes(x = X_NOM_DER, y = Y_FILA, label = nombre),
              family = SANS, size = TAM_NOMBRE, colour = TEXTO, hjust = 1) +
    geom_text(data = NIVELES, aes(x = X_TAG, y = Y_FILA, label = tipo),
              family = SANS, size = TAM_TAG, colour = GRIS, hjust = 0,
              lineheight = 1.05) +
    geom_text(data = sub_arriba, aes(x = x, y = y, label = txt),
              family = SANS, size = TAM_SUB, colour = GRIS) +
    geom_text(data = sub_abajo, aes(x = x, y = y, label = txt),
              family = SANS, size = TAM_SUB, colour = GRIS) +

    # --- Columna de longitud relativa ---
    geom_text(data = data.frame(1), aes(x = X_MINI, y = ALTO_PANEL - 4),
              label = "monómeros\n(relativo)", family = SANS, size = TAM_MINI,
              colour = GRIS, hjust = 0, lineheight = 1.05) +
    geom_rect(data = mini,
              aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
              fill = alpha(GRIS, 0.45), colour = NA) +
    geom_text(data = mini, aes(x = X_PCT, y = (ymin + ymax) / 2, label = pct),
              family = SANS, size = TAM_MINI, colour = GRIS, hjust = 1) +

    scale_fill_manual(values = c(UTR = alpha(AZUL_CLARO, 0.55), CDS = NARANJA),
                      guide = "none") +
    coord_cartesian(xlim = c(0, ANCHO_PANEL), ylim = c(0, ALTO_PANEL),
                    expand = FALSE, clip = "off") +
    labs(caption = paste("Esquema; ningún gen real. Las longitudes son relativas entre sí:",
                         "el pre-mRNA es la unidad de transcripción, el mRNA la suma de los",
                         "exones,\nla CDS un subintervalo del mRNA y la proteína la CDS entre tres.")) +
    tema_esquema()
}


if (!interactive()) {
  m_nombre <- media_ancho(NIVELES$nombre, TAM_NOMBRE)
  m_tag    <- media_ancho(NIVELES$tipo,   TAM_TAG)
  m_proc   <- media_ancho(procesos$proceso, TAM_PROC)
  m_defin  <- media_ancho(DEFINICION, TAM_PROC)
  m_pct    <- media_ancho(mini$pct,   TAM_MINI)

  stopifnot(
    # --- Lo que la figura afirma ---
    nrow(NIVELES) == 5L,
    identical(NIVELES$nombre, c("Locus genómico", "Pre-mRNA", "mRNA maduro",
                                "CDS", "Proteína")),
    nrow(PROCESOS) == 3L,                       # tres procesos, no cuatro
    !any(PROCESOS$desde == 3L),                 # mRNA -> CDS NO es un proceso
    sum(NIVELES$tipo == "constructo\n(un intervalo)") == 1L,

    # --- La jerarquía de longitudes: cada nivel cabe en el anterior ---
    all(diff(largo_dibujado) < 0),              # van encogiendo, sin empates
    PRE_INI >= PROMOTOR[2], PRE_FIN <= FLANCO[1],
    isTRUE(all.equal(MRNA[2] - MRNA[1], LARGO_EXONICO)),
    CDS[1] > MRNA[1], CDS[2] < MRNA[2],         # la CDS es interior al mRNA
    isTRUE(all.equal(PROT[2] - PROT[1], (CDS[2] - CDS[1]) / NT_POR_AA)),
    PROT[1] == CDS[1],                          # arranca en el codón de inicio

    # --- Nada se sale del panel ---
    min(NIVELES$orden) == 1L,
    min(X_NOM_DER - 2 * m_nombre) >= 0,
    FLANCO[2] <= X_TAG - 1,                     # el dibujo no invade las tags
    POLIA_FIN <= X_TAG - 1,
    max(X_TAG + 2 * m_tag) <= X_MINI - 1,       # ni las tags la mini columna
    max(mini$xmax) < X_PCT - 2 * max(m_pct) - 1,
    max(Y_FILA) + ALTO_B / 2 <= ALTO_PANEL - 2,
    min(Y_FILA) - ALTO_B / 2 >= 0,

    # --- Nada se encima ---
    all(procesos$y > procesos$yend),            # las flechas bajan
    X_FLECHA > CDS[2],                          # la columna de flechas libra la CDS
    all(X_ETIQ_P + 2 * m_proc <= ANCHO_PANEL),
    X_ETIQ_P + 2 * m_defin <= X_TAG,
    all(sub_arriba$x - media_ancho(sub_arriba$txt, TAM_SUB) >= -2),
    all(sub_abajo$x + media_ancho(sub_abajo$txt, TAM_SUB) <= ANCHO_PANEL),
    # el conector derecho de la CDS no toca la etiqueta "3' UTR"
    CDS[2] < with(subset(sub_abajo, txt == "3' UTR"),
                  x - media_ancho(txt, TAM_SUB)) - 0.5
  )

  message(sprintf("  %d niveles, %d procesos, 1 definición (mRNA -> CDS)",
                  nrow(NIVELES), nrow(PROCESOS)))
  message("  longitud relativa de monómeros por nivel:")
  for (i in seq_len(nrow(NIVELES))) {
    message(sprintf("    %-15s %6.1f mm dibujados  =  %5.1f %%",
                    NIVELES$nombre[i], largo_dibujado[i], 100 * frac[i]))
  }
  message(sprintf("  exones de %s mm; CDS de %g mm; proteína de %.2f mm (CDS/%d)",
                  paste(EXONES$x1 - EXONES$x0, collapse = ", "),
                  CDS[2] - CDS[1], PROT[2] - PROT[1], NT_POR_AA))

  guardar(construir(), "jerarquia-gen-producto", 16, 12)
}
