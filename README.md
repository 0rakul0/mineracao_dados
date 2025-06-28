
# 📊 Análise Exploratória de Dados — `bfd_2019.rdata`

Este projeto tem como objetivo realizar uma análise exploratória detalhada do dataset de voos **`bfd_2019.rdata`**, com foco na identificação de padrões, tendências e possíveis variáveis relacionadas a **atrasos de chegada**.

(link do dataset)[https://raw.githubusercontent.com/eogasawara/datamining/main/data-work/bfd_2019.rdata]

---

## 📌 Etapas da Análise

### 1. Entendimento Inicial
- Identificar número de linhas e colunas
- Compreender o significado das variáveis
- Verificar tipos de dados
- Analisar presença de NAs e valores únicos

### 2. Avaliação da Qualidade dos Dados
- Quantidade de NAs por coluna
- Valores inconsistentes ou fora do esperado
- Colunas com baixa variação ou valor constante

### 3. Análise Univariada
**Para variáveis numéricas**:
- Média, mediana, desvio padrão, mínimo, máximo, moda, skewness, curtose, quantis
- Gráficos: histograma, boxplot, curva de densidade

**Para variáveis categóricas**:
- Frequência de categorias
- Distribuição gráfica (gráfico de barras)

### 4. Análise Bivariada
- Correlação entre variáveis numéricas
- Comparações entre variáveis categóricas e o atraso
- Gráficos de dispersão (scatterplot), boxplot por categoria

### 5. Análise Multivariada
- **Correlação geral** entre variáveis
- **Parallel Coordinates Plot** para variáveis normalizadas (identificação de padrões de atraso)

### 6. Normalização
- Verificar necessidade de normalização/padronização de variáveis
- Avaliar transformações para variáveis assimétricas (ex: log)

---

## ❓ Perguntas-Chave a Responder
- Quais variáveis estão mais associadas ao atraso?
- Há companhias aéreas ou aeroportos mais propensos a atrasos?
- O horário ou dia da semana influencia nos atrasos?
- Atraso na decolagem é preditivo do atraso na chegada?
- Qual a distribuição geral dos atrasos?

---

## 👥 Divisão por Times

| Faixa de colunas | Responsável | Tarefas |
|------------------|-------------|---------|
| Colunas 1 a 16   | Jefferson   | Análise univariada + tratamento + gráficos |
| Colunas 17 a 31  | Aline       | Análise univariada + tratamento + gráficos |
| Colunas 32 a 48  | JP          | Análise univariada + tratamento + gráficos |

Cada integrante deve:
- Identificar tipo, NAs, valores únicos
- Fazer análise estatística descritiva
- Gerar gráficos básicos (boxplot, histograma, densidade)
- Sugerir transformações ou exclusões
- Destacar possíveis relações com atrasos

---

## 📍 Entregáveis esperados

- [ ] README atualizado com insights parciais por integrante
- [ ] Gráficos salvos ou script R de geração
- [ ] Lista de variáveis que requerem normalização
- [ ] Tabela de variáveis mais correlacionadas com o atraso
- [ ] Análise conjunta final (gráficos de correlação e parallel coordinates)

---

## 📂 Organização dos Arquivos

```
📁 projeto/
│
│
├── scripts/               # Scripts R de análise
│   ├── jefferson_eda.R
│   ├── aline_eda.R
│   └── jp_eda.R
│
├── plots/                 # Gráficos gerados por cada integrante
│
├── README.md              # Este roteiro
```

---

## 🔄 Próximos Passos

- [ ] Cada integrante realiza análise exploratória de sua faixa
- [ ] Unificar insights e preparar seção de análise conjunta
- [ ] Preparar visualizações finais para apresentação

---
