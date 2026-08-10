## Fig. @fig-archivo-curado (Sesión 11, § Archivo primario contra capa curada)
## La figura conceptual más importante de la unidad: la misma estructura, dos
## veces, en nucleótidos y en proteínas.
##
## ---------------------------------------------------------------------------
## POR QUÉ LA PILA DE LA IZQUIERDA ESTÁ DESALINEADA A PROPÓSITO
##
## El archivo primario no es "muchos registros": es muchos registros
## LIGERAMENTE DISTINTOS del mismo objeto, enviados por gente distinta, sin que
## nadie los concilie. Si se dibujaran como una pila perfecta, la figura diría
## "el archivo es grande", que es la lectura fácil y equivocada. Dibujados
## despatarrados dicen "el archivo es redundante", que es la buena.
##
## Los desfases están FIJOS, no son aleatorios: estilo.R garantiza que dos
## corridas den bytes idénticos y el diff de git quede limpio al regenerar.
## Un runif() rompería esa garantía.
## ---------------------------------------------------------------------------
##
## Esquema: no afirma ninguna cantidad. Sin título dentro del SVG.
##
## Regenerar:  Rscript figuras/sesion11/03_archivo_vs_curado.R

.ubicar <- function() {
  for (i in rev(seq_len(sys.nframe()))) {
    o <- sys.frame(i)$ofile
    if (!is.null(o)) return(normalizePath(o, winslash = "/"))
  }
  a <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1]), winslash = "/"))
  stop("no se pudo ubicar el script: correr con Rscript o con source()")
}
source(file.path(dirname(.ubicar()), "_tema.R"))


# --- Geometría, en milímetros -----------------------------------------------
# guardar(w = 16, h = 10) con 2 mm de margen: panel de 156 x 96 mm.
ANCHO_PANEL <- 156
ALTO_PANEL  <- 96

X_IZQ <- 10                       # borde izquierdo de la pila
X_DER <- 100                      # borde izquierdo de la caja curada
W_CURADO <- 44

Y_FILA <- c(70, 36)               # centro de cada fila: nucleótidos, proteínas
Y_ENCABEZADO <- 91

# El rótulo de cada fila va DEBAJO de su pila. La primera versión lo ponía a
# y - 17 fijo y el de la segunda fila caía encima de la proporción; se vio en
# el PNG, no en los stopifnot, que sólo medían las pilas. Ahora la separación
# se declara aquí y hay una comprobación explícita de los rótulos.
DESPLAZA_ETIQ <- 16
Y_ETIQ_FILA <- Y_FILA - DESPLAZA_ETIQ

Y_PROPORCION <- 10
Y_NOTA <- 3

SANS <- familia_base()

TAM_ENCABEZADO <- 2.7
TAM_ETIQ  <- 2.5
TAM_SUB   <- 2.0
TAM_FLECHA <- 2.1
TAM_PROP  <- 3.4
TAM_NOTA  <- 2.2

# --- La pila del archivo primario -------------------------------------------
N_ENVIOS <- 7
ALTO_ENVIO <- 2.8
PASO_ENVIO <- 3.5

# Desfases FIJOS (ver la nota de arriba). Se eligieron para que ninguno de los
# dos bordes quede recto: si el borde izquierdo se alineara, la pila volvería a
# leerse como una tabla ordenada.
DESFASE <- c(0.0, 2.6, -1.4, 3.4, 0.8, -2.2, 1.8)
ANCHO   <- c(34, 30, 36, 28, 33, 31, 35)

pila <- do.call(rbind, lapply(seq_along(Y_FILA), function(f) {
  y0 <- Y_FILA[f] + (N_ENVIOS - 1) / 2 * PASO_ENVIO
  do.call(rbind, lapply(seq_len(N_ENVIOS), function(k) {
    data.frame(
      xmin = X_IZQ + DESFASE[k],
      xmax = X_IZQ + DESFASE[k] + ANCHO[k],
      ymin = y0 - (k - 1) * PASO_ENVIO - ALTO_ENVIO / 2,
      ymax = y0 - (k - 1) * PASO_ENVIO + ALTO_ENVIO / 2,
      fila = f
    )
  }))
}))

# --- Las cajas curadas -------------------------------------------------------
curado <- do.call(rbind, lapply(seq_along(Y_FILA), function(f) {
  transform(caja_redonda(X_DER, X_DER + W_CURADO,
                         Y_FILA[f] - 5.5, Y_FILA[f] + 5.5, r = 1.8),
            fila = f)
}))

etiquetas <- data.frame(
  fila = c(1, 2),
  izq  = c("GenBank / INSDC", "UniProtKB / TrEMBL"),
  der  = c("RefSeq", "Swiss-Prot"),
  stringsAsFactors = FALSE
)
etiquetas$y <- Y_FILA[etiquetas$fila]

# --- Las flechas de curación -------------------------------------------------
X_FLECHA <- c(X_IZQ + max(ANCHO + DESFASE) + 4, X_DER - 4)
flechas <- data.frame(
  x = X_FLECHA[1], xend = X_FLECHA[2],
  y = Y_FILA, yend = Y_FILA
)

TXT_PROP <- "GenBank : RefSeq  ::  TrEMBL : Swiss-Prot"
TXT_NOTA <- paste("El archivo guarda lo que se envió.",
                  "La capa curada guarda lo que alguien decidió que está bien.")


construir <- function() {
  ggplot() +
    # --- Encabezados de columna ---
    annotate("text", x = X_IZQ + 17, y = Y_ENCABEZADO, label = "archivo primario",
             family = SANS, size = TAM_ENCABEZADO, colour = GRIS,
             fontface = "bold") +
    annotate("text", x = X_DER + W_CURADO / 2, y = Y_ENCABEZADO,
             label = "capa curada", family = SANS, size = TAM_ENCABEZADO,
             colour = AZUL, fontface = "bold") +
    annotate("text", x = X_IZQ + 17, y = Y_ENCABEZADO - 4.2,
             label = "redundante, sin conciliar", family = SANS,
             size = TAM_SUB, colour = GRIS) +
    annotate("text", x = X_DER + W_CURADO / 2, y = Y_ENCABEZADO - 4.2,
             label = "un representante por molécula", family = SANS,
             size = TAM_SUB, colour = AZUL) +

    # --- La pila: muchos envíos ligeramente distintos ---
    geom_rect(data = pila,
              aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
              fill = alpha(GRIS_CAJA, 0.9), colour = GRIS_BORDE,
              linewidth = 0.3) +

    # --- Las cajas curadas: una limpia por fila ---
    geom_polygon(data = curado, aes(x = x, y = y, group = fila),
                 fill = alpha(AZUL_CLARO, 0.20), colour = AZUL, linewidth = 0.5) +

    # --- Las flechas ---
    geom_segment(data = flechas, aes(x = x, y = y, xend = xend, yend = yend),
                 colour = VERDE, linewidth = 0.5,
                 arrow = arrow(length = unit(2.4, "mm"), type = "closed")) +
    geom_text(data = flechas, aes(x = (x + xend) / 2, y = y + 3.4),
              label = "curación", family = SANS, size = TAM_FLECHA,
              colour = VERDE, fontface = "italic") +

    # --- Rótulos de cada fila ---
    geom_text(data = etiquetas,
              aes(x = X_IZQ + 17, y = Y_ETIQ_FILA[fila], label = izq),
              family = SANS, size = TAM_ETIQ, colour = GRIS, fontface = "bold") +
    geom_text(data = etiquetas,
              aes(x = X_DER + W_CURADO / 2, y = y, label = der),
              family = SANS, size = TAM_ETIQ, colour = AZUL, fontface = "bold") +

    # --- La proporción, que es el remate ---
    annotate("text", x = ANCHO_PANEL / 2, y = Y_PROPORCION, label = TXT_PROP,
             family = SANS, size = TAM_PROP, colour = TEXTO, fontface = "bold") +

    # --- La nota al pie ---
    annotate("text", x = ANCHO_PANEL / 2, y = Y_NOTA, label = TXT_NOTA,
             family = SANS, size = TAM_NOTA, colour = GRIS, fontface = "italic") +

    coord_cartesian(xlim = c(0, ANCHO_PANEL), ylim = c(0, ALTO_PANEL),
                    expand = FALSE, clip = "off") +
    tema_esquema()
}


if (!interactive()) {
  m_prop <- media_ancho(TXT_PROP, TAM_PROP)
  m_nota <- media_ancho(TXT_NOTA, TAM_NOTA)

  stopifnot(
    # --- La estructura: dos filas, misma forma ---
    length(Y_FILA) == 2L,
    nrow(pila) == 2L * N_ENVIOS,
    nrow(etiquetas) == 2L,
    length(DESFASE) == N_ENVIOS, length(ANCHO) == N_ENVIOS,

    # --- La pila está despatarrada de verdad: ni el borde izquierdo ni el
    #     derecho quedan alineados. Es el argumento de la figura. ---
    length(unique(DESFASE)) == N_ENVIOS,
    length(unique(DESFASE + ANCHO)) == N_ENVIOS,

    # --- La pila no invade la columna curada ---
    max(pila$xmax) < X_FLECHA[1],
    X_FLECHA[2] > X_FLECHA[1],
    X_DER > max(pila$xmax),

    # --- Nada se sale del panel ---
    X_DER + W_CURADO <= ANCHO_PANEL,
    min(pila$xmin) >= 0,
    max(pila$ymax) < Y_ENCABEZADO - 5,
    Y_ENCABEZADO <= ALTO_PANEL,
    ANCHO_PANEL / 2 - m_prop >= 0,
    ANCHO_PANEL / 2 - m_nota >= 0,

    # --- Las filas no se enciman entre sí ni con la proporción ---
    min(pila$ymin[pila$fila == 1]) > max(pila$ymax[pila$fila == 2]),
    min(pila$ymin) > Y_PROPORCION + TAM_PROP,
    Y_PROPORCION - TAM_PROP > Y_NOTA + TAM_NOTA,

    # --- Y los RÓTULOS tampoco. Esto es lo que faltaba: el de la fila 2 caía
    #     justo encima de la proporción y ningún stopifnot lo veía. ---
    # cada rótulo queda debajo de su propia pila...
    all(Y_ETIQ_FILA + TAM_ETIQ < tapply(pila$ymin, pila$fila, min)),
    # ...y encima de la pila siguiente
    Y_ETIQ_FILA[1] - TAM_ETIQ > max(pila$ymax[pila$fila == 2]),
    # el último rótulo no toca la proporción
    Y_ETIQ_FILA[2] - TAM_ETIQ > Y_PROPORCION + TAM_PROP,
    # ni el primero toca los encabezados de columna
    max(pila$ymax) < Y_ENCABEZADO - 4.2 - TAM_SUB
  )

  message(sprintf("  dos filas: %s", paste(etiquetas$izq, "->", etiquetas$der,
                                           collapse = " | ")))
  message(sprintf("  envíos dibujados por fila: %d (desfases fijos, no aleatorios)",
                  N_ENVIOS))
  message(sprintf("  proporción: %s", TXT_PROP))

  guardar(construir(), "archivo-vs-curado", 16, 10)
}
