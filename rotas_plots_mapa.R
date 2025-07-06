# Instalar pacotes se necessário
# install.packages(c("shiny", "leaflet", "geosphere", "readr", "dplyr"))
library(shiny)
library(leaflet)
library(geosphere)
library(readr)
library(dplyr)

# Carregar base de aeroportos (1x no início)
aeroportos <- read_csv("https://ourairports.com/data/airports.csv", show_col_types = FALSE)

# Filtrar apenas com código ICAO (coluna `ident`)
aeroportos_icao <- aeroportos %>%
  select(ident, name, latitude_deg, longitude_deg)

# Função para mapear cor por tipo
get_cor_tipo <- function(tipo) {
  if (tipo == "I") return("red")
  if (tipo == "N") return("blue")
  return("gray")
}

ui <- fluidPage(
  titlePanel("Rotas de Aviões por Tipo"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput("tipo", "Selecione o tipo de rota:",
                  choices = NULL, selected = NULL),
      
      numericInput("atraso_minutos", "Diferença mínima em minutos:", 
                   value = 100, min = 0, step = 1),
      
      textOutput("atraso_valor")
    ),
    
    mainPanel(
      leafletOutput("mapa", height = 600)
    )
  )
)

server <- function(input, output, session) {
  
  rotas_geo <- reactive({
    req(exists("voos_atraso_chegada_grande"))
    
    rotas_df <- voos_atraso_chegada_grande %>%
      mutate(
        origem = sub("-.*", "", route),
        destino = sub(".*-", "", route)
      )
    
    rotas_geo <- rotas_df %>%
      left_join(aeroportos_icao, by = c("origem" = "ident")) %>%
      rename(lat_origem = latitude_deg, lon_origem = longitude_deg, nome_origem = name) %>%
      left_join(aeroportos_icao, by = c("destino" = "ident")) %>%
      rename(lat_destino = latitude_deg, lon_destino = longitude_deg, nome_destino = name) %>%
      mutate(diff = real_flight_length - expected_flight_length)
    
    rotas_geo
  })
  
  # Atualiza opções do selectInput tipo
  observe({
    tipos_unicos <- unique(rotas_geo()$type)
    updateSelectInput(session, "tipo", choices = tipos_unicos, selected = tipos_unicos[1])
  })
  
  max_diff <- reactive({
    max(rotas_geo()$diff, na.rm = TRUE)
  })
  
  output$atraso_valor <- renderText({
    paste0("Máximo atraso registrado: ", round(max_diff(), 1), " minutos")
  })
  
  output$mapa <- renderLeaflet({
    df <- rotas_geo() %>% 
      filter(type == input$tipo) %>%
      filter(diff > input$atraso_minutos)
    
    mapa <- leaflet() %>% addTiles()
    
    for (i in 1:nrow(df)) {
      origem <- c(df$lon_origem[i], df$lat_origem[i])
      destino <- c(df$lon_destino[i], df$lat_destino[i])
      
      if (any(is.na(origem)) || any(is.na(destino))) next
      
      cor_linha <- get_cor_tipo(df$type[i])
      rota <- gcIntermediate(origem, destino, n = 100, addStartEnd = TRUE, sp = TRUE)
      
      mapa <- mapa %>%
        addPolylines(data = rota, color = cor_linha, weight = 2)
    }
    
    mapa
  })
}

shinyApp(ui, server)