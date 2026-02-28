let
    // ===== CONFIGURAÇÕES =====
    BaseUrl = "https://seu-dominio.atlassian.net/rest/agile/1.0/board/id-seu-board/issue",
    PageSize = 1000,

    // ===== PRIMEIRA CHAMADA (PARA PEGAR O TOTAL) =====
    FirstResponse =
        Json.Document(
            Web.Contents(
                BaseUrl,
                [
                    Query = [
                        jql = "created >= -500d ORDER BY created ASC",
                        maxResults = Text.From(PageSize),
                        startAt = "0",
                        expand = "changelog",
                        fields = "created"
                    ]
                ]
            )
        ),

    Total = FirstResponse[total],

    // ===== FUNÇÃO PARA BUSCAR PÁGINAS =====
    GetPage = (StartAt as number) as list =>
        let
            Response =
                Json.Document(
                    Web.Contents(
                        BaseUrl,
                        [
                            Query = [
                                jql = "created >= -500d ORDER BY created ASC",
                                maxResults = Text.From(PageSize),
                                startAt = Text.From(StartAt),
                                expand = "changelog",
                                fields = "created"
                            ]
                        ]
                    )
                ),
            Issues = Response[issues]
        in
            Issues,

    // ===== PAGINAÇÃO CONTROLADA PELO TOTAL =====
    Pages =
        List.Generate(
            () => [StartAt = 0, Page = GetPage(0)],
            each [StartAt] < Total,
            each
                [
                    StartAt = [StartAt] + PageSize,
                    Page = GetPage([StartAt])
                ],
            each [Page]
        ),

    // ===== COMBINA TODAS AS PÁGINAS =====
    AllIssues = List.Combine(Pages),
    IssuesTable = Table.FromRecords(AllIssues),

    // ===== ISSUE KEY =====
    RenameKey =
        Table.RenameColumns(
            IssuesTable,
            {{"key", "IssueKey"}}
        ),

    // ===== CHANGELOG =====
    ExpandChangelog =
        Table.ExpandRecordColumn(
            RenameKey,
            "changelog",
            {"histories"},
            {"Histories"}
        ),

    ExpandHistories =
        Table.ExpandListColumn(
            ExpandChangelog,
            "Histories"
        ),

    ExpandHistoryFields =
        Table.ExpandRecordColumn(
            ExpandHistories,
            "Histories",
            {"created", "items"},
            {"ChangeDate", "Items"}
        ),

    ExpandItems =
        Table.ExpandListColumn(
            ExpandHistoryFields,
            "Items"
        ),

    // ===== FILTRO: STATUS =====
    FilterRelevantItems =
        Table.SelectRows(
            ExpandItems,
            each [Items][field] = "status"
              
        ),

    ExpandItemDetails =
        Table.ExpandRecordColumn(
            FilterRelevantItems,
            "Items",
            {"field", "fromString", "toString"},
            {"Field", "FromValue", "ToValue"}
        ),

    // ===== CONVERSÃO DE DATA =====
    ChangeDateType =
        Table.TransformColumns(
            ExpandItemDetails,
            {
                {
                    "ChangeDate",
                    each DateTimeZone.FromText(_),
                    type datetimezone
                }
            }
        ),

    // ===== COLUNAS FINAIS =====
    FinalColumns =
        Table.SelectColumns(
            ChangeDateType,
            {
                "IssueKey",
                "ChangeDate",
                "Field",
                "FromValue",
                "ToValue"
            }
        ),

    LinesFiltered = Table.SelectRows(FinalColumns, each true)

in
    LinesFiltered