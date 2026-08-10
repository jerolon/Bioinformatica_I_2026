## Fig. @fig-costos (Sesión 01, § El diluvio de datos) — Costo de secuenciar un
## genoma humano contra una tendencia tipo ley de Moore. Eje Y logarítmico: el
## punto es el quiebre de 2008, cuando la curva real se despega de Moore.
##
## Sin título dentro del SVG: el caption vive en el .qmd.
##
## Regenerar:  Rscript figuras/sesion01/costo-secuenciacion.R

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
# Fuente: NHGRI, "DNA Sequencing Costs: Data", serie "Cost per Genome".
# https://www.genome.gov/about-genomics/fact-sheets/DNA-Sequencing-Costs-Data
# Archivo oficial: Sequencing_Cost_Data_Table_May2022.xls (descargado 2026-08-03).
# Es la serie completa publicada, no un muestreo: 78 puntos, sep-2001 a may-2022.
COSTO_GENOMA <- data.frame(
  anio = c(
    2001, 2002, 2002, 2003, 2003, 2004, 2004, 2004, 2004, 2005, 2005, 2005,
    2005, 2006, 2006, 2006, 2006, 2007, 2007, 2007, 2007, 2008, 2008, 2008,
    2008, 2009, 2009, 2009, 2009, 2010, 2010, 2010, 2010, 2011, 2011, 2011,
    2011, 2012, 2012, 2012, 2012, 2013, 2013, 2013, 2013, 2014, 2014, 2014,
    2014, 2015, 2015, 2015, 2015, 2016, 2016, 2016, 2017, 2017, 2017, 2017,
    2018, 2018, 2018, 2018, 2019, 2019, 2019, 2019, 2020, 2020, 2020, 2020,
    2021, 2021, 2021, 2021, 2022, 2022),
  mes = c(
     9,  3,  9,  3, 10,  1,  4,  7, 10,  1,  4,  7,
    10,  1,  4,  7, 10,  1,  4,  7, 10,  1,  4,  7,
    10,  1,  4,  7, 10,  1,  4,  7, 10,  1,  4,  7,
    10,  1,  4,  7, 10,  1,  4,  7, 10,  1,  4,  7,
    10,  1,  4,  7, 10,  5,  8, 11,  2,  5,  8, 11,
     2,  5,  8, 11,  2,  5,  8, 11,  2,  5,  8, 11,
     2,  5,  8, 11,  2,  5),
  usd = c(
       95263071.92,    70175437.42,    61448421.50,    53751684.08,    40157554.23,    28780376.21,
       20442576.14,    19934345.74,    18519312.16,    17534969.56,    16159699.44,    16180224.10,
       13801124.19,    12585658.90,    11732534.52,    11455315.22,    10474556.36,     9408738.91,
        9047002.97,     8927342.14,     7147571.39,     3063819.99,     1352982.23,      752079.90,
         342502.06,      232735.44,      154713.60,      108065.14,       70333.33,       46774.27,
          31512.04,       31124.96,       29091.73,       20962.78,       16712.01,       10496.93,
           7743.44,        7666.22,        5901.29,        5984.72,        6618.35,        5671.35,
           5550.26,        5550.26,        5096.08,        4008.11,        4920.50,        4904.85,
           5730.89,        3969.84,        4210.79,        1363.24,        1245.31,        1175.74,
           1507.77,        1355.79,        1015.38,        1333.40,        1133.96,        1844.08,
           1232.28,        1463.13,        1467.28,        1391.68,         993.14,         606.32,
            942.15,         695.37,         644.62,         701.56,         688.57,         511.97,
            850.84,         454.05,         562.18,         552.20,         524.62,         524.62)
)

# Anclas de verificación (si al regenerar estos números no cuadran, la serie
# de arriba se desactualizó o se leyó mal). Comprobadas contra el .xls oficial.
ANCLA_2001     <- 95263072   # sep-2001, primer punto de la serie
ANCLA_2008_ENE <- 3063820    # ene-2008, justo antes del desplome
ANCLA_2022     <- 525        # may-2022, último punto publicado (524.62)
# Referencia externa, NO del NHGRI y no graficada: Illumina anunció en 2023 el
# cruce del umbral de ~200 USD por genoma. El capítulo la cita en prosa.

ANIO_NGS      <- 2008        # llegada de la NGS: el quiebre de la curva
PERIODO_MOORE <- 2           # la ley de Moore dobla cada ~2 años


construir <- function() {
  d <- transform(COSTO_GENOMA, x = a_fraccion(anio, mes))

  # Tendencia tipo ley de Moore: parte del mismo costo inicial y se divide a la
  # mitad cada dos años. No es un dato, es la referencia contra la que se
  # compara; por eso va punteada.
  x0 <- d$x[1]; y0 <- d$usd[1]
  moore <- data.frame(x = seq(x0, d$x[nrow(d)], length.out = 200))
  moore$usd <- y0 * 0.5 ^ ((moore$x - x0) / PERIODO_MOORE)

  ggplot(mapping = aes(x = x, y = usd)) +
    geom_vline(xintercept = ANIO_NGS, colour = GRIS, linewidth = 0.35,
               linetype = "dotted") +
    annotate("text", x = ANIO_NGS + 0.55, y = 2.2e7, label = "2008: llega NGS",
             hjust = 0, vjust = 0.5, size = 3.1, colour = GRIS) +
    geom_line(data = moore, aes(colour = "Tendencia tipo ley de Moore"),
              linewidth = 0.65, linetype = "22") +
    geom_line(data = d, aes(colour = "Costo real (NHGRI)"), linewidth = 0.7) +
    geom_point(data = d, aes(colour = "Costo real (NHGRI)"), size = 0.7) +
    scale_colour_manual(
      values = c("Costo real (NHGRI)" = TEAL,
                 "Tendencia tipo ley de Moore" = AMBAR),
      breaks = c("Costo real (NHGRI)", "Tendencia tipo ley de Moore")) +
    scale_y_log10(breaks = 10 ^ (2:8), labels = fmt_dolar,
                  limits = c(200, 3e8), expand = expansion(0)) +
    scale_x_continuous(breaks = seq(2002, 2022, 4), limits = c(2000.5, 2023.2),
                       expand = expansion(0)) +
    labs(x = "año", y = "costo por genoma (escala logarítmica)",
         caption = "Fuente: NHGRI, 2001-2022. Escala logarítmica.") +
    tema_lgc() +
    theme(legend.position = "inside",
          legend.position.inside = c(0.99, 0.99),
          legend.justification = c(1, 1),
          legend.key.width = unit(18, "pt"))
}


if (!interactive()) {
  # Verificación de las anclas: barata y atrapa una serie mal pegada.
  stopifnot(
    round(COSTO_GENOMA$usd[1]) == ANCLA_2001,
    round(COSTO_GENOMA$usd[nrow(COSTO_GENOMA)]) == ANCLA_2022
  )
  caida <- COSTO_GENOMA$usd[1] / COSTO_GENOMA$usd[nrow(COSTO_GENOMA)]
  message(sprintf("  puntos NHGRI: %d", nrow(COSTO_GENOMA)))
  message(sprintf("  caída total: %sx  (%s -> %.2f USD)",
                  format(round(caida), big.mark = ","),
                  format(COSTO_GENOMA$usd[1], big.mark = ",", scientific = FALSE),
                  COSTO_GENOMA$usd[nrow(COSTO_GENOMA)]))
  guardar(construir(), "costo-secuenciacion", subdir = "sesion01")
}
