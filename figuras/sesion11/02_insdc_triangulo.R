## Fig. @fig-insdc (Sesión 11, § Los tres y el trato / qué NO se intercambia)
## El triángulo del INSDC. Lo importante de la figura es la mitad de abajo:
## lo que NO viaja entre los tres socios.
##
## ---------------------------------------------------------------------------
## POR QUÉ LA MITAD DE ABAJO ES MÁS GRANDE DE LO QUE PARECE QUE DEBERÍA
##
## La confusión que el capítulo quiere matar ("RefSeq es parte del INSDC") no
## se corrige dibujando bonito el triángulo: se corrige dándole a la excepción
## el mismo peso visual que a la regla. Por eso la caja gris ocupa casi la
## mitad del panel y no es un pie de página.
##
## El triángulo pequeño de dbGaP/EGA/JGA se dibuja con la MISMA geometría que
## el grande, a escala: son un espejo de acceso controlado, y la figura lo dice
## con la forma antes que con el texto.
## ---------------------------------------------------------------------------
##
## Esquema: no afirma ninguna cantidad. Sin título dentro del SVG.
##
## Regenerar:  Rscript figuras/sesion11/02_insdc_triangulo.R

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
# guardar(w = 16, h = 11) con 2 mm de margen: panel de 156 x 106 mm.
ANCHO_PANEL <- 156
ALTO_PANEL  <- 106

Y_CORTE <- 49                     # la línea punteada que parte la figura

SANS <- familia_base()

TAM_NODO   <- 3.0
TAM_SUB    <- 2.0
TAM_ARISTA <- 1.9
TAM_TITULO <- 2.6
TAM_FUERA  <- 2.4
TAM_SUBF   <- 2.0

# --- Los tres socios ---------------------------------------------------------
NODO_W <- 38; NODO_H <- 14

nodos <- data.frame(
  x   = c(78, 30, 126),
  y   = c(90, 62,  62),
  sig = c("GenBank", "ENA", "DDBJ"),
  sub = c("NCBI · Estados Unidos", "EMBL-EBI · Europa", "NIG · Japón"),
  stringsAsFactors = FALSE
)

cajas <- do.call(rbind, lapply(seq_len(nrow(nodos)), function(k) {
  transform(caja_redonda(nodos$x[k] - NODO_W / 2, nodos$x[k] + NODO_W / 2,
                         nodos$y[k] - NODO_H / 2, nodos$y[k] + NODO_H / 2,
                         r = 2.2),
            id = k)
}))

# --- Las tres aristas, bidireccionales ---------------------------------------
# Se recortan por los dos extremos para que las puntas no se metan bajo las
# cajas. El recorte es generoso del lado horizontal (media caja) y menor en las
# diagonales, donde la caja se cruza antes.
pares <- data.frame(a = c(1, 1, 2), b = c(2, 3, 3))

aristas <- do.call(rbind, lapply(seq_len(nrow(pares)), function(k) {
  i <- pares$a[k]; j <- pares$b[k]
  horizontal <- abs(nodos$y[i] - nodos$y[j]) < 1
  rec <- if (horizontal) NODO_W / 2 + 2 else 15
  transform(recortar(nodos$x[i], nodos$y[i], nodos$x[j], nodos$y[j],
                     ini = rec, fin = rec), id = k)
}))

# Etiqueta de cada arista, en su punto medio y desplazada hacia afuera para no
# caer encima de la línea.
etq_aristas <- data.frame(
  x = c((aristas$x[1] + aristas$xend[1]) / 2 - 7,
        (aristas$x[2] + aristas$xend[2]) / 2 + 7,
        (aristas$x[3] + aristas$xend[3]) / 2),
  y = c((aristas$y[1] + aristas$yend[1]) / 2 + 3,
        (aristas$y[2] + aristas$yend[2]) / 2 + 3,
        (aristas$y[3] + aristas$yend[3]) / 2 + 2.6),
  txt = rep("intercambio diario", 3),
  ang = c(35, -35, 0),
  stringsAsFactors = FALSE
)

# --- La caja de lo que NO se intercambia -------------------------------------
FUERA <- c(xmin = 5, xmax = 151, ymin = 5, ymax = 42)
caja_fuera <- caja_redonda(FUERA["xmin"], FUERA["xmax"],
                           FUERA["ymin"], FUERA["ymax"], r = 2.5)

# Dos columnas: los dos recursos de la izquierda, el triángulo de acceso
# controlado a la derecha.
fuera_items <- data.frame(
  x   = c(14, 14),
  y   = c(27, 15),
  sig = c("RefSeq", "UniProt"),
  sub = c("sólo NCBI. Un NM_ no existe en el ENA.",
          "ni siquiera es INSDC: otro consorcio."),
  stringsAsFactors = FALSE
)

# El triángulo chico, misma forma que el grande a escala ~0.30.
TRI_CX <- 116; TRI_CY <- 23; TRI_ESC <- 0.30
tri_chico <- data.frame(
  x = TRI_CX + (nodos$x - 78) * TRI_ESC,
  y = TRI_CY + (nodos$y - 71) * TRI_ESC,
  sig = c("dbGaP", "EGA", "JGA"),
  stringsAsFactors = FALSE
)
tri_borde <- tri_chico[c(1, 2, 3, 1), c("x", "y")]

TXT_TRI <- "acceso controlado:\nsolicitud y comité"


construir <- function() {
  ggplot() +
    # ---------------- Arriba: el triángulo que sí se intercambia ------------
    geom_segment(data = aristas,
                 aes(x = x, y = y, xend = xend, yend = yend),
                 colour = AZUL, linewidth = 0.5,
                 arrow = arrow(length = unit(2.2, "mm"), ends = "both",
                               type = "closed")) +
    geom_text(data = etq_aristas, aes(x = x, y = y, label = txt, angle = ang),
              family = SANS, size = TAM_ARISTA, colour = AZUL) +

    geom_polygon(data = cajas, aes(x = x, y = y, group = id),
                 fill = alpha(AZUL_CLARO, 0.16), colour = AZUL, linewidth = 0.45) +
    geom_text(data = nodos, aes(x = x, y = y + 2.2, label = sig),
              family = SANS, size = TAM_NODO, colour = AZUL, fontface = "bold") +
    geom_text(data = nodos, aes(x = x, y = y - 3.0, label = sub),
              family = SANS, size = TAM_SUB, colour = TEXTO) +

    # ---------------- La línea que parte la figura --------------------------
    annotate("segment", x = 5, xend = 151, y = Y_CORTE, yend = Y_CORTE,
             colour = GRIS_BORDE, linewidth = 0.4, linetype = "dotted") +

    # ---------------- Abajo: lo que NO se intercambia -----------------------
    geom_polygon(data = caja_fuera, aes(x = x, y = y),
                 fill = GRIS_CAJA, colour = GRIS_BORDE, linewidth = 0.4) +
    annotate("text", x = FUERA["xmin"] + 4, y = FUERA["ymax"] - 4.5,
             label = "NO se intercambia", family = SANS, size = TAM_TITULO,
             colour = GRIS, fontface = "bold", hjust = 0) +

    geom_text(data = fuera_items, aes(x = x, y = y, label = sig),
              family = SANS, size = TAM_FUERA, colour = GRIS,
              fontface = "bold", hjust = 0) +
    geom_text(data = fuera_items, aes(x = x + 22, y = y, label = sub),
              family = SANS, size = TAM_SUBF, colour = GRIS, hjust = 0) +

    # El triángulo espejo, en gris
    geom_polygon(data = tri_borde, aes(x = x, y = y),
                 fill = NA, colour = GRIS_BORDE, linewidth = 0.4,
                 linetype = "dashed") +
    geom_text(data = tri_chico, aes(x = x, y = y, label = sig),
              family = SANS, size = TAM_SUBF, colour = GRIS, fontface = "bold") +
    annotate("text", x = TRI_CX, y = TRI_CY - 13, label = TXT_TRI,
             family = SANS, size = TAM_SUBF * 0.92, colour = GRIS,
             lineheight = 1.1) +

    coord_cartesian(xlim = c(0, ANCHO_PANEL), ylim = c(0, ALTO_PANEL),
                    expand = FALSE, clip = "off") +
    tema_esquema()
}


if (!interactive()) {
  stopifnot(
    # --- La estructura ---
    nrow(nodos) == 3L,
    nrow(pares) == 3L,                       # el triángulo está completo
    nrow(tri_chico) == 3L,
    all(nodos$sig %in% c("GenBank", "ENA", "DDBJ")),
    all(tri_chico$sig %in% c("dbGaP", "EGA", "JGA")),

    # --- El corte separa de verdad: nada del triángulo baja, nada de la caja
    #     sube. Si esto falla, la figura estaría diciendo que RefSeq se
    #     intercambia, que es exactamente el mito que viene a matar. ---
    min(nodos$y) - NODO_H / 2 > Y_CORTE,
    FUERA["ymax"] < Y_CORTE,
    min(aristas$y, aristas$yend) > Y_CORTE,

    # --- Nada se sale del panel ---
    max(nodos$x) + NODO_W / 2 <= ANCHO_PANEL,
    min(nodos$x) - NODO_W / 2 >= 0,
    max(nodos$y) + NODO_H / 2 <= ALTO_PANEL,
    FUERA["xmax"] <= ANCHO_PANEL, FUERA["xmin"] >= 0, FUERA["ymin"] >= 0,

    # --- El triángulo chico cabe en su caja ---
    all(tri_chico$x > FUERA["xmin"]), all(tri_chico$x < FUERA["xmax"]),
    all(tri_chico$y > FUERA["ymin"]), all(tri_chico$y < FUERA["ymax"]),
    # y no se encima con el texto de la izquierda
    min(tri_chico$x) - 6 > max(fuera_items$x + 22) +
      2 * max(media_ancho(fuera_items$sub, TAM_SUBF))
  )

  message(sprintf("  socios INSDC: %s", paste(nodos$sig, collapse = ", ")))
  message(sprintf("  aristas bidireccionales: %d", nrow(pares)))
  message(sprintf("  fuera del intercambio: %s + acceso controlado (%s)",
                  paste(fuera_items$sig, collapse = ", "),
                  paste(tri_chico$sig, collapse = ", ")))
  message(sprintf("  corte en y = %.0f mm; triángulo arriba, caja gris abajo",
                  Y_CORTE))

  guardar(construir(), "insdc-triangulo", 16, 11)
}
