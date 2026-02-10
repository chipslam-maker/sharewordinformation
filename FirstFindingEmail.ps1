Subject: Investigation into Data Inconsistency - Proposed SQL logic update
Hi [Name/Team],

I am currently investigating the data inconsistency issue between the New and Old server environments. During my analysis, I identified a potential gap in the source query logic that should be addressed to ensure a reliable comparison.

The Current Query: (This is currently non-deterministic as it lacks a fixed sort order)

<table style="background-color: #f4f4f4; border: 1px solid #cccccc; width: 100%;"> <tr> <td style="padding: 15px;"> <pre style="font-family: Consolas, 'Courier New', monospace; margin: 0; font-size: 13px;"> SELECT TOP 100 Id, CAST(CourierId as nvarchar(50)), Device, DepartedDateTime = CONVERT(nvarchar(23), [DepartedDateTime], 121), CompletionDateTime = CONVERT(nvarchar(23), [CompletionDateTime], 121) FROM [sm].[ExtractCourierRound] WHERE RoundCompleted=1 AND StopsItemsLoaded=0 AND id % 4 = 0 <b style="color: #d9534f;">-- Missing ORDER BY clause</b> </pre> </td> </tr> </table>

Technical Context & Concern: Currently, the package uses four parallel tasks to process data, each using a modulo filter (id % 4 = 0, 1, 2, 3) for distribution.

However, because each query lacks an ORDER BY clause, the TOP 100 selection remains non-deterministic. SQL Server may return different subsets of records on different servers based on physical data distribution. This means the four tasks on the New server might be processing a completely different data range compared to the Old server, which is likely the primary cause of the inconsistent results we are seeing.


Proposed Solution: I suggest standardizing the query in both environments to establish a consistent baseline:

<table style="background-color: #e8f4ff; border: 1px solid #b3d7ff; width: 100%;"> <tr> <td style="padding: 15px;"> <pre style="font-family: Consolas, 'Courier New', monospace; margin: 0; font-size: 13px;"> SELECT TOP 100 Id, ... FROM [sm].[ExtractCourierRound] WHERE RoundCompleted=1 AND StopsItemsLoaded=0 AND id % 4 = 0 <b style="color: #0056b3;">ORDER BY Id ASC</b> </pre> </td> </tr> </table>

Proposed Next Steps & Execution:

Eliminate Variables: While I cannot yet confirm if this is the sole cause of the data gaps, implementing this change will eliminate a major variable and allow me to pinpoint whether the issue lies in the data migration or the transformation logic.

Deployment: To minimize any potential risk and ensure consistency with the established release process, I suggest having Tim (who handled the latest deployment) execute this update. This ensures the change is integrated safely by someone familiar with the current environment setup.

The performance impact will be negligible as Id is an indexed field, and we are only sorting a small subset (100 records).

Please let me know if you are comfortable with this approach so we can coordinate with Tim.

Best regards,

[Your Name]
