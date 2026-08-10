## Fig. @fig-gc-ventanas (Sesión 01, § Un promedio puede esconderlo todo) —
## Contenido de GC en ventanas de 500 pb a lo largo del genoma del fago lambda.
##
## Es la figura que sostiene el argumento del capítulo: el promedio global
## (49.9 %) sugiere un genoma parejo, y no lo es. La primera mitad es rica en GC
## y la segunda en AT, con un cambio abrupto en medio. Lambda es el ejemplo de
## libro de un punto de cambio.
##
## Todo sale del FASTA de datos/: longitud, promedio global y cada ventana. No
## hay ni un número pegado a mano en la figura.
##
## Sin título dentro del SVG: el caption vive en el .qmd.
##
## Regenerar:  Rscript figuras/sesion01/03_gc_ventanas.R

# `_tema.R` vive junto a este script: se ubica el archivo para que
# `Rscript figuras/sesion01/<script>.R` corra desde la raíz del repo.
.ubicar <- function() {
  # Si el script se corrió con source() (RStudio, o desde otro script), el path
  # correcto es el `ofile` que source() deja en su frame. Se busca ESO primero:
  # commandArgs("--file=") apuntaría al script de AFUERA, no a éste.
  for (i in rev(seq_len(sys.nframe()))) {   # de adentro hacia afuera
    o <- sys.frame(i)$ofile
    if (!is.null(o)) return(normalizePath(o, winslash = "/"))
  }
  a <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1]), winslash = "/"))
  stop("no se pudo ubicar el script: correr con Rscript o con source()")
}
source(file.path(dirname(.ubicar()), "_tema.R"))

# --- Parámetros -------------------------------------------------------------
# Fuente del genoma: NCBI RefSeq NC_001416.1, descargado por
# 00_descarga_datos.sh. `lambda.fasta` es la copia con nombre legible del mismo
# archivo (md5 idéntico a NC_001416.1.fasta, comprobado).
ARCHIVO  <- "lambda.fasta"
ACCESION <- "NC_001416.1"

# Ventana de 500 pb, la que usa el capítulo. Es el compromiso de siempre: con
# ventanas mucho más chicas el ruido de muestreo (±~2 puntos porcentuales de
# desviación estándar a 500 pb, el doble a 125) tapa la señal; con ventanas
# mucho más grandes el punto de cambio se promedia hasta desaparecer, que es
# justo el error que la figura enseña a evitar.
W <- 500L

# Ancla de longitud: la que publica el registro de NCBI y la que reporta el
# capítulo. Se comprueba abajo con stopifnot; si el FASTA que hay en datos/ no
# es éste, el script truena en vez de dibujar otro genoma.
N_ESPERADO <- 48502L

# Ancla de composición. OJO: el capítulo dice "24198 bases G/C"; el conteo real
# sobre este FASTA es 24182 (C = 11362 + G = 12820). La discrepancia ya está
# reportada al autor. Esta figura muestra lo que calcula del archivo.
GC_ESPERADO <- 24182L

# Ancho aproximado de la etiqueta del promedio, en kilobases sobre el eje X,
# medido en la figura ya renderizada. No necesita ser exacto: solo delimita el
# tramo del trazo que la etiqueta podría tapar (ver altura_etiqueta).
ANCHO_ETIQUETA_KB <- 12


#' Altura a la que se coloca la etiqueta del promedio global.
#'
#' Lo natural sería pegarla a la línea punteada, pero ahí se encima con el
#' trazo: en la mitad derecha varias ventanas cruzan el promedio (la de 39.8 kb
#' llega a 54.4 %) y la línea de datos parte la etiqueta a la mitad. Se sube al
#' hueco de arriba a la derecha, que en este genoma está vacío porque esa mitad
#' es rica en AT. La altura sale del propio trazo y no de un número a mano, para
#' que siga sin encimarse si cambia el tamaño de ventana o el genoma.
altura_etiqueta <- function(df) {
  corte <- max(df$pos) - ANCHO_ETIQUETA_KB * 1000
  max(df$gc[df$pos >= corte]) + 0.06 * diff(range(df$gc))
}


calcular <- function() {
  # `secuencia` y no `seq`: `seq` es una función base y sombrearla dentro de una
  # función que además usa seq.int() invita a un error tonto.
  secuencia <- leer_fasta(ruta_datos(ARCHIVO))
  n     <- nchar(secuencia)
  bases <- strsplit(secuencia, "")[[1]]

  # Vector lógico G/C calculado UNA vez sobre el genoma completo, en lugar de un
  # `%in%` por ventana: mismo resultado, y el conteo por ventana queda en una
  # sola suma sobre un rango.
  es_gc <- bases %in% c("G", "C")

  # Ventanas NO traslapadas. El último arranque posible es n - W + 1, así que la
  # ventana parcial del final se descarta: 48502 no es múltiplo de 500 y quedan
  # 2 pb fuera del análisis. Se descartan a propósito: una ventana de 2 bases
  # solo puede valer 0, 50 o 100 % de GC, y ese punto de ruido puro se dibujaría
  # con el mismo peso visual que las 97 ventanas completas.
  inicio <- seq.int(1L, n - W + 1L, by = W)
  gc_ventana <- vapply(inicio, function(i) 100 * sum(es_gc[i:(i + W - 1L)]) / W,
                       numeric(1))

  # La ventana se grafica en su punto medio, no en su arranque: es la posición
  # que representa el valor.
  df <- data.frame(pos = inicio + W %/% 2L, gc = gc_ventana)

  # "Primera mitad" se define por la posición en el GENOMA, no partiendo la
  # lista de ventanas en dos partes iguales: son 97 ventanas, un número impar, y
  # partir la lista dejaría la ventana de en medio arbitrariamente de un lado.
  mitad <- n / 2

  list(
    df         = df,
    n          = n,
    gc_bases   = sum(es_gc),
    gc_global  = 100 * sum(es_gc) / n,
    gc_mitad1  = mean(df$gc[df$pos <= mitad]),
    gc_mitad2  = mean(df$gc[df$pos >  mitad]),
    sobrantes  = n - length(inicio) * W,
    # leer_fasta() ya quitó todo lo no alfabético, pero una N o un carácter
    # ambiguo pasaría entero y se contaría como "no GC", bajando el promedio en
    # silencio. Se cuenta para poder afirmarlo, no para suponerlo.
    fuera_acgt = sum(!bases %in% c("A", "C", "G", "T"))
  )
}


construir <- function(d) {
  ggplot(d$df, aes(x = pos / 1000, y = gc)) +
    # El promedio global va ANTES del trazo para que la línea de datos quede
    # encima de la referencia y no al revés.
    geom_hline(yintercept = d$gc_global, linetype = "dashed",
               colour = NARANJA, linewidth = 0.4) +
    geom_line(colour = AZUL, linewidth = 0.5) +
    # Alineada al extremo derecho, en ámbar como la línea que describe: es lo
    # único ámbar de la figura, así que la asociación se lee sola aunque la
    # etiqueta no esté pegada a la línea.
    annotate("text", x = max(d$df$pos) / 1000, y = altura_etiqueta(d$df),
             label = sprintf("promedio global %.1f%%", d$gc_global),
             hjust = 1, size = 2.8, colour = NARANJA) +
    # Marcas cada 10 kb: el eje se lee contra la escala del genoma (48.5 kb) sin
    # tener que contar.
    scale_x_continuous(breaks = seq(0, 50, by = 10)) +
    labs(x = "Posición en el genoma (kb)", y = "Contenido de GC (%)",
         caption = sprintf("Ventanas de %d pb no traslapadas. Fago lambda, NCBI %s.",
                           W, ACCESION)) +
    tema_libro()
}


if (!interactive()) {
  d <- calcular()
  y_etq <- altura_etiqueta(d$df)
  techo_derecha <- max(d$df$gc[d$df$pos >= max(d$df$pos) - ANCHO_ETIQUETA_KB * 1000])

  stopifnot(
    d$n == N_ESPERADO,                    # es el genoma que dice ser
    d$gc_bases == GC_ESPERADO,            # conteo real, no el 24198 del capítulo
    d$fuera_acgt == 0,                    # sin N ni códigos ambiguos
    abs(d$gc_global - 49.86) < 0.05,      # el capítulo lo redondea a 49.9 %
    # La afirmación del texto: la primera mitad es rica en GC y la segunda en
    # AT. Se exige un margen de 5 puntos porcentuales para que no la pase una
    # diferencia que sea ruido.
    d$gc_mitad1 - d$gc_mitad2 > 5,
    # El hueco donde va la etiqueta sigue vacío: arriba del trazo de ese tramo y
    # dentro del rango que la figura ya dibuja, o sea sin encimarse ni salirse.
    y_etq > techo_derecha,
    y_etq < max(d$df$gc)
  )

  message(sprintf("  lambda %s: %d pb, %d bases G/C", ACCESION, d$n, d$gc_bases))
  message(sprintf("  GC global = %.1f%% (%.4f%% sin redondear)",
                  d$gc_global, d$gc_global))
  message(sprintf("  %d ventanas de %d pb; %d pb sobrantes al final, descartadas",
                  nrow(d$df), W, d$sobrantes))
  message(sprintf("  GC medio por ventana: 1a mitad %.1f%% · 2a mitad %.1f%% (Δ %.1f pp)",
                  d$gc_mitad1, d$gc_mitad2, d$gc_mitad1 - d$gc_mitad2))
  message(sprintf("  rango por ventana: %.1f%% a %.1f%%",
                  min(d$df$gc), max(d$df$gc)))

  # El GC de una ventana de 500 pb es siempre un múltiplo exacto de 0.2, así que
  # escribirlo con una decimal no pierde nada y evita los 0.20000000000000001
  # que saldrían del formato por defecto.
  escribir_tsv(data.frame(pos = d$df$pos, gc = sprintf("%.1f", d$df$gc)),
               "gc-ventanas-lambda")
  guardar(construir(d), "gc-ventanas-lambda", w = 16, h = 8)
}
