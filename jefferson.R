library(dplyr)
library(stringr)


#### import do dataset
dados <- get(load(url("https://raw.githubusercontent.com/eogasawara/datamining/main/data-work/bfd_2019.rdata")))

#### dados inicias
dim(dados)
names(dados)


#### dados e descrições

"""
arrival - ICAO code of the destination airport of the flight;
depart - ICAO code of the flight origin airport;
route - flight route from arrival airport to destination airport
company - ICAO acronym of the airline. Ex: GLO, TAM, ONE;
flight - ANAC flight identifier;
di - Authorization code
type - (N) National, (I) International, (R) Regional, (H) Sub-regional, (E) Special, (C) Freight / Cargo, (G) International Freight / Cargo and (L) Postal Network;
expected_depart - Expected flight departure date in YYYYMMDD format where YYYY = year, MM = month and DD = day and HH = full hour;
real_depart - Flight departure date in YYYYMMDD HH format where YYYY = year, MM = month and DD = day and HH = full hour;
expected_arrival - Estimated date and time of flight arrival in YYYYMMDD format where YYYY = year, MM = month and DD = day and HH = full hour;
real_arrival - Flight arrival date in YYYYMMDD format where YYYY = year, MM = month and DD = day and HH = full hour;
status - Flight status (EX: realizado, cancelado);
observation - justification for canceled flight
delay_depart - Difference in minutes between expected and real departure datetime;
delay_arrival - Difference in minutes between expected and real arrival datetime;
expected_flight_length - Difference in minutes between expected departure and arrival datetime;
real_flight_length - Difference in minutes between real departure and arrival datetime;
outlier_depart_delay - Whether the departure delay for the flight is considered an outlier
outlier_arrival_delay - Whether the arrival delay for a particular flight is considered an outlier
outlier_expected_flight_consistency - Whether the expected flight consistency is considered an outlier
outlier_real_flight_consistency - Whether the real flight consistency is considered an outlier
outlier_expected_flight_length - Whether the expected flight length is considered an outlier
outlier_real_flight_length - Whether the real flight length is considered an outlier
depart_lon - longitude coordinates of the departure location
depart_lat - latitude coordinates of the departure location
depart_elevation - elevation or altitude of the departure airport above sea level
depart_air_temperature - Temperature of the air in degrees Celsius at the airport of origin, at the time of flight departure;
depart_dew_point - Dew point, in degrees Celsius at the airport of origin, at the time of flight departure;
depart_relative_humidity - Percentage of relative humidity in the airport of origin;
depart_wind_direction - Wind direction, based on Wind Rose, at the airport of origin;
depart_wind_speed - Wind speed, in knots, at the airport of origin; 32 . depart_sky_coverage - Amount of the sky covered by clouds at the departure location. Ex: FEW (Few clouds), SCT (Scattered clouds), BKN (Broken clouds)
depart_pressure - Atmospheric pressure, in mbar, at the airport of origin;
depart_visibility - Visibility, in miles, at the airport of origin;
depart_apparent_temperature - Temperature in degrees Celsius at the airport of origin, at the time of flight departure;
depart_wind_speed_scale - describes the wind speed at the departure location using the Beaufort wind scale
depart_wind_direction_cat - wind direction at the departure location using standard compass directions
depart_day_period - period of the day of the departure
arrival_lon - longitude coordinates of the arrival location
arrival_lat - latitude coordinates of the arrival location
arrival_elevation - elevation or altitude of the arrival airport above sea level
arrival_air_temperature - Temperature of the air in degrees Celsius at the destination airport, at the time of flight arrival;
arrival_dew_point - Dew point, in degrees Celsius at the destination airport, at the time of flight arrival.
arrival_relative_humidity - Percentage of relative humidity in the destination airport;
arrival_wind_direction - Wind direction, based on Wind Rose, at the airport of destination;
arrival_wind_speed - Wind speed in knots at the destination airport; 47 . arrival_sky_cover - Amount of the sky covered by clouds at the arrival location. Ex: FEW (Few clouds), SCT (Scattered clouds), BKN (Broken clouds)
arrival_pressure - Atmospheric pressure, in mbar, at the destination airport;
arrival_visibility - Visibility, in miles, at the destination airport;
arrival_apparent_temperature - Apparent temperature in degrees Celsius at the destination airport, at the time of flight arrival;
arrival_wind_speed_scale - wind speed at the arrival location using the Beaufort wind scale
arrival_wind_direction_cat - wind direction at the arrival location using standard compass directions
arrival_day_period - period of the day of the arrival
"""



#### dados sobre atrasos
summary(dados$delay_depart)
#        Min.    1st Qu.     Median       Mean    3rd Qu.       Max.       NA's 
# -525615.00      -5.00       0.00      -3.54       4.00  132895.00      18135 

summary(dados$delay_arrival)

#### media de atrasos por companhia
aggregate(delay_arrival ~ company, data = dados, FUN = mean, na.rm = TRUE)


#### distribuição de atraso em voos
hist(dados$delay_arrival, breaks = 50, main = "Atraso na chegada", xlab = "Minutos")

#### voos com maiores atrasos
dados[order(-dados$delay_arrival), ][1:10, c("flight", "company", "delay_arrival", "real_arrival")]

#### analise do clima nos atrasos
boxplot(delay_depart ~ depart_sky_coverage, data = dados, main = "Atraso por cobertura do céu")

#### atrasos ao longo do dia
boxplot(delay_depart ~ depart_day_period, data = dados, main = "Atraso por período do dia")

#### verificar o motivo do atraso
top_motivo_atrasos <-  dados %>% filter(delay_arrival > 0) %>% count(type, observation, sort = TRUE)

obs_mais_comuns <-dados %>%
  filter(!is.na(observation)) %>%
  count(observation, sort = TRUE) 

obs_labels <- data.frame(
  code = c("N", "I", "G"),
  descricao = c("Normal", "Infraestrutura", "Gestão")
)


dados <- dados %>%
  mutate(obs_categoria = case_when(
    str_detect(observation, regex("LIBERAÇÃO|PLANO DE VOO|ANTECIPAÇÃO|AUTORIZAD[AO]", ignore_case = TRUE)) ~ "Tráfego aéreo / Autorização",
    str_detect(observation, regex("DEFEITO|TROCA DE AERONAVE|AVARIA|PANE|DEGELO", ignore_case = TRUE)) ~ "Problema na aeronave",
    str_detect(observation, regex("CONEXÃO AERONAVE|VOO DE IDA", ignore_case = TRUE)) ~ "Conexão",
    str_detect(observation, regex("METEOROLÓGICAS|ABAIXO LIMITES|GELO|NEVE|LAMA", ignore_case = TRUE)) ~ "Clima",
    str_detect(observation, regex("AEROPORTO .*INTERDITADO|RESTRIÇÃO|FACILIDADES|DESTINO INTERDITADO|ALTERNATIVA", ignore_case = TRUE)) ~ "Infraestrutura Aeroportuária",
    str_detect(observation, regex("EQUIPO|ABASTECIMENTO|DESTANQUEIO|OPERAÇÕES EM SOLO", ignore_case = TRUE)) ~ "Falha de equipamentos/apoio",
    str_detect(observation, regex("SEGURANÇA|PAX|CARGA|ALFÂNDEGA|MIGRAÇÃO", ignore_case = TRUE)) ~ "Segurança / Passageiros / Alfândega",
    str_detect(observation, regex("^CANCELAMENTO", ignore_case = TRUE)) ~ "Cancelamento técnico ou climático",
    str_detect(observation, regex("FERIADO|VOO ESPECIAL|INCLUSÃO DE ETAPA", ignore_case = TRUE)) ~ "Outros específicos",
    str_detect(observation, regex("ATRASOS NÃO ESPECÍFICOS", ignore_case = TRUE)) ~ "Outros não específicos",
    TRUE ~ "Outros não específicos"
  ))

atrasos_por_categoria <- dados %>%
  group_by(obs_categoria) %>%
  summarise(
    media_atraso_depart = mean(delay_depart, na.rm = TRUE),
    total_voos = n()
  ) %>%
  arrange(desc(media_atraso_depart))

print(atrasos_por_categoria)

"""Maiores Causas de Atraso Positivo (Atrasos Reais):
Problema na aeronave (Média: 55.7 min, 26.026 voos): Esta categoria tem a maior média de atraso positivo. Isso indica que, quando um voo atrasa devido a problemas na aeronave, o atraso tende a ser significativamente longo. É um fator crítico que merece atenção.
Conexão (Média: 45.8 min, 27.070 voos): A segunda maior média de atraso. Atrasos causados por problemas de conexão (talvez aeronave ou tripulação vindo de um voo anterior atrasado) também resultam em atrasos consideráveis na partida.
Infraestrutura Aeroportuária (Média: 28.3 min, 7.248 voos) e 'Clima' (Média: 27.8 min, 8.352 voos): Essas categorias também contribuem com atrasos médios significativos. Problemas no aeroporto (restrições, interdições) e condições climáticas adversas são fatores externos importantes.
Falha de equipamentos/apoio (Média: 19.4 min, 17.889 voos): Atrasos relacionados a equipamentos de solo ou abastecimento, embora menores que os anteriores, ainda representam uma causa de atraso.
Categorias com Médias de Atraso Negativas (Antecipação ou Partida Adiantada):
Outros não específicos (Média: -6.67 min, 725.134 voos): Esta é a categoria com o maior volume de voos e uma média de atraso negativa. Isso sugere que a maioria dos voos que se encaixam nesta categoria (onde a causa do atraso não foi especificamente identificada por suas regras) na verdade partiu adiantada em média em 6.67 minutos. Isso é um bom sinal de pontualidade na ausência de problemas específicos.
Tráfego aéreo / Autorização (Média: -9.44 min, 149.896 voos): Voos relacionados a liberação ou autorização de tráfego aéreo também tendem a partir adiantados, o que é um bom indicativo de eficiência no fluxo de controle de tráfego.
Segurança / Passageiros / Alfândega (Média: -46.1 min, 9.741 voos): Esta categoria mostra a maior média de 'adiantamento'. Isso pode ser um artefato dos dados ou indicar que voos com essas 'observações' (que podem ser mais sobre procedimentos do que atrasos em si) tendem a ter uma margem de tempo que resulta em partida antecipada, ou que os atrasos são superados e compensados por outros fatores.
Categoria com NaN (Not a Number):
Cancelamento técnico ou climático (Média: NaN, 93 voos): O valor NaN (Not a Number) para a média de atraso nesta categoria, com total_voos = 93, geralmente significa que todos os voos nesta categoria têm um delay_depart que é NA (Not Available) ou são todos voos cancelados (onde o conceito de atraso na partida pode não se aplicar ou é registrado como NA). O mean(..., na.rm = TRUE) só retorna NaN se todos os valores forem NAs na coluna delay_depart para esse grupo. Se são voos cancelados, é esperado que não haja um tempo de partida real e, consequentemente, um atraso de partida.

Interpretação Geral:
Sua categorização é muito eficaz para identificar as principais áreas de problema e as áreas de sucesso.
Os 'Problemas na aeronave' e 'Conexão' são os fatores mais impactantes quando ocorre um atraso. Investigações adicionais nessas áreas poderiam focar em:
Manutenção: Existe algum padrão nos problemas de aeronave (tipo de aeronave, idade, histórico de manutenção)?
Logística de Conexão: Há gargalos específicos ou itinerários que causam mais problemas de conexão?
As categorias com médias negativas (Outros não específicos, Tráfego aéreo / Autorização, Segurança / Passageiros / Alfândega) sugerem que a operação é eficiente e que, para a maioria dos voos, não há problemas que causem atrasos, e até há 'recuperação' de tempo.
A categoria 'Cancelamento técnico ou climático' com NaN reitera a ideia de que cancelamentos são uma 'não-partida' e não um 'atraso na partida'.
"""
dados <- dados %>%
  mutate(route_identifier = paste0(depart, "-", arrival))

motivos_por_rota <- dados %>%
  group_by(route_identifier, obs_categoria) %>% # Agrupa por rota E categoria de observação
  summarise(
    contagem_atrasos = n(),
    media_atraso_depart = mean(delay_depart, na.rm = TRUE) # Adicionalmente, a média de atraso para essa combinação
  ) %>%
  ungroup() %>% # Desagrupa para poder ordenar globalmente
  arrange(desc(contagem_atrasos))


#### frequencia de voos por status
table(dados$status_arrival)

aggregate(depart_air_temperature ~ status_arrival, data=dados, FUN=mean, na.rm=TRUE)
aggregate(depart_wind_speed ~ status_arrival, data=dados, FUN=mean, na.rm=TRUE)

top10_atrasos <- dados[order(-dados$delay_arrival), ][1:10, ]

top10_atrasos

#### cerifica as condições climaticas nos aeroportos de partida e chegada desses voos atrasados
top10_atrasos[, c("flight", "company", "delay_arrival", "depart_air_temperature", "depart_wind_speed", "depart_sky_coverage",
                  "arrival_air_temperature", "arrival_wind_speed", "arrival_sky_coverage")]

####
top10_atrasos[, c("outlier_depart_delay", "outlier_arrival_delay")]

#### grafico 
boxplot(dados$delay_arrival, main="Distribuição geral dos atrasos na chegada", ylab="Minutos de atraso")
points(top10_atrasos$delay_arrival, col="red", pch=19)

# Distribuição do atraso na partida
hist(dados$delay_depart, breaks=50, main="Histograma: Atraso na partida", xlab="Minutos de atraso")

# Boxplot atraso na partida por categoria de cobertura do céu
boxplot(delay_depart ~ depart_sky_coverage, data=dados,
        main="Atraso na partida por cobertura do céu",
        xlab="Cobertura do céu",
        ylab="Minutos de atraso")


# Calcular estatísticas de atraso na partida por companhia
atrasos_por_companhia_depart <- dados %>%
  group_by(company) %>%
  summarise(
    media_atraso_depart = mean(delay_depart, na.rm = TRUE),
    mediana_atraso_depart = median(delay_depart, na.rm = TRUE),
    total_voos = n(),
    atrasos_maior_que_0 = sum(delay_depart > 0, na.rm = TRUE),
    percentual_atrasos = (atrasos_maior_que_0 / total_voos) * 100
  ) %>%
  arrange(desc(media_atraso_depart)) # Ordenar pela média de atraso

print(atrasos_por_companhia_depart)

# Repetir para atraso na chegada (delay_arrival) se for relevante
atrasos_por_companhia_arrival <- dados %>%
  group_by(company) %>%
  summarise(
    media_atraso_arrival = mean(delay_arrival, na.rm = TRUE),
    mediana_atraso_arrival = median(delay_arrival, na.rm = TRUE),
    total_voos = n()
  ) %>%
  arrange(desc(media_atraso_arrival))

print(atrasos_por_companhia_arrival)

# Se você tiver muitas companhias, pode filtrar as top N ou as com mais voos
top_companies <- atrasos_por_companhia_depart %>%
  arrange(desc(total_voos)) %>%
  head(10) # Pegar as 10 companhias com mais voos

dados_top_companies <- dados %>%
  filter(company %in% top_companies$company)

boxplot(delay_depart ~ company, data = dados_top_companies,
        main = "Atraso na Partida por Companhia Aérea (Top 10 Voos)",
        xlab = "Companhia Aérea",
        ylab = "Minutos de Atraso",
        las = 2)

# Calcular estatísticas de atraso na partida por rota
atrasos_por_rota_depart <- dados %>%
  group_by(route) %>%
  summarise(
    media_atraso_depart = mean(delay_depart, na.rm = TRUE),
    mediana_atraso_depart = median(delay_depart, na.rm = TRUE),
    total_voos = n()
  ) %>%
  arrange(desc(media_atraso_depart))

# Pode ser interessante filtrar rotas com um número mínimo de voos para evitar outliers
atrasos_por_rota_depart_filtrado <- atrasos_por_rota_depart %>%
  filter(total_voos >= 50) # Exemplo: rotas com pelo menos 50 voos

print(head(atrasos_por_rota_depart_filtrado, 10)) # Top 10 rotas com mais atrasos

"""
Discrepância entre Média e Mediana: Esta é a observação mais crítica.
Para rotas como EHAM-ELLX, a média de atraso é altíssima (899 minutos, quase 15 horas!), mas a mediana é relativamente baixa (30.5 minutos). Isso sugere fortemente a presença de atrasos extremos (outliers) que puxam a média para cima.
Rotas como LFPO-SBKP, SBKP-LFPO, GOBD-LTBA, KIAH-SBGL, e SGES-SBKP têm médias de atraso também muito altas, mas suas medianas são 0. Isso é um forte indicativo de que a maioria dos voos nessas rotas não atrasa, mas um pequeno número de voos experimenta atrasos extremamente longos.
Em contraste, rotas como EBBR-EDDF (mediana 159) e EDDF-GVAC (mediana 31) mostram que um número mais significativo de voos está experimentando atrasos, não apenas alguns outliers isolados.

Identificação de Rotas Problemáticas:
EHAM-ELLX é claramente a rota mais crítica em termos de atrasos médios, embora o comportamento da mediana sugira que é devido a eventos isolados, mas muito severos.
As rotas com mediana 0 e alta média são interessantes para investigar os eventos específicos que causaram esses atrasos massivos.
As rotas com medianas mais altas (e.g., EBBR-EDDF) indicam problemas mais sistêmicos que afetam uma proporção maior de voos.

Potenciais Causas:
Outliers Extremos: A grande diferença entre média e mediana aponta para a necessidade de investigar os voos individuais que causaram esses atrasos de centenas ou milhares de minutos. Houve cancelamentos, desvios, falhas mecânicas graves, problemas climáticos extremos em dias específicos?
Infraestrutura Aeroportuária/Controle de Tráfego: Rotas com atrasos mais "consistentes" (mediana mais alta) podem estar ligadas a problemas de capacidade no aeroporto de origem/destino, gargalos no controle de tráfego aéreo, ou questões operacionais da companhia aérea para aquela rota específica.
Condições Climáticas: As variáveis que você já está explorando (temperatura, vento, cobertura do céu) podem ser cruciais para entender esses atrasos, especialmente se os outliers ocorreram em dias de condições climáticas adversas.
"""

# Investiga os voos da rota EHAM-ELLX com os maiores atrasos
dados %>%
  filter(route == "EHAM-ELLX") %>%
  arrange(desc(delay_depart)) %>%
  select(real_depart, delay_depart, depart_air_temperature, depart_wind_speed, depart_sky_coverage, status) %>%
  head(5)

### relação de atraso e temperatura
plot(dados$depart_air_temperature, dados$delay_depart,
     main="Atraso na partida x Temperatura no aeroporto",
     xlab="Temperatura (°C)",
     ylab="Minutos de atraso",
     pch=20, col=rgb(0,0,1,0.3))
abline(lm(delay_depart ~ depart_air_temperature, data=dados), col="red")

### relação de atraso e velocidade do vento
plot(dados$depart_wind_speed, dados$delay_depart,
     main="Atraso na partida x Velocidade do vento",
     xlab="Velocidade do vento (m/s)",
     ylab="Minutos de atraso",
     pch=20, col=rgb(0,0,1,0.3))
abline(lm(delay_depart ~ depart_wind_speed, data=dados), col="red")

### correlação clima e atrasos
vars <- dados[, c("delay_depart", "depart_air_temperature", "depart_wind_speed", "depart_pressure", "depart_relative_humidity")]

# Calcula matriz de correlação (ignorando NAs)
cor(vars, use="complete.obs")



