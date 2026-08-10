## Fig. @fig-explosion (Sesión 6, "Por qué no se puede a mano")
## La explosión combinatoria.
##
## log10 del número de alineamientos contra la longitud n, con la línea de los
## ~10^80 átomos del universo observable cruzando la curva.
##
## La cuenta es C(2n, n), que es la que usa el capítulo (y la que da los
## 705,432 de la tabla del texto). Se calcula en log10 con lgamma porque el
## número desborda un double a partir de n = 150 o así:
##
##     log10 C(2n,n) = (lgamma(2n+1) - 2*lgamma(n+1)) / log(10)
##
## Un stopifnot comprueba que n = 11 dé exactamente 705,432 antes de escribir
## nada. Si algún día la fórmula se toca, el script truena.
##
## ---------------------------------------------------------------------------
## NOTA SOBRE LA TABLA DEL CAPÍTULO
##
## Los tres renglones de la tabla del .qmd salen de esta misma fórmula. Dos
## cuadran exactamente; el de n = 100 no:
##
##     n = 11   ->  705,432                   coincide
##     n = 100  ->  9.05e58, o sea ~10^59     el texto decía "más de 10^60"
##     n = 300  ->  10^179.13                 coincide
##
## Se corrigió el renglón de n = 100 en el .qmd para que no contradiga a la
## figura. El argumento no cambia: 10^59 sigue siendo veinte órdenes de
## magnitud arriba de los átomos del universo observable.
##
## Segunda nota, para quien la quiera perseguir: C(2n,n) es la cuenta clásica
## de los libros de texto, pero NO es exactamente "los alineamientos donde los
## huecos nunca se emparejan con huecos". Ésos son los números centrales de
## Delannoy, y para n = 11 dan 45,046,719, no 705,432. Las dos explotan igual
## de rápido, así que la moraleja del capítulo se sostiene, pero la frase del
## texto y el número que cita no son de la misma fórmula. Se dejó como está:
## cambiarlo es decisión del autor, no de la figura.
## ---------------------------------------------------------------------------
##
## Sin título dentro del SVG: el caption vive en el .qmd.
##
## Regenerar:  Rscript figuras/sesion06/04_explosion.R

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


# --- La cuenta --------------------------------------------------------------
log10_alineamientos <- function(n) {
  (lgamma(2 * n + 1) - 2 * lgamma(n + 1)) / log(10)
}

N_MAX <- 400L
curva <- data.frame(n = 1:N_MAX)
curva$log10 <- log10_alineamientos(curva$n)

# ~10^80 átomos en el universo observable (estimación de orden de magnitud que
# se cita siempre; el valor exacto depende de qué se cuente y no importa acá).
LOG_ATOMOS <- 80

# Primer n donde la curva pasa la línea. Es el momento visual de la figura.
N_CRUCE <- curva$n[which(curva$log10 >= LOG_ATOMOS)[1]]


# --- Los tres hitos ---------------------------------------------------------
# El de n = 11 se escribe con su valor exacto porque es el que cita la tabla
# del capítulo; los otros dos, en orden de magnitud, que es lo único que se
# puede leer a esa escala.
SUP <- c("0" = "⁰", "1" = "¹", "2" = "²", "3" = "³",
         "4" = "⁴", "5" = "⁵", "6" = "⁶", "7" = "⁷",
         "8" = "⁸", "9" = "⁹")
sup <- function(x) paste(SUP[strsplit(as.character(x), "")[[1]]], collapse = "")

hitos <- data.frame(n = c(11L, 100L, 300L))
hitos$log10 <- log10_alineamientos(hitos$n)
hitos$valor <- c(
  format(round(choose(22, 11)), big.mark = ",", scientific = FALSE),
  sprintf("%.1f × 10%s", 10^(hitos$log10[2] %% 1), sup(floor(hitos$log10[2]))),
  sprintf("≈ 10%s", sup(round(hitos$log10[3])))
)
# Dónde cae la etiqueta de cada hito. La curva parte el panel en dos zonas
# vacías y se usan las dos: la de n = 100 va arriba a la izquierda para no
# encimarse con la anotación del cruce, que cae justo a su derecha.
hitos$xt <- c(34, 62, 306)
hitos$yt <- c(7, 70, 158)
hitos$h  <- c(0, 1, 0)         # hjust del texto respecto de su ancla

TXT_ATOMOS <- sprintf("átomos estimados del universo observable (~10%s)",
                      sup(LOG_ATOMOS))
TXT_CRUCE  <- sprintf("la curva los pasa\nen n = %d", N_CRUCE)


# --- La figura --------------------------------------------------------------
construir <- function() {
  ggplot(curva, aes(x = n, y = log10)) +
    # --- La referencia de los átomos ---
    geom_hline(yintercept = LOG_ATOMOS, colour = NARANJA,
               linewidth = 0.5, linetype = "22") +
    annotate("text", x = N_MAX - 4, y = LOG_ATOMOS + 7, label = TXT_ATOMOS,
             family = familia_base(), size = 2.6, colour = NARANJA, hjust = 1) +

    # --- La curva ---
    geom_line(colour = AZUL, linewidth = 0.6) +

    # --- El cruce ---
    annotate("point", x = N_CRUCE, y = LOG_ATOMOS, colour = NARANJA, size = 1.9) +
    annotate("segment", x = N_CRUCE + 12, xend = N_CRUCE + 2,
             y = LOG_ATOMOS - 22, yend = LOG_ATOMOS - 3,
             colour = NARANJA, linewidth = 0.35) +
    annotate("text", x = N_CRUCE + 15, y = LOG_ATOMOS - 26, label = TXT_CRUCE,
             family = familia_base(), size = 2.6, colour = NARANJA,
             hjust = 0, vjust = 1, lineheight = 1.15) +

    # --- Los tres hitos ---
    geom_point(data = hitos, aes(x = n, y = log10), colour = AZUL, size = 1.9) +
    geom_segment(data = hitos, aes(x = n, xend = xt, y = log10, yend = yt),
                 colour = alpha(AZUL, 0.55), linewidth = 0.35) +
    geom_text(data = hitos,
              aes(x = xt + ifelse(h == 0, 5, -5), y = yt, hjust = h,
                  label = sprintf("n = %d\n%s", n, valor)),
              family = familia_base(), size = 2.7, colour = AZUL,
              vjust = 0.5, lineheight = 1.15) +

    scale_x_continuous(breaks = seq(0, N_MAX, 100), expand = expansion(mult = c(0.01, 0.03))) +
    scale_y_continuous(breaks = seq(0, 240, 40), expand = expansion(mult = c(0.02, 0.05))) +
    labs(x = "longitud de cada secuencia (residuos)",
         y = "número de alineamientos (log10)",
         caption = paste("C(2n, n), calculado en log10 con lgamma.",
                         "La escala del eje y es el EXPONENTE:",
                         "cada 40 son cuarenta órdenes de magnitud.")) +
    tema_libro()
}


if (!interactive()) {
  exacto_11 <- round(choose(2 * 11, 11))

  stopifnot(
    # --- EL REQUISITO: n = 11 tiene que dar 705,432 ---
    exacto_11 == 705432,
    abs(log10_alineamientos(11) - log10(705432)) < 1e-9,

    # --- La curva ---
    nrow(curva) == N_MAX,
    all(diff(curva$log10) > 0),                 # crece siempre
    all(is.finite(curva$log10)),                # lgamma no desborda
    # el término dominante es 4^n / sqrt(pi n): que la asintótica cuadre
    abs(curva$log10[N_MAX] -
        (2 * N_MAX * log10(2) - 0.5 * log10(pi * N_MAX))) < 0.01,

    # --- El cruce ---
    curva$log10[N_CRUCE] >= LOG_ATOMOS,
    curva$log10[N_CRUCE - 1] < LOG_ATOMOS,
    N_CRUCE > 1, N_CRUCE < N_MAX,

    # --- Los hitos caen donde el capítulo dice ---
    hitos$n[1] == 11, hitos$n[2] == 100, hitos$n[3] == 300,
    round(hitos$log10[3]) == 179,               # el 10^179 de la tabla
    # ninguna etiqueta cae encima de la curva ni de la línea de los átomos
    all(abs(hitos$yt - log10_alineamientos(hitos$xt)) > 10),
    all(abs(hitos$yt - LOG_ATOMOS) > 8),
    all(hitos$yt > 0), all(hitos$yt < max(curva$log10))
  )

  message(sprintf("  n = 11  -> %s alineamientos  (log10 = %.4f)",
                  format(exacto_11, big.mark = ","), log10_alineamientos(11)))
  message(sprintf("  n = 100 -> %s              (log10 = %.4f)",
                  hitos$valor[2], hitos$log10[2]))
  message(sprintf("  n = 300 -> %s                    (log10 = %.4f)",
                  hitos$valor[3], hitos$log10[3]))
  message(sprintf("  la curva pasa los 10^%d en n = %d (log10 = %.2f; en n = %d era %.2f)",
                  LOG_ATOMOS, N_CRUCE, curva$log10[N_CRUCE],
                  N_CRUCE - 1, curva$log10[N_CRUCE - 1]))
  message("  aviso: el .qmd decía \"más de 10^60\" para n = 100; el valor real es 9.1 x 10^58")

  salida <- data.frame(
    n     = curva$n,
    log10 = round(curva$log10, 6),
    hito  = ifelse(curva$n %in% hitos$n, "tabla del capítulo",
                   ifelse(curva$n == N_CRUCE, "cruce con 10^80", ""))
  )
  escribir_tsv(salida, "explosion")
  guardar(construir(), "explosion", 16, 9)
}
