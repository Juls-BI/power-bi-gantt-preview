// Calendar table covering the full years of the Schedule dataset.
// Home > New Source > Blank Query > Advanced Editor, paste this and name the query "Calendar".
let
    Gantt     = Schedule,
    MinDate   = Date.From(List.Min(Gantt[StartDate])),
    MaxDate   = Date.From(List.Max(Gantt[EndDate])),

    StartDate = Date.StartOfYear(MinDate),
    EndDate   = Date.EndOfYear(MaxDate),

    Dates     = List.Dates(StartDate, Duration.Days(EndDate - StartDate) + 1, #duration(1, 0, 0, 0)),
    Base      = Table.FromList(Dates, Splitter.SplitByNothing(), type table [Date = date]),

    AddYear         = Table.AddColumn(Base, "Year", each Date.Year([Date]), Int64.Type),
    AddQuarter      = Table.AddColumn(AddYear, "Quarter", each "Q" & Text.From(Date.QuarterOfYear([Date])), type text),
    AddMonthNum     = Table.AddColumn(AddQuarter, "MonthNumber", each Date.Month([Date]), Int64.Type),
    AddMonthName    = Table.AddColumn(AddMonthNum, "MonthName", each Date.ToText([Date], "MMM", "en-GB"), type text),
    AddMonthYear    = Table.AddColumn(AddMonthName, "MonthYear", each Date.ToText([Date], "MMM yyyy", "en-GB"), type text),
    AddMonthYearKey = Table.AddColumn(AddMonthYear, "MonthYearSort", each Date.Year([Date]) * 100 + Date.Month([Date]), Int64.Type),

    // ISO week: the week belongs to the year that contains its Thursday
    AddISOWeek      = Table.AddColumn(AddMonthYearKey, "ISOWeek", each
                        let thu = Date.AddDays([Date], 3 - Date.DayOfWeek([Date], Day.Monday))
                        in  Number.RoundDown((Date.DayOfYear(thu) - 1) / 7) + 1, Int64.Type),
    AddWeekStart    = Table.AddColumn(AddISOWeek, "WeekStart", each Date.StartOfWeek([Date], Day.Monday), type date),

    AddDayOfWeek    = Table.AddColumn(AddWeekStart, "DayOfWeek", each Date.DayOfWeek([Date], Day.Monday) + 1, Int64.Type),
    AddDayName      = Table.AddColumn(AddDayOfWeek, "DayName", each Date.ToText([Date], "ddd", "en-GB"), type text),
    AddIsWorkingDay = Table.AddColumn(AddDayName, "IsWorkingDay", each Date.DayOfWeek([Date], Day.Monday) < 5, type logical),
    AddIsToday      = Table.AddColumn(AddIsWorkingDay, "IsToday", each [Date] = Date.From(DateTime.LocalNow()), type logical)
in
    AddIsToday
