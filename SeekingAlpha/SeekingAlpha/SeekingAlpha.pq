// This file contains your Data Connector logic
section SeekingAlpha;

[DataSource.Kind="SeekingAlpha", Publish="SeekingAlpha.Publish"]
shared SeekingAlpha.Contents = Value.ReplaceType(SeekingAlphaImpl, SeekingAlphaInputs);


SeekingAlphaInputs = type function() as any meta [
    Documentation.Name = "Seeking Alpha Name",
    Documentation.LongDescription = "Seeking Alpha Description"
];

SeekingAlphaImpl = () =>
    let
        Credentials = Extension.CurrentCredential(),
        Cookie = 
            ""
            & "user_id=" & Credentials[Username] & "; "
            & "user_remember_token=" & Credentials[Password],
        

        Utils = Expression.Evaluate(Text.FromBinary(Extension.Contents("Utils.pqm")), #shared),

        Generic.Fetch = Utils[Generic.Fetch],
        Portfolio.Fetch = Utils[Portfolio.Fetch],

        Portfolios = Portfolio.Fetch([Cookie=Cookie])
    in
        Portfolios;

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
