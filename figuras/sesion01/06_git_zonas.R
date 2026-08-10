## Fig. @fig-zonas (Sesión 01, práctica, § Las tres zonas)
## Las tres zonas de git y los comandos que mueven archivos entre ellas:
##
##     directorio de trabajo --git add--> staging --git commit--> repositorio
##
## Esquema puro: acá no hay nada que calcular de un archivo, a diferencia de las
## otras figuras de la carpeta. Lo que sí se deriva es la GEOMETRÍA: el ancho de
## cada caja, el hueco entre ellas y el largo de cada flecha salen del texto que
## llevan adentro, no de números acomodados a ojo. Si mañana cambia una etiqueta,
## la fila se reacomoda sola y los stopifnot del final avisan si algo se encima.
##
## Sin título dentro del SVG: el caption vive en el .qmd.
##
## Regenerar:  Rscript figuras/sesion01/06_git_zonas.R

# `_tema.R` vive junto a este script: se ubica el archivo para que
# `Rscript figuras/sesion01/06_git_zonas.R` corra desde la raíz del repo.
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


# --- Lo que afirma la figura ------------------------------------------------
# Único lugar donde se teclean los nombres y los comandos. De acá salen el
# dibujo y el .tsv, así que no pueden desincronizarse entre sí.
#
# Las glosas de las cajas van partidas a mano con "\n" y no con un envoltorio
# automático: son tres, se leen de un vistazo, y un wrap automático dependería
# del ancho que resuelva la fuente instalada en cada máquina (o sea, rompería el
# diff determinista que promete FIGURAS.md).
ZONAS <- data.frame(
  orden  = 1:3,
  nombre = c("Directorio de trabajo", "Staging area", "Repositorio (.git)"),
  glosa  = c("sus archivos\ncomo están ahora",
             "lo que va a entrar\nen la próxima foto",
             "el historial de fotos"),
  stringsAsFactors = FALSE
)

# La cuarta caja no es una zona de git: vive en otra máquina. Por eso va aparte,
# más chica y con borde punteado.
REMOTO <- "GitHub (remoto)"

# Las cinco flechas. `desde`/`hacia` indexan ZONAS$orden; el 4 es el remoto.
#
# Ojo con `git reset`: es la única de las cinco que la práctica NO ejercita (los
# ejercicios llegan hasta `git checkout --`). Está acá a propósito, porque el
# modelo de tres zonas se entiende mal si el staging parece una calle de un solo
# sentido. Si alguien "limpia" la figura para que cuadre con los ejercicios, esa
# es la razón por la que estaba.
MOVIMIENTOS <- data.frame(
  desde   = c(1L, 2L, 2L, 3L, 3L),
  hacia   = c(2L, 3L, 1L, 1L, 4L),
  comando = c("git add", "git commit", "git reset", "git checkout --", "git push"),
  sentido = c("avance", "avance", "regreso", "regreso", "avance"),
  glosa   = c("", "", "saca del staging", "restaura desde el último commit", ""),
  stringsAsFactors = FALSE
)

N_COMMITS <- 3L   # los círculos encadenados de la caja 3


# --- Geometría, en milímetros -----------------------------------------------
# Con `guardar(w = 16, h = 9)` y 2 mm de margen a cada lado, el panel mide
# 156 mm de ancho; de los 90 mm de alto, la nota de fuente se lleva 3.5 mm.
# Fijando las escalas a esos rangos, 1 unidad = 1 mm; y como el `size` de
# geom_text también está en mm, los anchos de texto se pueden comparar contra
# los huecos y comprobar que nada se encima. Mismo truco que 02_pipeline.R.
ANCHO_PANEL <- 156
ALTO_PANEL  <- 86.5

# Avance medio de un carácter, en fracción del em. Es una cota para los
# chequeos y para repartir el espacio, no una medida de la fuente real.
AVANCE_MONO <- 0.60
AVANCE_SANS <- 0.55

TAM_NOMBRE <- 2.8    # el nombre de cada zona, arriba de su caja
TAM_GLOSA  <- 2.2    # la glosa de adentro de la caja
TAM_CMD    <- 2.6    # los comandos: texto monoespaciado, es código
TAM_NOTA   <- 2.0    # las glosas de las flechas de regreso
TAM_REMOTO <- 2.5

# La fila de tres cajas no ocupa todo el panel: se deja aire a la derecha para
# que la caja del remoto quede ARRIBA Y A LA DERECHA de la del repositorio, que
# es lo que la figura tiene que decir (el push sale del repo hacia afuera).
X_INI_FILA <- 2
ANCHO_CAJA <- 33
HUECO      <- 22                      # entre cajas; tiene que caber `git commit`
Y_CAJA_MIN <- 26
Y_CAJA_MAX <- 54
Y_MEDIO    <- (Y_CAJA_MIN + Y_CAJA_MAX) / 2

Y_NOMBRE   <- 57.5                    # nombres, arriba de las cajas
RETIRO     <- 1.2                     # las flechas no tocan las cajas

# Caja del remoto.
REMOTO_X   <- c(124, 156)
REMOTO_Y   <- c(74, 86)

# Las dos flechas de regreso se rutean POR DEBAJO de las cajas (no por el hueco)
# porque `git checkout --` va de la 3 a la 1 y tendría que atravesar la 2.
# Quedan anidadas: la corta arriba, la larga abajo.
#
# Las dos van bien separadas entre sí a propósito: con las líneas juntas, la
# etiqueta de la de arriba queda a media distancia de las dos y no se sabe a
# cuál pertenece. Cada etiqueta tiene que estar más cerca de su propia línea que
# de la otra, y eso es lo que comprueba el stopifnot del final.
Y_REGRESO  <- c(20.5, 8)              # reset, checkout
SEPARA_CMD <- 2.6                     # comando, debajo de su línea
SEPARA_GLO <- 5.4                     # glosa, debajo del comando

# Cadena de commits dentro de la caja 3.
Y_CADENA   <- 34
R_COMMIT   <- 2.3
PASO_COMMIT <- 8

MONO <- familia_mono()
SANS <- familia_base()


# --- Cajas ------------------------------------------------------------------
cajas <- transform(
  ZONAS,
  xmin = X_INI_FILA + (orden - 1) * (ANCHO_CAJA + HUECO),
  ymin = Y_CAJA_MIN,
  ymax = Y_CAJA_MAX
)
cajas$xmax <- cajas$xmin + ANCHO_CAJA
cajas$x    <- (cajas$xmin + cajas$xmax) / 2

# La glosa de la caja 3 sube para dejarle sitio a la cadena de commits; las
# otras dos van centradas. Es la única asimetría del dibujo y es deliberada: la
# caja 3 tiene más adentro porque es la que guarda algo.
cajas$y_glosa <- ifelse(cajas$orden == 3, 45, Y_MEDIO)

remoto <- data.frame(
  xmin = REMOTO_X[1], xmax = REMOTO_X[2],
  ymin = REMOTO_Y[1], ymax = REMOTO_Y[2],
  x = mean(REMOTO_X), y = mean(REMOTO_Y),
  etiqueta = REMOTO, stringsAsFactors = FALSE
)


# --- Flechas de avance (naranjas) entre cajas vecinas ------------------------
avances <- subset(MOVIMIENTOS, sentido == "avance" & hacia <= 3)
avances$x    <- cajas$xmax[avances$desde] + RETIRO
avances$xend <- cajas$xmin[avances$hacia] - RETIRO
avances$xm   <- (avances$x + avances$xend) / 2


# --- Flechas de regreso (grises), ruteadas por debajo ------------------------
# Cada una es una polilínea de cuatro puntos: baja de la caja de origen, corre
# en horizontal y sube a la caja 1. geom_path pone la punta al final del grupo,
# así que la flecha apunta hacia arriba, hacia el directorio de trabajo.
regresos <- subset(MOVIMIENTOS, sentido == "regreso")
regresos$y_linea <- Y_REGRESO
# Se sale y se entra por dentro de la caja, no por sus esquinas: dos flechas que
# aterrizan en la caja 1 tienen que llegar a puntos distintos de su borde.
regresos$x_sale  <- cajas$xmin[regresos$desde] + 8
regresos$x_llega <- cajas$xmin[regresos$hacia] + c(26, 10)
regresos$xm      <- (regresos$x_sale + regresos$x_llega) / 2

rutas <- do.call(rbind, lapply(seq_len(nrow(regresos)), function(i) {
  r <- regresos[i, ]
  data.frame(
    ruta = i,
    x    = c(r$x_sale,   r$x_sale,   r$x_llega, r$x_llega),
    y    = c(Y_CAJA_MIN, r$y_linea,  r$y_linea, Y_CAJA_MIN - RETIRO)
  )
}))


# --- La flecha del push -----------------------------------------------------
# Sale de la caja 3 por su borde superior, cerca de la esquina derecha, y sube
# hacia el remoto. Arranca a la derecha del nombre de la caja para no cruzarlo:
# el stopifnot del final comprueba justamente eso.
push <- data.frame(
  x    = cajas$xmax[3] - 1,
  y    = Y_CAJA_MAX + RETIRO,
  xend = remoto$xmin + 26,
  yend = remoto$ymin - RETIRO
)
push$comando <- MOVIMIENTOS$comando[MOVIMIENTOS$hacia == 4]
# La etiqueta va a la izquierda de la flecha, en el hueco entre el nombre de la
# caja 3 y el remoto. Alineada a la derecha, terminando en el borde de la caja.
push$x_lab <- cajas$xmax[3]
push$y_lab <- 66

# x de la flecha del push a una altura dada. Sirve para el chequeo de cruce.
x_push_en <- function(y) {
  push$x + (push$xend - push$x) * (y - push$y) / (push$yend - push$y)
}


# --- La cadena de commits de la caja 3 --------------------------------------
# Círculos dibujados como polígonos y no con geom_point: así el radio está en
# milímetros de verdad y los chequeos de abajo pueden compararlo contra el borde
# de la caja. Con `size` de geom_point habría que adivinar la conversión.
circulo <- function(x, y, r, id, n = 48) {
  ang <- seq(0, 2 * pi, length.out = n + 1)[-(n + 1)]
  data.frame(x = x + r * cos(ang), y = y + r * sin(ang), id = id)
}

x_commits <- cajas$x[3] + (seq_len(N_COMMITS) - (N_COMMITS + 1) / 2) * PASO_COMMIT
commits <- do.call(rbind, lapply(seq_len(N_COMMITS), function(i) {
  circulo(x_commits[i], Y_CADENA, R_COMMIT, id = i)
}))
# El último es el commit al que apunta la rama: va resaltado en naranja, que en
# este libro es el color de "el punto de la figura".
ULTIMO <- N_COMMITS


construir <- function() {
  ggplot() +
    # --- Cajas: azul, relleno transparente ---
    geom_rect(data = cajas,
              aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
              fill = NA, colour = AZUL, linewidth = 0.5) +
    # El remoto está en otra máquina: borde punteado.
    geom_rect(data = remoto,
              aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
              fill = NA, colour = AZUL, linewidth = 0.45, linetype = "dotted") +

    # --- La cadena de commits, dentro de la caja 3 ---
    geom_segment(data = data.frame(a = min(x_commits), b = max(x_commits)),
                 aes(x = a, xend = b, y = Y_CADENA, yend = Y_CADENA),
                 colour = GRIS, linewidth = 0.4) +
    geom_polygon(data = subset(commits, id != ULTIMO),
                 aes(x = x, y = y, group = id),
                 fill = alpha(AZUL, 0.15), colour = AZUL, linewidth = 0.4) +
    geom_polygon(data = subset(commits, id == ULTIMO),
                 aes(x = x, y = y, group = id),
                 fill = NARANJA, colour = NARANJA, linewidth = 0.4) +

    # --- Textos de las cajas ---
    geom_text(data = cajas, aes(x = x, y = Y_NOMBRE, label = nombre),
              family = SANS, size = TAM_NOMBRE, colour = AZUL) +
    geom_text(data = cajas, aes(x = x, y = y_glosa, label = glosa),
              family = SANS, size = TAM_GLOSA, colour = GRIS, lineheight = 1.05) +
    geom_text(data = remoto, aes(x = x, y = y, label = etiqueta),
              family = SANS, size = TAM_REMOTO, colour = GRIS) +

    # --- Avance: add y commit, gruesas y con la etiqueta en naranja ---
    # arrow.fill: sin él la punta cerrada sale hueca (ggplot no hereda el color
    # del trazo para el relleno del polígono).
    geom_segment(data = avances,
                 aes(x = x, xend = xend, y = Y_MEDIO, yend = Y_MEDIO),
                 colour = NARANJA, linewidth = 0.55, arrow.fill = NARANJA,
                 arrow = arrow(length = unit(2, "mm"), type = "closed")) +
    geom_text(data = avances, aes(x = xm, y = Y_MEDIO + SEPARA_CMD, label = comando),
              family = MONO, size = TAM_CMD, colour = NARANJA) +

    # --- Regreso: más delgadas, grises, ruteadas por debajo ---
    geom_path(data = rutas, aes(x = x, y = y, group = ruta),
              colour = GRIS, linewidth = 0.3, lineend = "round",
              linejoin = "round",
              arrow = arrow(length = unit(1.6, "mm"), type = "open")) +
    geom_text(data = regresos,
              aes(x = xm, y = y_linea - SEPARA_CMD, label = comando),
              family = MONO, size = TAM_CMD, colour = GRIS) +
    geom_text(data = regresos,
              aes(x = xm, y = y_linea - SEPARA_GLO, label = glosa),
              family = SANS, size = TAM_NOTA, colour = GRIS) +

    # --- Push: fuera de la máquina ---
    geom_segment(data = push, aes(x = x, xend = xend, y = y, yend = yend),
                 colour = NARANJA, linewidth = 0.55, arrow.fill = NARANJA,
                 arrow = arrow(length = unit(2, "mm"), type = "closed")) +
    geom_text(data = push, aes(x = x_lab, y = y_lab, label = comando),
              family = MONO, size = TAM_CMD, colour = NARANJA, hjust = 1) +

    coord_cartesian(xlim = c(0, ANCHO_PANEL), ylim = c(0, ALTO_PANEL),
                    expand = FALSE, clip = "off") +
    labs(caption = paste("Esquema. El modelo de las tres zonas es el del capítulo 2 de Pro Git;",
                         "los comandos son los de esta práctica.")) +
    theme_void(base_size = 10, base_family = SANS) +
    theme(plot.caption = element_text(size = rel(0.73), colour = GRIS,
                                      face = "italic", hjust = 0,
                                      margin = margin(t = 3)),
          plot.caption.position = "plot",
          # El margen va acá y no en la escala, para que la nota de fuente
          # arranque exactamente donde arranca la primera caja.
          plot.margin = margin(0, 2, 0, 2, "mm"))
}


if (!interactive()) {
  # Medio ancho de cada texto, en mm, para los chequeos de encimado. nchar() se
  # mide sobre la línea más larga: las glosas van partidas con "\n".
  media <- function(txt, tam, avance) {
    largo <- vapply(strsplit(txt, "\n", fixed = TRUE),
                    function(p) max(nchar(p)), numeric(1))
    largo * tam * avance / 2
  }

  m_nombre <- media(cajas$nombre,       TAM_NOMBRE, AVANCE_SANS)
  m_glosa  <- media(cajas$glosa,        TAM_GLOSA,  AVANCE_SANS)
  m_avance <- media(avances$comando,    TAM_CMD,    AVANCE_MONO)
  m_regres <- media(regresos$comando,   TAM_CMD,    AVANCE_MONO)
  m_nota   <- media(regresos$glosa,     TAM_NOTA,   AVANCE_SANS)
  m_push   <- media(push$comando,       TAM_CMD,    AVANCE_MONO)

  # ¿La flecha del push libra el nombre de la caja 3, y la etiqueta libra la
  # flecha? Es el único cruce posible del dibujo, y el que más fácil se rompe si
  # alguien alarga "Repositorio (.git)". La etiqueta va con hjust = 1, o sea que
  # crece hacia la IZQUIERDA desde x_lab: lo que hay que medir es la distancia
  # de su borde derecho a la flecha.
  holgura_push_flecha <- x_push_en(Y_NOMBRE) - (cajas$x[3] + m_nombre[3])
  holgura_push_texto  <- x_push_en(push$y_lab) - push$x_lab

  # Las etiquetas de las flechas de regreso van sobre el tramo horizontal de su
  # ruta: tienen que caber entre las dos patas verticales.
  izq  <- pmin(regresos$x_sale, regresos$x_llega)
  der  <- pmax(regresos$x_sale, regresos$x_llega)
  ancho_lab_regreso <- pmax(m_regres, m_nota)

  stopifnot(
    # --- Lo que la figura afirma ---
    nrow(MOVIMIENTOS) == 5L,
    identical(MOVIMIENTOS$comando,
              c("git add", "git commit", "git reset", "git checkout --", "git push")),
    identical(sort(unique(MOVIMIENTOS$sentido)), c("avance", "regreso")),
    nrow(avances) == 2L, nrow(regresos) == 2L, nrow(push) == 1L,
    N_COMMITS == 3L, length(unique(commits$id)) == N_COMMITS,
    sum(unique(commits$id) == ULTIMO) == 1L,       # exactamente uno resaltado

    # --- Nada se sale del panel ---
    min(cajas$xmin) >= 0, max(remoto$xmax) <= ANCHO_PANEL,
    remoto$ymax <= ALTO_PANEL,
    min(cajas$x - m_nombre) >= 0,                  # los nombres tampoco
    max(cajas$x + m_nombre) <= ANCHO_PANEL,
    min(regresos$y_linea) - SEPARA_GLO - TAM_NOTA / 2 >= 0,

    # --- Nada se encima ---
    HUECO > 2 * RETIRO + 4,                        # queda flecha visible
    all(m_avance * 2 + 2 * RETIRO + 3 < HUECO),    # `git commit` cabe en el hueco
    all(m_nombre <= ANCHO_CAJA / 2),               # el nombre cabe sobre su caja
    all(m_glosa  <  ANCHO_CAJA / 2),               # la glosa cabe dentro
    max(regresos$y_linea) < Y_CAJA_MIN - 3,        # el ruteo pasa bajo las cajas
    # La etiqueta de la ruta de arriba queda más cerca de SU línea que de la de
    # abajo: si no, no se sabe a cuál de las dos flechas pertenece.
    SEPARA_GLO < (Y_REGRESO[1] - SEPARA_GLO) - Y_REGRESO[2],
    all(regresos$x_sale > max(regresos$x_llega)),  # el ruteo va de derecha a izq.
    all(regresos$xm - ancho_lab_regreso > izq + 1),   # las etiquetas caben
    all(regresos$xm + ancho_lab_regreso < der - 1),   #   entre las patas
    max(x_commits) + R_COMMIT < cajas$xmax[3],     # la cadena cabe en la caja 3
    min(x_commits) - R_COMMIT > cajas$xmin[3],
    Y_CADENA + R_COMMIT < cajas$y_glosa[3] - TAM_GLOSA,
    Y_CADENA - R_COMMIT > Y_CAJA_MIN,
    holgura_push_flecha > 1.5,                     # la flecha libra el nombre
    holgura_push_texto  > 1.5,                     # y la etiqueta libra la flecha
    push$x_lab - 2 * m_push > cajas$xmin[3]        # la etiqueta se lee sobre la caja 3
  )

  message(sprintf("  %d zonas + remoto, %d flechas (%d de avance, %d de regreso)",
                  nrow(cajas), nrow(MOVIMIENTOS),
                  sum(MOVIMIENTOS$sentido == "avance"),
                  sum(MOVIMIENTOS$sentido == "regreso")))
  message(sprintf("  cajas de %g x %g mm, hueco de %g mm; cadena de %d commits",
                  ANCHO_CAJA, Y_CAJA_MAX - Y_CAJA_MIN, HUECO, N_COMMITS))
  message(sprintf("  holgura del push: %.1f mm (flecha vs. nombre), %.1f mm (etiqueta vs. flecha)",
                  holgura_push_flecha, holgura_push_texto))
  message(sprintf("  familia monoespaciada: %s", MONO))

  # El .tsv de esta figura no lleva números medidos (no hay ninguno que medir):
  # lleva las cinco transiciones. Sirve para lo mismo que en las otras figuras
  # del grupo, que es cotejar la figura contra la prosa del capítulo, sólo que
  # acá lo que tiene que cuadrar son los comandos, no las cifras.
  etiqueta_zona <- c(ZONAS$nombre, REMOTO)
  escribir_tsv(
    data.frame(origen  = etiqueta_zona[MOVIMIENTOS$desde],
               destino = etiqueta_zona[MOVIMIENTOS$hacia],
               comando = MOVIMIENTOS$comando,
               sentido = MOVIMIENTOS$sentido,
               glosa   = MOVIMIENTOS$glosa,
               stringsAsFactors = FALSE),
    "git-tres-zonas")
  guardar(construir(), "git-tres-zonas", 16, 9)
}
