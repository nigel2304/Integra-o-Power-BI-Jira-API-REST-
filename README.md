# Integração Power BI + Jira (API REST)

Este repositório documenta o processo de integração do **Power BI** com o **Jira Cloud** utilizando a **API REST**, permitindo a extração de issues, histórico de status e a criação de métricas de fluxo como **Aging**, **Cycle Time** e **Lead Time**.

---

## Pré-requisitos

Antes de iniciar, é necessário:

- Conta ativa no Jira (Cloud)
- Acesso ao Power BI Desktop
- Permissão para gerar token de API no Jira
- Conhecimento básico de Power Query (M) e DAX

---

## 1. Gerar Token de API no Jira

1. Acesse:  
   https://id.atlassian.com/manage-profile/security/api-tokens
2. Clique em **Create API token**
3. Defina um nome (ex: `powerbi-jira`)
4. Copie o token gerado

> ⚠️ **Importante:** o token é exibido apenas uma vez. Armazene-o com segurança.

---

## 2. Estrutura de Autenticação

A API do Jira utiliza **Basic Authentication**:

- **Usuário:** e-mail da conta Jira  
- **Senha:** API Token  

Essas informações serão utilizadas no Power BI.

---

## 3. Conectando o Power BI à API do Jira

1. Abra o **Power BI Desktop**
2. Clique em **Obter Dados**
3. Selecione **Web**
4. Utilize o modo **Avançado**

### Exemplo de URL da API

https://seu-dominio.atlassian.net/rest/api/3/search

---

## 4. Parâmetros de Consulta (JQL)

No campo **Parâmetros de Consulta**, utilize algo semelhante a:

jql = project = "ABC"
maxResults = 100

O JQL pode ser ajustado conforme a necessidade, permitindo filtros por:

- Projeto
- Status
- Sprint
- Responsável
- Intervalo de datas

---

## 5. Autenticação no Power BI

Quando solicitado pelo Power BI:

- **Método:** Basic  
- **Usuário:** e-mail da conta Jira  
- **Senha:** API Token  

Após a autenticação, a conexão com a API será estabelecida.

---

## 6. Scripts M (Power Query)

Após a conexão com a API do Jira, são utilizados **scripts M (Power Query)** responsáveis por extrair, transformar e estruturar os dados.

Este repositório disponibiliza **dois scripts principais**.

---

### 6.1 QueryIssues

Script responsável por retornar **todas as issues criadas nos últimos 500 dias**, com os principais campos já expandidos e normalizados.

**Campos retornados:**

- `IssueKey`
- `Summary`
- `Created`
- `ResolutionDate`
- `Status`
- `Assignee`

Este script representa a **tabela principal de issues**, refletindo o estado atual de cada item.

---

### 6.2 QueryIssuesHistory

Script responsável por retornar **todo o histórico das issues dos últimos 500 dias**, filtrando **apenas registros que representam mudanças de status**.

**Campos retornados:**

- `IssueKey`
- `ChangeDate`
- `Field`
- `FromValue`
- `ToValue`

Este script é utilizado para análises de fluxo e cálculo de métricas como cycle time e lead time.

---

### 6.3 Observações sobre os Scripts M

- O intervalo de **500 dias** é apenas um valor padrão
- O período de datas pode ser alterado diretamente no script M
- Os campos retornados podem ser ajustados conforme a necessidade
- Cada projeto pode customizar os scripts conforme seu fluxo

---

### 6.4 Descrição dos Campos

#### QueryIssues

- **IssueKey:** código da issue  
- **Summary:** título da issue  
- **Created:** data de criação  
- **ResolutionDate:** data de conclusão  
- **Status:** status atual  
- **Assignee:** responsável  

#### QueryIssuesHistory

- **IssueKey:** código da issue  
- **ChangeDate:** data da alteração de status  
- **Field:** valor fixo indicando histórico de status  
- **FromValue:** status anterior  
- **ToValue:** novo status  

---

## 7. Medidas DAX

Após a carga dos dados via Power Query, são criadas **medidas DAX** responsáveis pelos principais indicadores de fluxo.

Medidas disponibilizadas neste repositório:

- **AgingIssue**  
  Calcula há quanto tempo a issue está aberta.

- **CycletimeIssue**  
  Calcula o tempo de execução da issue com base nas mudanças de status.

- **LeadtimeIssue**  
  Calcula o tempo total entre criação e resolução da issue.

As medidas utilizam como base as tabelas **QueryIssues** e **QueryIssuesHistory**.

---

## 8. Próximos Passos (Fora do Escopo)

Após estabelecer a conexão com o Jira e realizar a carga dos dados, os próximos passos normalmente envolvem:

- Tratamento adicional dos dados
- Criação de relacionamentos entre tabelas
- Ajustes no modelo semântico
- Construção de relatórios e dashboards

> ⚠️ **Observação:**  
> Esses passos variam conforme o processo e as necessidades de cada time, portanto **não estão descritos neste repositório**.

---

## Referências

- Jira REST API  
  https://developer.atlassian.com/cloud/jira/platform/rest/v3/

- Power BI – Conector Web  
  https://learn.microsoft.com/power-bi/connect-data/desktop-connect-to-web

