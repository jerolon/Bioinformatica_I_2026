## Fig. @fig-crecimiento (Sesión 01, § El diluvio de datos) — Crecimiento de
## GenBank en número de bases, eje Y logarítmico.
##
## Van DOS series, y la razón es de honestidad con la fuente:
##
##   · GenBank "tradicional" (1982-2026). Es la tabla oficial "Growth of GenBank"
##     de las release notes, completa. NCBI le cuelga a ESA serie la afirmación
##     de que las bases se duplican cada ~18 meses.
##   · Total incluyendo WGS/TSA/TLS (2019-2026). Las release notes sólo reportan
##     el agregado set-based a partir de la release 235 (dic 2019); antes de eso
##     decían explícitamente que los datos WGS "no están representados aquí" y se
##     distribuían por separado. Graficar un total desde 1982 dibujaría un salto
##     de 2019 que es un artefacto del reporte, no del crecimiento.
##
## La segunda serie es la que corresponde al número que cita el capítulo (49.73
## billones de bases en la versión 269.0), así que tiene que estar.
##
## Sin título dentro del SVG: el caption vive en el .qmd.
##
## Regenerar:  Rscript figuras/sesion01/crecimiento-genbank.R

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
# Fuente: NCBI, GenBank release notes, § 2.2.8 "Growth of GenBank".
# ftp://ftp.ncbi.nlm.nih.gov/genbank/gbrel.txt  (leído 2026-08-03, release 272.0)
# Un punto por año: la última release de cada año. La tabla oficial trae 236
# releases; se toma una por año para que el script siga siendo legible.
GENBANK_TRADICIONAL <- data.frame(
  anio = c(
    1982, 1983, 1984, 1985, 1986, 1987, 1988, 1989, 1990, 1991, 1992, 1993,
    1994, 1995, 1996, 1997, 1998, 1999, 2000, 2001, 2002, 2003, 2004, 2005,
    2006, 2007, 2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017,
    2018, 2019, 2020, 2021, 2022, 2023, 2024, 2025, 2026),
  mes = c(
    12, 11, 11,  9, 11, 12, 12, 12, 12, 12, 12, 12,
    12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12,
    12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12,
    12, 12, 12, 12, 12, 12, 12, 12,  6),
  bases = c(
             680338,         2274029,         3689752,         5204420,         9615371,
           16752872,        24690876,        37183950,        51306092,        77337678,
          120242234,       163802597,       230485928,       425860958,       730552938,
         1258290513,      2162067871,      4653932745,     11101066288,     15849921438,
        28507990166,     36553368485,     44575745176,     56037734462,     69019290705,
        83874179730,     99116431942,    110118557163,    122082812719,    135117731375,
       148390863904,    156230531562,    184938063614,    203939111071,    224973060433,
       249722163594,    285688542186,    388417258009,    723003822007,   1053275115030,
      1635594138493,   2570711588044,   5085904976338,   6651459875408,   7618210921117)
)

# Total = tradicional + set-based (WGS/TSA/TLS), leído del encabezado de cada
# release notes archivada en ftp.ncbi.nlm.nih.gov/genbank/release.notes/.
# Sólo desde la release 235 (dic 2019): antes no se reportaba el agregado.
GENBANK_TOTAL_CON_WGS <- data.frame(
  anio  = c(2019, 2020, 2021, 2022, 2023, 2024, 2025, 2026),
  mes   = c(  12,   12,   12,   12,   12,   12,   12,    6),
  bases = c(
     7002682071442,   # rel 235:  0.39 Tb trad +  6.61 Tb WGS
    12979089734857,   # rel 241
    16472323371440,   # rel 247
    21378050803566,   # rel 253
    27942667518683,   # rel 259
    38966101308627,   # rel 264: 38.97 Tb
    49734431090421,   # rel 269: 49.73 Tb  <- la cifra del capítulo
    57686501377443)   # rel 272: 7.62 Tb trad + 50.07 Tb WGS
)

# Anclas de verificación.
ANCLA_REL_3       <- 680338            # dic 1982, primera release tabulada
ANCLA_REL_269     <- 49734431090421    # dic 2025, el 49.73 Tb del capítulo
DUPLICACION_MESES <- 18                # NCBI: las bases doblan cada ~18 meses

SERIE_TRAD  <- "GenBank tradicional"
SERIE_TOTAL <- "Total, incluyendo WGS"


construir <- function() {
  trad  <- transform(GENBANK_TRADICIONAL,   x = a_fraccion(anio, mes),
                     serie = SERIE_TRAD)
  total <- transform(GENBANK_TOTAL_CON_WGS, x = a_fraccion(anio, mes),
                     serie = SERIE_TOTAL)
  d <- rbind(trad, total)
  d$serie <- factor(d$serie, levels = c(SERIE_TRAD, SERIE_TOTAL))

  ggplot(d, aes(x = x, y = bases, colour = serie, shape = serie)) +
    geom_line(linewidth = 0.7) +
    geom_point(size = 1.1) +
    # El dato que cita el capítulo, señalado. El anillo es necesario: la versión
    # 269.0 y la 272.0 quedan pegadas en el eje, y una guía sola apuntaría
    # ambiguamente a las dos.
    annotate("point", x = a_fraccion(2025, 12), y = ANCLA_REL_269,
             shape = 21, size = 3.4, colour = GRIS, fill = NA, stroke = 0.45) +
    annotate("segment", x = 2019.5, xend = a_fraccion(2025, 12),
             y = 1.05e14, yend = 6.6e13, colour = GRIS, linewidth = 0.3) +
    annotate("text", x = 2019.2, y = 1.05e14, hjust = 1, vjust = 0.5,
             label = "49.73 Tb\n(versión 269.0)", size = 2.9, colour = GRIS,
             lineheight = 1.05) +
    scale_colour_manual(values = setNames(c(TEAL, AMBAR),
                                          c(SERIE_TRAD, SERIE_TOTAL))) +
    scale_shape_manual(values = setNames(c(16, 15), c(SERIE_TRAD, SERIE_TOTAL))) +
    scale_y_log10(breaks = 10 ^ seq(6, 14, 2), labels = fmt_bases,
                  limits = c(2e5, 4e14), expand = expansion(0)) +
    scale_x_continuous(breaks = seq(1985, 2025, 10), limits = c(1980.5, 2028.5),
                       expand = expansion(0)) +
    labs(x = "año", y = "bases (escala logarítmica)",
         caption = paste("Fuente: NCBI GenBank, versión 269.0 (diciembre 2025).",
                         "El total se duplica cada ~18 meses.")) +
    tema_lgc() +
    theme(legend.position = "inside",
          legend.position.inside = c(0.01, 0.99),
          legend.justification = c(0, 1),
          legend.key.width = unit(18, "pt"))
}


if (!interactive()) {
  stopifnot(
    GENBANK_TRADICIONAL$bases[1] == ANCLA_REL_3,
    GENBANK_TOTAL_CON_WGS$bases[nrow(GENBANK_TOTAL_CON_WGS) - 1] == ANCLA_REL_269
  )

  # ¿Se sostiene el "doblan cada ~18 meses"? Ajuste log-lineal a la serie
  # tradicional completa, que es a la que NCBI le atribuye la afirmación.
  x <- a_fraccion(GENBANK_TRADICIONAL$anio, GENBANK_TRADICIONAL$mes)
  y <- log2(GENBANK_TRADICIONAL$bases)
  pendiente <- unname(coef(lm(y ~ x))[2])          # duplicaciones por año
  message(sprintf("  puntos: %d tradicional, %d con WGS",
                  nrow(GENBANK_TRADICIONAL), nrow(GENBANK_TOTAL_CON_WGS)))
  message(sprintf("  duplicación observada (serie tradicional): %.1f meses  (NCBI dice ~%d)",
                  12 / pendiente, DUPLICACION_MESES))
  guardar(construir(), "crecimiento-genbank", subdir = "sesion01")
}
