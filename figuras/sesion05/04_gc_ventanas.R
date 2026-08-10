## Fig. @fig-ventanas (Sesión 5, Ejercicio 10)
## GC en ventanas de 1 kb a lo largo del genoma de lambda.
##
## Es la figura que carga el argumento del capítulo: un promedio puede
## esconderlo todo. El 49.9 % global no describe ninguna parte del genoma.
##
## El corte entre las dos mitades NO está puesto a ojo ni copiado de la
## especificación. Se estima con el criterio clásico de un solo punto de
## cambio: el corte que minimiza la suma de cuadrados dentro de los dos
## segmentos. Sale en 22 kb, y el script comprueba que la diferencia entre
## mitades sea grande y significativa antes de dibujar las bandas. Si algún día
## deja de serlo, las bandas se quitan solas y avisa.
##
## Se calcula en R y no con seqkit, aunque el capítulo use seqkit en la
## práctica, para que el script sea autocontenido. Los números coinciden.
##
## Sin título dentro del SVG: el caption vive en el .qmd.
##
## Regenerar:  bash figuras/sesion05/00_datos.sh   # una vez
##             Rscript figuras/sesion05/04_gc_ventanas.R

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


# --- Los datos --------------------------------------------------------------
ACC <- "NC_001416.1"
VENTANA <- 1000L

seq_lambda <- leer_genoma(ACC)
inicio <- seq.int(1L, length(seq_lambda) - VENTANA + 1L, by = VENTANA)
d <- data.frame(
  inicio = inicio,
  kb = (inicio - 1L + VENTANA / 2) / 1000,     # centro de la ventana, en kb
  gc = vapply(inicio, function(i)
    gc_pct(Biostrings::subseq(seq_lambda, i, i + VENTANA - 1L)), numeric(1))
)
GC_GLOBAL <- gc_pct(seq_lambda)
COLA <- length(seq_lambda) - (max(inicio) + VENTANA - 1L)   # lo que sobra al final


# --- Punto de cambio, estimado ----------------------------------------------
# Criterio clásico de un solo change point: el corte k que minimiza la suma de
# cuadrados dentro de los dos segmentos. Se dejan cinco ventanas de holgura en
# cada extremo para no "encontrar" un corte que sea una sola ventana rara.
MARGEN <- 5L
candidatos <- seq(MARGEN, nrow(d) - MARGEN)
sse <- vapply(candidatos, function(k) {
  a <- d$gc[1:k]; b <- d$gc[(k + 1):nrow(d)]
  sum((a - mean(a))^2) + sum((b - mean(b))^2)
}, numeric(1))
K <- candidatos[which.min(sse)]

CORTE_KB   <- K * VENTANA / 1000
MEDIA_IZQ  <- mean(d$gc[1:K])
MEDIA_DER  <- mean(d$gc[(K + 1):nrow(d)])
prueba     <- t.test(d$gc[1:K], d$gc[(K + 1):nrow(d)])
R2         <- 1 - min(sse) / sum((d$gc - mean(d$gc))^2)

# Las bandas sólo se dibujan si el corte es real. Umbrales deliberadamente
# laxos: se trata de no dibujar una división donde no la hay, no de exigir un
# efecto enorme.
HAY_CORTE <- abs(MEDIA_IZQ - MEDIA_DER) > 5 && prueba$p.value < 1e-4
if (!HAY_CORTE) {
  message("  AVISO: el corte no es claro; se dibuja sin bandas.")
}

d$mitad <- ifelse(seq_len(nrow(d)) <= K, "rica en GC", "rica en AT")


# --- Etiquetas --------------------------------------------------------------
FIN_KB <- length(seq_lambda) / 1000
TXT_PROMEDIO <- sprintf("promedio global %.1f%%", GC_GLOBAL)
TXT_IZQ <- sprintf("rica en GC\n%.1f%% de media", MEDIA_IZQ)
TXT_DER <- sprintf("rica en AT\n%.1f%% de media", MEDIA_DER)

PIE <- sprintf(paste("Ventanas de %s pb no traslapadas. Fago lambda, NCBI %s.",
                     "El corte en %g kb está estimado de los datos\n(el que",
                     "minimiza la varianza dentro de cada mitad), no puesto a",
                     "ojo: separa %.1f%% de %.1f%% (p = %.0e)."),
               format(VENTANA, big.mark = ","), ACC, CORTE_KB,
               MEDIA_IZQ, MEDIA_DER, prueba$p.value)


construir <- function(d) {
  p <- ggplot(d, aes(x = kb, y = gc))

  if (HAY_CORTE) {
    p <- p +
      annotate("rect", xmin = 0, xmax = CORTE_KB, ymin = -Inf, ymax = Inf,
               fill = alpha(NARANJA, 0.07)) +
      annotate("rect", xmin = CORTE_KB, xmax = FIN_KB, ymin = -Inf, ymax = Inf,
               fill = alpha(AZUL, 0.07)) +
      annotate("segment", x = CORTE_KB, xend = CORTE_KB,
               y = -Inf, yend = Inf, colour = alpha(GRIS, 0.7),
               linewidth = 0.4, linetype = "dashed") +
      annotate("text", x = CORTE_KB / 2, y = max(d$gc) + 1.2, label = TXT_IZQ,
               size = 2.3, colour = GRIS, lineheight = 1.05,
               family = familia_base()) +
      annotate("text", x = (CORTE_KB + FIN_KB) / 2, y = max(d$gc) + 1.2,
               label = TXT_DER, size = 2.3, colour = GRIS, lineheight = 1.05,
               family = familia_base())
  }

  p +
    geom_hline(yintercept = GC_GLOBAL, colour = NARANJA, linewidth = 0.5,
               linetype = "dashed") +
    # La etiqueta del promedio va a la IZQUIERDA y por debajo de su línea: en
    # esa mitad la curva corre bien arriba del promedio y queda hueco. A la
    # derecha la curva cruza el promedio varias veces y la tapaba.
    annotate("text", x = 1, y = GC_GLOBAL - 1.8, label = TXT_PROMEDIO,
             hjust = 0, size = 2.4, colour = NARANJA,
             family = familia_base()) +
    geom_line(colour = AZUL, linewidth = 0.5) +
    scale_x_continuous(limits = c(0, FIN_KB), expand = expansion(0),
                       breaks = seq(0, 48, 8),
                       labels = function(x) paste0(x, " kb")) +
    scale_y_continuous(limits = c(min(d$gc) - 2, max(d$gc) + 5),
                       expand = expansion(0)) +
    labs(x = NULL, y = "Contenido de GC (%)", caption = PIE) +
    tema_libro()
}


if (!interactive()) {
  stopifnot(
    # --- Los datos ---
    length(seq_lambda) == 48502L,
    nrow(d) == 48L,                        # 48 ventanas completas de 1 kb
    COLA < VENTANA,                        # y una cola que no alcanza para otra
    all(d$gc >= 0 & d$gc <= 100),
    abs(GC_GLOBAL - 49.9) < 0.1,           # el 49.9 % del capítulo

    # --- El punto de cambio ---
    K > MARGEN, K < nrow(d) - MARGEN,
    HAY_CORTE,                             # si esto falla, hay que quitar bandas
    MEDIA_IZQ > MEDIA_DER,                 # primera mitad rica en GC
    prueba$p.value < 1e-6,
    R2 > 0.5,
    # el promedio global cae ENTRE las dos medias y no describe a ninguna:
    # es el punto entero del ejercicio 10
    GC_GLOBAL < MEDIA_IZQ, GC_GLOBAL > MEDIA_DER,
    min(abs(GC_GLOBAL - c(MEDIA_IZQ, MEDIA_DER))) > 4
  )

  message(sprintf("  %s: %s pb, GC global %.2f %%", ACC,
                  format(length(seq_lambda), big.mark = ","), GC_GLOBAL))
  message(sprintf("  %d ventanas de %s pb (sobran %d pb sin ventana)",
                  nrow(d), format(VENTANA, big.mark = ","), COLA))
  message(sprintf("  GC por ventana: de %.1f %% a %.1f %%", min(d$gc), max(d$gc)))
  message("")
  message(sprintf("  *** punto de cambio estimado: ventana %d  ->  %g kb", K, CORTE_KB))
  message(sprintf("      0-%g kb    media %.2f %%  (n = %d)", CORTE_KB, MEDIA_IZQ, K))
  message(sprintf("      %g-%.1f kb media %.2f %%  (n = %d)", CORTE_KB, FIN_KB,
                  MEDIA_DER, nrow(d) - K))
  message(sprintf("      diferencia %.2f puntos; t = %.1f; p = %.2e; R2 = %.3f",
                  MEDIA_IZQ - MEDIA_DER, prueba$statistic, prueba$p.value, R2))
  message(sprintf("      el promedio global (%.2f) cae entre las dos y no describe ninguna",
                  GC_GLOBAL))

  escribir_tsv(
    data.frame(inicio_pb = d$inicio, centro_kb = d$kb, gc = round(d$gc, 4),
               mitad = d$mitad, ventana_pb = VENTANA, accession = ACC,
               stringsAsFactors = FALSE),
    "gc-ventanas")
  guardar(construir(d), "gc-ventanas", 16, 8)
}
