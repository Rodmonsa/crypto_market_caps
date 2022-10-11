CREATE PROCEDURE crypto_rank_nulls_with_temp_table
 @rank int,
 @platf nvarchar(100)

	AS 

	BEGIN 

SELECT *
INTO #MyTempTable 
FROM (
    SELECT c.platform_name, Name, symbol, a.platform_id, 
    Market_cap,
    ROW_NUMBER() OVER (PARTITION BY a.Platform_id Order by market_cap DESC) AS Rnks
    FROM [dbo].[Fact] as a
	JOIN [dbo].[Dim] as b ON a.id=b.id
	JOIN [dbo].[Platdim] AS c ON a.platform_id=c.platform_id
)RNK
IF @rank IS null
	SET @rank= (SELECT max(Rnks) FROM #MyTempTable)
IF @platf IS null
	SET @platf= (SELECT STRING_AGG (platform_id, ',') AS column1 FROM Platdim)

SELECT platform_id, platform_name, Name, symbol, Market_cap, Rnks
FROM #MyTempTable
WHERE  platform_id IN (SELECT value FROM string_split(@platf, ',')) AND Rnks <= @rank


END