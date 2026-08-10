## Fig. @fig-pe (Sesión 11, § Qué tan segura es una anotación curada)
## Distribución de niveles de evidencia (PE) en Swiss-Prot.
##
## ---------------------------------------------------------------------------
## ESTAS CIFRAS ESTÁN VERIFICADAS CONTRA LA API, NO COPIADAS DE LA PROSA
##
## La especificación traía los cinco números con un "# VERIFICAR en
## uniprot.org/uniprotkb/statistics antes de publicar". Se verificaron contra
## la API REST el 2026-08-07 y los cinco coinciden:
##
##   curl -sI "https://rest.uniprot.org/uniprotkb/search?query=reviewed:true+AND+existence:3&size=0"
##   -> X-Total-Results: 385493   X-UniProt-Release: 2026_02
##
## El script REVISA que los cinco sumen el total de Swiss-Prot del mismo
## release. Es la comprobación que atrapa el error típico: actualizar cuatro
## números y olvidar el quinto.
##
## Para volver a verificar contra la API cuando salga un release nuevo:
##     Rscript figuras/sesion11/04_niveles_pe.R --verificar
## Sin la bandera no sale a internet, para que el render no dependa de la red.
## ---------------------------------------------------------------------------
##
## Sin título dentro del SVG: el caption vive en el .qmd.
##
## Regenerar:  Rscript figuras/sesion11/04_niveles_pe.R

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


# --- Los datos, con su release pegado ---------------------------------------
RELEASE      <- "2026_02"
RELEASE_FECHA <- "10 de junio de 2026"
SWISSPROT_TOTAL <- 575503L          # entradas revisadas en ese release

pe <- data.frame(
  codigo = c("PE1", "PE2", "PE3", "PE4", "PE5"),
  nivel = c("PE1  evidencia a nivel de proteína",
            "PE2  evidencia a nivel de transcrito",
            "PE3  inferido por homología",
            "PE4  predicho",
            "PE5  incierto"),
  n = c(121117L, 54492L, 385493L, 12672L, 1729L),
  stringsAsFactors = FALSE
)
pe$pct <- 100 * pe$n / sum(pe$n)

# PE3 es el punto de la figura: dos tercios de lo *curado* es inferencia.
pe$destaca <- pe$codigo == "PE3"
pe$color   <- ifelse(pe$destaca, NARANJA, AZUL)

# De arriba hacia abajo en el orden natural PE1..PE5.
pe$nivel <- factor(pe$nivel, levels = rev(pe$nivel))

pe$etiqueta <- sprintf("%s   (%.1f %%)", format(pe$n, big.mark = ","), pe$pct)


# --- Verificación opcional contra la API ------------------------------------
verificar_api <- function() {
  message("  consultando rest.uniprot.org ...")
  leer_total <- function(q) {
    con <- url(paste0("https://rest.uniprot.org/uniprotkb/search?query=", q,
                      "&size=0"), open = "rb")
    on.exit(close(con), add = TRUE)
    cab <- curlGetHeaders(paste0("https://rest.uniprot.org/uniprotkb/search?query=",
                                 q, "&size=0"))
    tot <- grep("^[Xx]-[Tt]otal-[Rr]esults:", cab, value = TRUE)
    rel <- grep("^[Xx]-[Uu]ni[Pp]rot-[Rr]elease:", cab, value = TRUE)
    list(n = as.integer(trimws(sub("^[^:]+:", "", tot[1]))),
         release = trimws(sub("^[^:]+:", "", rel[1])))
  }
  vivo <- vapply(1:5, function(k) leer_total(
    sprintf("reviewed:true+AND+existence:%d", k))$n, integer(1))
  rel <- leer_total("reviewed:true")$release

  cmp <- data.frame(codigo = pe$codigo, en_script = pe$n, en_api = vivo,
                    igual = pe$n == vivo)
  print(cmp, row.names = FALSE)
  message(sprintf("  release en el script: %s   release vivo: %s",
                  RELEASE, rel))
  if (!all(cmp$igual) || !identical(rel, RELEASE)) {
    message("")
    message("  *** CAMBIARON. Actualiza RELEASE, SWISSPROT_TOTAL y pe$n,")
    message("      y de paso las cifras de contenido/04-bases-datos/uniprot.qmd.")
  } else {
    message("  todo coincide.")
  }
  invisible(cmp)
}


# --- Geometría ---------------------------------------------------------------
TAM_ETIQ_BARRA <- 2.6

# Aire de la derecha, dimensionado con la etiqueta más larga (la del PE3, que
# es la barra que llega al final del eje).
#
# OJO CON LA ARITMÉTICA, que ya falló una vez: expansion(mult = e) NO es una
# fracción del panel, es una fracción del RANGO DE DATOS. Con el rango [0, max]
# y expansión e, la barra más larga termina en 1/(1+e) del ancho del panel, así
# que el hueco que queda a su derecha es (e/(1+e)) x ANCHO_PANEL_MM. Para que
# quepa una etiqueta de L mm hace falta
#
#     e >= L / (ANCHO_PANEL_MM - L)
#
# La primera versión dividía L entre el ancho del panel y daba 0.22, que es
# justo lo que se veía cortado: "385,493  (67.0 %" sin el paréntesis final.
#
# ANCHO_PANEL_MM es el ancho ÚTIL: los 160 mm de la figura menos los rótulos
# del eje y, que son largos ("PE2 evidencia a nivel de transcrito"), y menos
# los márgenes. Medido sobre el PNG de prueba: ~106 mm.
ANCHO_PANEL_MM <- 106
.mm_etiqueta <- max(nchar(pe$etiqueta)) * TAM_ETIQ_BARRA * AVANCE_SANS
AIRE_DERECHA <- 1.25 * .mm_etiqueta / (ANCHO_PANEL_MM - .mm_etiqueta)

TXT_FUENTE <- sprintf(paste("Swiss-Prot, release %s (%s). Las cifras cambian en",
                            "cada release: %s entradas revisadas en total."),
                      RELEASE, RELEASE_FECHA, format(SWISSPROT_TOTAL, big.mark = ","))

construir <- function() {
  ggplot(pe, aes(x = n, y = nivel)) +
    geom_col(fill = pe$color[order(match(pe$nivel, levels(pe$nivel)))][
               rank(match(pe$nivel, levels(pe$nivel)))],
             width = 0.62) +
    geom_text(aes(label = etiqueta), hjust = -0.06,
              family = familia_base(), size = TAM_ETIQ_BARRA, colour = TEXTO) +
    # Aire a la derecha para la etiqueta de la barra más larga. Se calcula a
    # partir del texto en vez de teclear un porcentaje: con 0.22 fijo, la
    # etiqueta del PE3 se salía del panel y se cortaba en "(67.0 %". El ancho
    # de la etiqueta en unidades del eje = caracteres x avance x (tam / mm por
    # unidad), aproximado con el mismo AVANCE_SANS que usan los stopifnot.
    scale_x_continuous(labels = fmt_conteo,
                       expand = expansion(mult = c(0, AIRE_DERECHA))) +
    labs(x = NULL, y = NULL, caption = TXT_FUENTE) +
    tema_libro(base_size = 10) +
    theme(panel.grid.major.y = element_blank(),
          axis.line.y = element_blank(),
          axis.ticks.y = element_blank())
}


if (!interactive()) {
  if ("--verificar" %in% commandArgs(trailingOnly = TRUE)) {
    verificar_api()
  }

  pe3 <- pe$pct[pe$codigo == "PE3"]
  pe1 <- pe$pct[pe$codigo == "PE1"]

  stopifnot(
    # --- La comprobación que importa: los cinco suman el total del release.
    #     Si alguien actualiza cuatro y olvida uno, truena acá. ---
    sum(pe$n) == SWISSPROT_TOTAL,

    nrow(pe) == 5L,
    all(pe$n > 0),
    !anyDuplicated(pe$codigo),
    isTRUE(all.equal(sum(pe$pct), 100)),

    # --- Lo que el capítulo afirma en prosa, comprobado contra los datos.
    #     uniprot.qmd dice "El 67 % es PE3" y "apenas el 21 % tiene evidencia
    #     experimental a nivel de proteína". Si los datos dejan de sostenerlo,
    #     la figura y el texto se contradirían en silencio. ---
    round(pe3) == 67,
    round(pe1) == 21,
    pe$n[pe$codigo == "PE3"] == max(pe$n),   # PE3 es la barra más larga
    sum(pe$destaca) == 1L,

    # --- La etiqueta de la barra larga cabe en el hueco que deja la expansión.
    #     Ver la deducción arriba; sin esto se corta y no se nota hasta que
    #     alguien mira la figura impresa. ---
    (AIRE_DERECHA / (1 + AIRE_DERECHA)) * ANCHO_PANEL_MM > .mm_etiqueta,
    AIRE_DERECHA > 0, AIRE_DERECHA < 1
  )

  message(sprintf("  Swiss-Prot %s: %s entradas revisadas",
                  RELEASE, format(SWISSPROT_TOTAL, big.mark = ",")))
  for (k in seq_len(nrow(pe))) {
    message(sprintf("    %s  %9s  %5.1f %%%s", pe$codigo[k],
                    format(pe$n[k], big.mark = ","), pe$pct[k],
                    ifelse(pe$destaca[k], "   <- el punto de la figura", "")))
  }
  message(sprintf("  suma = %s  (== total del release, comprobado)",
                  format(sum(pe$n), big.mark = ",")))

  escribir_tsv(pe[, c("codigo", "nivel", "n", "pct")], "niveles-pe")
  guardar(construir(), "niveles-pe", 16, 8)
}
