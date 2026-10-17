# Power BI Gantt Visual (Preview): Sample and Workarounds
![Power BI](https://img.shields.io/badge/Power%20BI-F2C811?style=flat&logo=powerbi&logoColor=black)
![DAX](https://img.shields.io/badge/DAX-measures-0078D4?style=flat)
![Gantt visual](https://img.shields.io/badge/Gantt%20visual-preview-orange?style=flat)
![Tested](https://img.shields.io/badge/tested-October%202026-lightgrey?style=flat)


A sample report and dataset for trying the native [Gantt visual in Power BI](https://learn.microsoft.com/en-us/power-bi/visuals/power-bi-visualization-gantt), which is currently in preview. It includes the DAX measures I used to work around some of its current limitations.

Tested in October 2026. Preview features change quickly, so some of these workarounds may no longer be needed.

## Download

- **Just the report:** open [`report/NewGantt.pbix`](report/NewGantt.pbix) and select **Download raw file**.
- **Everything:** select **Code > Download ZIP** at the top of this page.

You need an up-to-date version of [Power BI Desktop](https://www.microsoft.com/power-bi/desktop). If the Gantt visual doesn't appear, check **File > Options and settings > Options > Preview features**.

## What's in this repo

| Folder | Contents |
| --- | --- |
| `data/` | `Schedule.csv`: dummy schedule with 25 work items across two projects |
| `measures/` | DAX measures used in the report, one file per measure |
| `powerquery/` | `Calendar.pq`: optional calendar table built from the dataset's date range |
| `report/` | `NewGantt.pbix`: the sample report |

## The dataset

`data/Schedule.csv` contains two dummy projects, **Sales Dashboard Revamp** and **Conference Talk Prep**, running from September to November 2026.

| Column | Description |
| --- | --- |
| `TaskID` | Unique ID for each work item |
| `Project` | First grouping level |
| `Phase` | Second grouping level |
| `WorkItem` | Task or milestone name (the row label) |
| `Type` | `Task` or `Milestone` |
| `Owner` | Person responsible |
| `StartDate` | Start date |
| `EndDate` | End date. Milestones have the same date in `StartDate` and `EndDate` |
| `DurationDays` | Days between start and end (0 for milestones) |
| `Progress` | Percentage complete, as a decimal from 0 to 1 |
| `Status` | `Done`, `In progress`, `At risk` or `Not started` |
| `DependsOn` | IDs of predecessor tasks, separated by semicolons |

Progress and status were calculated as of 17 October 2026.

## Workarounds

### Milestones

The Gantt visual draws a milestone only when **End** is blank. This dataset stores milestones with the same date in `StartDate` and `EndDate`, so [`TaskEnd`](measures/TaskEnd.dax) returns blank for milestones. Use `StartDate` in **Start** and `TaskEnd` in **End**.

### Columns that only show at work-item level

Columns behave like a matrix, so a field such as `Status` appears on Project and Phase rows too. [`WorkItemStatus`](measures/WorkItemStatus.dax) uses `ISINSCOPE` so the status only shows on work-item rows.

### A warning icon for at-risk items

Conditional formatting is available for the bars, but not for the fields in **Columns**. [`WorkItemStatusIcon`](measures/WorkItemStatusIcon.dax) adds the ⚠️ emoji to the text instead, so at-risk items show as "At risk ⚠️". Because the words stay next to the icon, the meaning doesn't rely on the icon alone.

### Dynamic subtitle

[`GanttSubTitle`](measures/GanttSubTitle.dax) shows the number of items at risk and the next upcoming milestone, for example "Project Timeline: 2 items at risk · Next milestone 12 Nov". Add it under **Format visual > Title > Subtitle > Text > fx**.

## Getting started

1. Open `report/NewGantt.pbix`, or build your own report.
2. To build your own, load `data/Schedule.csv` with **Get Data > Text/CSV** and name the query `Schedule`. Check that `StartDate` and `EndDate` are typed as dates.
3. Add the measures from `measures/`.
4. Optionally, add the calendar table from `powerquery/Calendar.pq`.
5. Add a Gantt visual and set:
   - **Categories:** `Project`, then `Phase`
   - **Row label:** `WorkItem`
   - **Start:** `StartDate`
   - **End:** `TaskEnd`
   - **Progress:** `Progress`
   - **Columns:** `WorkItemStatusIcon`

## Known limitations (as of October 2026)

- No baseline comparison
- No today line, and no option to scroll to the current date
- No conditional formatting on columns
- Up to 1,000 rows and three grouping levels
- No dependencies, critical path or float
