## Fig. @fig-brecha (Sesión 01, § El diluvio de datos) — La brecha de anotación
## en UniProtKB: lo revisado a mano (Swiss-Prot) contra lo anotado
## automáticamente (TrEMBL). Barras horizontales en escala log10.
##
## El punto pedagógico es la diferencia de ~260x, no los valores absolutos.
##
## Sin título dentro del SVG: el caption vive en el .qmd.
##
## Regenerar:  Rscript figuras/sesion01/brecha-anotacion.R

# `estilo.R` vive en figuras/, un nivel arriba: se ubica este script para que
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
source(file.path(dirname(dirname(.ubicar())), "estilo.R"))

# --- Datos -----------------------------------------------------------------
# Fuente: UniProt release 2026_02 (10-jun-2026).
# https://ftp.uniprot.org/pub/databases/uniprot/current_release/relnotes.txt
# Verificado 2026-08-03; Swiss-Prot cotejado además contra
# https://web.expasy.org/docs/relnotes/relstat.html
# La nota de release da los tres números explícitos, así que TrEMBL no se
# deriva por resta: viene publicado.
VERSION       <- "2026_02"
FECHA_VERSION <- "10-jun-2026"
SWISSPROT       <-    575503   # revisadas, curadas a mano
TREMBL          <- 149234636   # no revisadas, anotación automática
UNIPROTKB_TOTAL <- 149810139   # el total que reporta la nota de release

# NOTA: UniProtKB se reorganizó en 2026_02 (se removieron ~141 M entradas
# redundantes de TrEMBL). Antes de esa limpieza TrEMBL rondaba ~250 M. Al
# actualizar, usar la cifra viva de la versión que toque, no escalar ésta.

BASE_BARRA <- 1e4   # origen visual de las barras (no hay cero en escala log)

ETQ_SP <- "Revisadas a mano\n(Swiss-Prot)"
ETQ_TR <- "Anotadas automáticamente\n(TrEMBL)"


construir <- function() {
  # La barra chica arriba (y = 2), para que la comparación se lea de un vistazo.
  d <- data.frame(
    etiqueta = c(ETQ_TR, ETQ_SP),
    y        = c(1, 2),
    valor    = c(TREMBL, SWISSPROT),
    color    = c(GRIS, VERDE)
  )

  # La razón se redondea a la decena para que diga lo mismo que el cuerpo del
  # capítulo ("aproximadamente 260 a 1") y no un 259 que invita a leerlo como
  # exacto.
  razon <- round(TREMBL / SWISSPROT, -1)

  # geom_col NO sirve acá: arranca la barra en cero, y en log10 el cero es -Inf.
  # Se dibujan rectángulos explícitos de BASE_BARRA al valor, igual que hacía la
  # versión de matplotlib con barh(left = BASE_BARRA).
  ggplot(d) +
    geom_rect(aes(xmin = BASE_BARRA, xmax = valor,
                  ymin = y - 0.25, ymax = y + 0.25, fill = etiqueta)) +
    # nudge_x va en espacio YA transformado: 0.13 en log10 es un factor de 1.35.
    geom_text(aes(x = valor, y = y,
                  label = format(valor, big.mark = " ", scientific = FALSE)),
              hjust = 0, nudge_x = 0.13, size = 3.5, fontface = "bold",
              colour = TEXTO) +
    # x en unidades de DATO: la escala lo transforma, no hay que pasar log10().
    annotate("text", x = BASE_BARRA * 2.2, y = 1.5, hjust = 0,
             label = sprintf("≈ %d× más secuencias que anotación revisada",
                             razon),
             size = 3.7, colour = TEXTO) +
    scale_fill_manual(values = setNames(d$color, d$etiqueta), guide = "none") +
    scale_x_log10(breaks = 10 ^ (4:9), labels = fmt_conteo,
                  expand = expansion(0)) +
    scale_y_continuous(breaks = d$y, labels = d$etiqueta,
                       limits = c(0.45, 2.55), expand = expansion(0)) +
    coord_cartesian(xlim = c(BASE_BARRA, 3e9), clip = "off") +
    labs(x = "entradas en UniProtKB (escala logarítmica)", y = NULL,
         caption = sprintf(paste("Fuente: UniProt %s (junio 2026). Escala logarítmica.",
                                 "Cifras sujetas a cambio en cada versión."),
                           VERSION)) +
    tema_lgc() +
    theme(panel.grid.major.y = element_blank(),
          axis.line.y  = element_blank(),
          axis.ticks.y = element_blank(),
          axis.text.y  = element_text(hjust = 1, lineheight = 1.05),
          plot.margin  = margin(4, 22, 4, 4))
}


if (!interactive()) {
  stopifnot(SWISSPROT + TREMBL == UNIPROTKB_TOTAL)   # las partes suman el total
  razon <- TREMBL / SWISSPROT
  pct   <- 100 * SWISSPROT / UNIPROTKB_TOTAL
  message(sprintf("  UniProt %s (%s)", VERSION, FECHA_VERSION))
  message(sprintf("  razón TrEMBL:Swiss-Prot = %.1f : 1", razon))
  message(sprintf("  revisadas = %.2f%% del total", pct))
  guardar(construir(), "brecha-anotacion", subdir = "sesion01")
}
