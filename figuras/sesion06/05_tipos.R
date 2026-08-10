## Fig. @fig-tipos (Sesión 6, "Global, local, semiglobal") — OPCIONAL
## Los tres tipos de alineamiento sobre el mismo par de secuencias.
##
## Es el Ejercicio 4 dibujado: una proteína de 400 residuos y un dominio de 50
## que está adentro de ella, alineados de las tres maneras. Lo que cambia entre
## los paneles no es el par de secuencias: es la pregunta.
##
##   global      needle  obliga a alinear las dos completas, así que riega los
##                       50 residuos del dominio a lo largo de los 400
##   local       water   se queda con el tramo que sí se parece y tira el resto
##   semiglobal          alinea todo pero no cobra los huecos de los extremos
##
## Esquema puro: las posiciones son de juguete y están declaradas arriba, no
## medidas de ningún archivo. Lo que sí se calcula acá es la geometría (dónde
## cae cada bloque, dónde va cada hueco), para que los tres paneles sean
## consistentes entre sí y con las longitudes que anuncian.
##
## Sin título dentro del SVG: el caption vive en el .qmd.
##
## Regenerar:  Rscript figuras/sesion06/05_tipos.R

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


# --- Las dos secuencias de juguete ------------------------------------------
LARGA  <- 400L      # residuos de la proteína completa
CORTO  <- 50L       # residuos del dominio
DOM_DE <- 150L      # dónde empieza el dominio dentro de la larga (1-based)
DOM_A  <- DOM_DE + CORTO            # primer residuo DESPUÉS del dominio

# En el panel global, los 50 residuos del dominio quedan repartidos a lo largo
# de los 400. Se reparten en bloques parejos: es un esquema, pero uno cuyas
# cuentas cierran (los bloques suman exactamente CORTO residuos).
N_BLOQUES  <- 10L
LARGO_BLOQ <- CORTO %/% N_BLOQUES
centros    <- LARGA * (seq_len(N_BLOQUES) - 0.5) / N_BLOQUES
bloques_global <- data.frame(de = centros - LARGO_BLOQ / 2,
                             a  = centros + LARGO_BLOQ / 2)


# --- Geometría, en milímetros -----------------------------------------------
# guardar(w = 14, h = 10) con 2 mm de margen lateral y el caption abajo.
ANCHO_PANEL <- 136
ALTO_PANEL  <- 93

X_INI <- 27; X_FIN <- 134            # los 400 residuos, de punta a punta
X_FILA <- 24                         # etiquetas "larga" / "corta", a la derecha

xr <- function(pos) X_INI + (X_FIN - X_INI) * pos / LARGA

ALTO_BARRA <- 4

# Un panel por tipo. base = el renglón del título; lo demás cuelga de ahí.
BASES <- c(global = 90, local = 60, semiglobal = 30)
dy    <- c(titulo = 0, larga = -7, corta = -13, etiqueta = -20, libres = -17)

# El semiglobal es el único que lleva llaves debajo de la fila corta, así que
# su etiqueta baja para dejarles lugar. Sin esto, "libres" y la etiqueta caen
# en el mismo renglón y se encima una sobre la otra.
AJUSTE <- list(semiglobal = c(etiqueta = -4))

yb <- function(tipo, que) {
  a <- AJUSTE[[tipo]]
  BASES[[tipo]] + dy[[que]] + if (!is.null(a) && que %in% names(a)) a[[que]] else 0
}

TAM_TIT   <- 2.7
TAM_ETIQ  <- 2.4
TAM_FILA  <- 2.1
TAM_LIBRE <- 2.0

VERDE_TENUE <- alpha(GRIS, 0.14)     # secuencia sin alinear
SANS <- familia_base()


# --- Los tres paneles -------------------------------------------------------
#' Rectángulos de una fila: los tramos alineados, en verde.
tramos <- function(tipo, fila, de, a) {
  if (length(de) == 0) return(NULL)
  data.frame(tipo = tipo, xmin = xr(de), xmax = xr(a),
             y = yb(tipo, fila), fill = VERDE)
}

#' Segmentos punteados: los huecos, que sí se dibujan porque son parte del
#' alineamiento (a diferencia de lo que water simplemente no alinea).
huecos <- function(tipo, fila, de, a) {
  if (length(de) == 0) return(NULL)
  data.frame(tipo = tipo, x = xr(de), xend = xr(a), y = yb(tipo, fila))
}

# --- global: los 50 residuos, regados a lo largo de los 400 ---
g_bloques <- bloques_global
# los huecos del dominio son todo lo que queda entre bloque y bloque
g_huecos_de <- c(0, g_bloques$a)
g_huecos_a  <- c(g_bloques$de, LARGA)

# --- local: un solo bloque, y nada más ---
# --- semiglobal: el mismo bloque, con los flancos presentes pero libres ---

barras_verdes <- rbind(
  tramos("global",     "larga", g_bloques$de, g_bloques$a),
  tramos("global",     "corta", g_bloques$de, g_bloques$a),
  tramos("local",      "larga", DOM_DE, DOM_A),
  tramos("local",      "corta", DOM_DE, DOM_A),
  tramos("semiglobal", "larga", DOM_DE, DOM_A),
  tramos("semiglobal", "corta", DOM_DE, DOM_A)
)

barras_tenues <- rbind(
  data.frame(tipo = "global",     xmin = xr(0), xmax = xr(LARGA), y = yb("global", "larga")),
  data.frame(tipo = "local",      xmin = xr(0), xmax = xr(LARGA), y = yb("local", "larga")),
  data.frame(tipo = "semiglobal", xmin = xr(0), xmax = xr(LARGA), y = yb("semiglobal", "larga"))
)

barras_huecos <- rbind(
  huecos("global",     "corta", g_huecos_de, g_huecos_a),
  huecos("semiglobal", "corta", c(0, DOM_A), c(DOM_DE, LARGA))
)

# Los flancos libres del semiglobal, con su llave y su palabra.
FLANCOS <- data.frame(de = c(0, DOM_A), a = c(DOM_DE, LARGA))
llaves_libres <- data.frame(
  x = xr(FLANCOS$de), xend = xr(FLANCOS$a), y = yb("semiglobal", "libres")
)
txt_libres <- data.frame(
  x = xr((FLANCOS$de + FLANCOS$a) / 2), y = yb("semiglobal", "libres") - 2.6,
  txt = "libres"
)

titulos <- data.frame(
  x = 2, y = vapply(names(BASES), yb, numeric(1), "titulo"),
  txt = c("Global", "Local", "Semiglobal")
)

etiquetas <- data.frame(
  x = X_INI, y = vapply(names(BASES), yb, numeric(1), "etiqueta"),
  txt = c("needle: alinea todo contra todo, aunque no tenga sentido",
          "water: encuentra el tramo que sí se parece",
          "extremos sin penalizar")
)

filas <- do.call(rbind, lapply(names(BASES), function(t) data.frame(
  x = X_FILA, y = c(yb(t, "larga"), yb(t, "corta")),
  txt = c(sprintf("larga · %d", LARGA), sprintf("corta · %d", CORTO))
)))


construir <- function() {
  ggplot() +
    # --- La secuencia larga completa, de fondo ---
    geom_rect(data = barras_tenues,
              aes(xmin = xmin, xmax = xmax,
                  ymin = y - ALTO_BARRA / 2, ymax = y + ALTO_BARRA / 2),
              fill = VERDE_TENUE) +

    # --- Los huecos, punteados ---
    geom_segment(data = barras_huecos, aes(x = x, xend = xend, y = y, yend = y),
                 colour = alpha(GRIS, 0.75), linewidth = 0.45, linetype = "12") +

    # --- Lo alineado, en verde ---
    geom_rect(data = barras_verdes,
              aes(xmin = xmin, xmax = xmax,
                  ymin = y - ALTO_BARRA / 2, ymax = y + ALTO_BARRA / 2),
              fill = VERDE) +

    # --- Los flancos libres del semiglobal ---
    geom_segment(data = llaves_libres, aes(x = x, xend = xend, y = y, yend = y),
                 colour = NARANJA, linewidth = 0.4) +
    geom_segment(data = rbind(
        data.frame(x = llaves_libres$x,    y = llaves_libres$y),
        data.frame(x = llaves_libres$xend, y = llaves_libres$y)),
      aes(x = x, xend = x, y = y - 1, yend = y + 1),
      colour = NARANJA, linewidth = 0.4) +
    geom_text(data = txt_libres, aes(x = x, y = y, label = txt),
              family = SANS, size = TAM_LIBRE, colour = NARANJA) +

    # --- Rótulos ---
    geom_text(data = titulos, aes(x = x, y = y, label = txt),
              family = SANS, size = TAM_TIT, colour = TEXTO,
              hjust = 0, fontface = "bold") +
    geom_text(data = etiquetas, aes(x = x, y = y, label = txt),
              family = SANS, size = TAM_ETIQ, colour = TEXTO, hjust = 0) +
    geom_text(data = filas, aes(x = x, y = y, label = txt),
              family = SANS, size = TAM_FILA, colour = GRIS, hjust = 1) +

    coord_cartesian(xlim = c(0, ANCHO_PANEL), ylim = c(0, ALTO_PANEL),
                    expand = FALSE, clip = "off") +
    labs(caption = sprintf(paste("Esquema. Proteína de %d residuos con un dominio",
                                 "de %d adentro (posiciones %d a %d)."),
                           LARGA, CORTO, DOM_DE, DOM_A - 1L)) +
    tema_esquema()
}


if (!interactive()) {
  stopifnot(
    # --- Las cuentas del esquema cierran ---
    DOM_A - DOM_DE == CORTO,
    DOM_A <= LARGA,
    nrow(bloques_global) == N_BLOQUES,
    abs(sum(bloques_global$a - bloques_global$de) - CORTO) < 1e-9,
    all(bloques_global$de >= 0), all(bloques_global$a <= LARGA),
    all(diff(bloques_global$de) > 0),
    # los bloques del global no se tocan: entre cada dos hay hueco
    all(g_huecos_a - g_huecos_de > 0),

    # --- Lo que cada panel tiene que mostrar ---
    # global: el dominio en muchos pedazos; local y semiglobal: en uno solo
    sum(barras_verdes$tipo == "global") == 2 * N_BLOQUES,
    sum(barras_verdes$tipo == "local") == 2,
    sum(barras_verdes$tipo == "semiglobal") == 2,
    # local no dibuja huecos (lo que no alinea, no existe); los otros dos sí
    !any(barras_huecos$tipo == "local"),
    any(barras_huecos$tipo == "global"),
    nrow(llaves_libres) == 2,

    # --- Nada se sale del panel ---
    X_FIN <= ANCHO_PANEL,
    X_FILA - media_ancho(filas$txt, TAM_FILA) * 2 >= 0,
    all(etiquetas$x + media_ancho(etiquetas$txt, TAM_ETIQ) * 2 <= ANCHO_PANEL),
    max(titulos$y) + TAM_TIT <= ALTO_PANEL,
    min(txt_libres$y) - TAM_LIBRE >= 0,
    min(etiquetas$y) - TAM_ETIQ >= 0,
    # los paneles no se pisan
    all(diff(rev(BASES)) > 20)
  )

  message(sprintf("  larga: %d aa   dominio: %d aa en las posiciones %d-%d",
                  LARGA, CORTO, DOM_DE, DOM_A - 1L))
  message(sprintf("  global: los %d residuos en %d bloques de %d",
                  CORTO, N_BLOQUES, LARGO_BLOQ))
  message("  local: un bloque; semiglobal: un bloque con los dos flancos libres")

  guardar(construir(), "tipos-alineamiento", 14, 10)
}
