// This file contains your Data Connector logic
section SeekingAlpha;

[DataSource.Kind="SeekingAlpha", Publish="SeekingAlpha.Publish"]
shared SeekingAlpha.Contents = Value.ReplaceType(SeekingAlphaImpl, SeekingAlphaInputs);


SeekingAlphaInputs = type function(
   time as (type text meta [
        Documentation.FieldCaption = "Time Range",
        Documentation.FieldDescription = "The Time Range of Data You Want To Query",
        Documentation.AllowedValues = {
            //For drop down options
            "1D", "5D", "1M", "6M", "YTD", "1Y", "5Y", "10Y", "MAX"
        }
    ])
    )
    as any meta [
    Documentation.Name = "Seeking Alpha Name",
    Documentation.LongDescription = "Seeking Alpha Description"
];

SeekingAlphaImpl = (time as text) =>
    let
        Credentials = Extension.CurrentCredential(),
        Cookie = 
            ""
            & "user_id=" & Credentials[Username] & "; "
            & "user_remember_token=" & Credentials[Password],
        

        Utils = Expression.Evaluate(Text.FromBinary(Extension.Contents("Utils.pqm")), #shared),

        Generic.Fetch = Utils[Generic.Fetch],
        Portfolio.Fetch = Utils[Portfolio.Fetch],
        Stock.FetchChart = Utils[Stock.FetchChart],
        Table.ToNavigationTable = Utils[Table.ToNavigationTable],

        Portfolios = Portfolio.Fetch([Cookie=Cookie]),

        stubs = 
        let
            stubables = List.Accumulate(
                            Portfolios,
                            {},
                            (state, current) => if current[type] <> "ticker" then state else List.Combine({state, {current}})
                        ),
            stubs = List.Transform(stubables, (stubable) => stubable[attributes][slug]),
            stubData = List.Transform(stubs, (stub) => Stock.FetchChart(stub, time))
        in
            stubData,

        stubTables = List.Transform(
                        stubs,
                        (stub) =>
                        let
                            stubName = stub[id],
                            timeData = stub[attributes],
                            rows = List.Transform(
                                        Record.FieldNames(timeData),
                                        (date) =>
                                        let
                                            values = Record.Field(timeData, date)
                                        in
                                            {DateTime.From(date), values[close], values[high], values[low], values[volume], values[open]}
                                   ),


                            stubTable = Table.FromRows(rows, type table [date = datetime, close = number, high = number, low = number, volume = number, open = number])
                        in
                            {stubName, stubName, stubTable, "Table", "Table", true}
                    )

    in
        Table.ToNavigationTable({{"Stubs", "Stubs", Table.ToNavigationTable(stubTables), "Table", "Table", false}});

// Data Source Kind description
SeekingAlpha = [
    Authentication = [
        UsernamePassword = [
            UsernameLabel = "user_id",
            PasswordLabel = "user_remember_token",
            Label = "Seeking Alpha API Auth"
        ]
    ],
    Label = Extension.LoadString("DataSourceLabel")
];

// Data Source UI publishing description
SeekingAlpha.Publish = [
    Beta = true,
    Category = "Other",
    ButtonText = { Extension.LoadString("ButtonTitle"), Extension.LoadString("ButtonHelp") },
    LearnMoreUrl = "https://powerbi.microsoft.com/",
    SourceImage = SeekingAlpha.Icons,
    SourceTypeImage = SeekingAlpha.Icons
];

SeekingAlpha.Icons = [
    Icon16 = { Extension.Contents("SeekingAlpha16.png"), Extension.Contents("SeekingAlpha20.png"), Extension.Contents("SeekingAlpha24.png"), Extension.Contents("SeekingAlpha32.png") },
    Icon32 = { Extension.Contents("SeekingAlpha32.png"), Extension.Contents("SeekingAlpha40.png"), Extension.Contents("SeekingAlpha48.png"), Extension.Contents("SeekingAlpha64.png") }
];
