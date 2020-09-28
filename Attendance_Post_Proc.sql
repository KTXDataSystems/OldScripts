-- Attendance Post Processing. Step 7 of Nightly Processing Job;


DELETE FROM [KTX-SQL-DW].[KTX_Analytics].[dbo].[ADA_Consolidated_Enrollment_Append]
INSERT INTO [KTX-SQL-DW].[KTX_Analytics].[dbo].[ADA_Consolidated_Enrollment_Append]
?
SELECT [Academic_Year]
	  ,[KTX_District]
	  ,[School_ID]
	  ,[Student_ID_Local]
	  ,[Student_ID_State]
	  ,[Name_Last]
	  ,[Name_First]
	  ,[Grade]
	  ,CASE WHEN ([Hispanic_Latino] = 'Y' OR [Ethnicity] = 'Hispanic') THEN 'Hispanic'
		    ELSE [Ethnicity] END AS 'Aggregate_Ethnicity'
	  ,[Gender]
	  ,[ED]
	  ,CASE WHEN [SPED] = 'Y' THEN 'Y'
			ELSE 'N' END AS 'SPED'
	  ,CASE WHEN ([LEP] = 'Y' OR [LEP] = '1') THEN 'Y'
	        ELSE 'N' END AS 'LEP'
	  ,[At_Risk]
	  ,[Homeless]
	  ,[Date_Enrolled]
	  ,CASE WHEN CONCAT([KTX_District],[Date_Withdrawn]) = 'DFW20200604' THEN ''
	        ELSE [Date_Withdrawn] END AS 'Date_Withdrawn'
FROM [KTX-SQL-DW].[KTX_Analytics].[dbo].[Consolidated_Enrollment]
WHERE ([Date_Enrolled] != [Date_Withdrawn]) AND ([Date_Withdrawn] = '' OR CONCAT([KTX_District],[Date_Withdrawn]) = 'DFW20200604')
UNION ALL
SELECT [Academic_Year]
	  ,[KTX_District]
	  ,[School_ID]
	  ,[Student_ID_Local]
	  ,[Student_ID_State]
	  ,[Name_Last]
	  ,[Name_First]
	  ,[Grade]
	  ,CASE WHEN ([Hispanic_Latino] = 'Y' OR [Ethnicity] = 'Hispanic') THEN 'Hispanic'
		    ELSE [Ethnicity] END AS 'Aggregate_Ethnicity'
	  ,[Gender]
	  ,[ED]
	  ,CASE WHEN [SPED] = 'Y' THEN 'Y'
			ELSE 'N' END AS 'SPED'
	  ,CASE WHEN ([LEP] = 'Y' OR [LEP] = '1') THEN 'Y'
	        ELSE 'N' END AS 'LEP'
	  ,[At_Risk]
	  ,[Homeless]
	  ,[Date_Enrolled]
	  ,[Date_Withdrawn]
FROM [KTX-SQL-DW].[KTX_Analytics].[dbo].[Consolidated_Enrollment_historic]
WHERE ([Date_Enrolled] != [Date_Withdrawn]) AND ([Date_Withdrawn] = '' OR CONCAT([KTX_District],[Date_Withdrawn]) = 'DFW20170608' OR CONCAT([KTX_District],[Date_Withdrawn]) = 'DFW20180607' OR CONCAT([KTX_District],[Date_Withdrawn]) = 'DFW20190606' 
		OR CONCAT([KTX_District],[Date_Withdrawn]) = 'AUS20170601' OR CONCAT([KTX_District],[Date_Withdrawn]) = 'AUS20180529')
		AND [Academic_Year] != '2020'
ORDER BY [Academic_Year],[KTX_District],[School_ID],[Student_ID_Local],[Date_Enrolled]


DELETE FROM [KTX-SQL-DW].[KTX_Analytics].[dbo].[ADA_Reasons_and_Posting_Agg]
INSERT INTO [KTX-SQL-DW].[KTX_Analytics].[dbo].[ADA_Reasons_and_Posting_Agg]
?
SELECT [r].[Academic_Year]
	  ,[r].[KTX_District]
	  ,[r].[School_Name]
	  ,[r].[School_ID]
	  ,[r].[Student_id]
	  ,[r].[Name_First]
	  ,[r].[Name_Last]
	  ,[r].[Grade]
	  ,COUNT([p].[CA Eligible]) AS 'Total CA Absences'
	  ,COUNT([p].[T Eligible]) AS 'Total T Absences'
	  ,COUNT([p].[PA Eligible]) AS 'Total PA Absences'
FROM [KTX-SQL-DW].[KTX_Analytics].[dbo].[ADA_Absence_reasons] AS r
LEFT JOIN [KTX-SQL-DW].[KTX_Analytics].[dbo].[All_Posting_Codes] AS p
ON [r].[Academic_Year] = [p].[School Year] ANd [r].[School_ID] = [p].[New School ID] AND [r].[Absence_Reason] = [p].[Attendance Posting Code]
GROUP BY [r].[Academic_Year] ,[r].[KTX_District] ,[r].[School_Name] ,[r].[School_ID] ,[r].[Student_id] ,[r].[Name_First] ,[r].[Name_Last] ,[r].[Grade]

DELETE FROM [KTX-SQL-DW].[KTX_Analytics].[dbo].[ADA_Consolidated_Historical_Posting]
INSERT INTO [KTX-SQL-DW].[KTX_Analytics].[dbo].[ADA_Consolidated_Historical_Posting]
?
SELECT [c].[Academic_Year]
	  ,[c].[KTX_District]
	  ,[c].[School_ID]
	  ,[c].[Student_ID_Local]
	  ,[c].[Student_ID_State]
	  ,[c].[Name_First]
	  ,[c].[Name_Last]
	  ,[c].[Grade]
	  ,[c].[Aggregate_Ethnicity]
	  ,[c].[Gender]
	  ,[c].[ED]
	  ,[c].[SPED]
	  ,[c].[LEP]
	  ,[c].[At_Risk]
	  ,[c].[Homeless]
	  ,[c].[Date_Enrolled]
	  ,[c].[Date_Withdrawn]
	  ,[h].[Total_Absences]
	  ,[h].[Total_Absences_Excused]
	  ,[h].[Total_Days_Present]
	  ,[h].[Total_Days_Enrolled]
	  ,[h].[YTD_Percent_Present]
	  ,[a].[Total CA Absences]
	  ,[a].[Total T Absences]
	  ,[a].[Total PA Absences]
FROM [KTX-SQL-DW].[KTX_Analytics].[dbo].[ADA_Consolidated_Enrollment_Append] AS c
LEFT JOIN [KTX-SQL-DW].[KTX_Analytics].[dbo].[ADA_historical_by_student] AS h
ON [c].[Academic_Year] = [h].[Academic_Year] AND [c].[School_ID] = [h].[School_ID] AND [c].[Student_ID_Local] = [h].[Student_id]
LEFT JOIN [KTX-SQL-DW].[KTX_Analytics].[dbo].[ADA_Reasons_and_Posting_Agg] AS a
ON [c].[Academic_Year] = [a].[Academic_Year] AND [c].[School_ID] = [a].[School_ID] AND [c].[Student_ID_Local] = [a].[Student_id]
GROUP BY [c].[Academic_Year] ,[c].[KTX_District] ,[c].[School_ID] ,[c].[Student_ID_Local] ,[c].[Student_ID_State] ,[c].[Name_First] ,[c].[Name_Last] ,[c].[Grade]
	  ,[c].[Aggregate_Ethnicity] ,[c].[Gender] ,[c].[ED] ,[c].[SPED] ,[c].[LEP] ,[c].[At_Risk] ,[c].[Homeless] ,[c].[Date_Enrolled] ,[c].[Date_Withdrawn]
	  ,[h].[Total_Absences] ,[h].[Total_Absences_Excused] ,[h].[Total_Days_Present] ,[h].[Total_Days_Enrolled] ,[h].[YTD_Percent_Present], [a].[Total CA Absences]
	  ,[a].[Total T Absences], [a].[Total PA Absences]
ORDER BY [Student_ID_Local], [c].[Academic_Year]
