CREATE PROCEDURE WFM_ImportAFD (@FileName NVARCHAR(200))
AS
BEGIN
	IF OBJECT_ID('tempdb..#textfile') IS NOT NULL DROP TABLE #textfile
	CREATE TABLE #textfile (line VARCHAR(8000))

	DECLARE @sql varchar (1000)	
	SELECT @sql = 'bulk insert #textfile' + ' from ''K:\SISQUAL\AFD\' + @FileName + ''''
	
	-- executa a string montada na linha anterior
	
	EXEC (@sql)
		
	DECLARE @NFR  varchar(20)
	SET @NFR =(
		SELECT 
			SUBSTRING(line,188,17) 
		FROM #textfile 
		WHERE
			LEN(LINE) = 232
			AND SUBSTRING(line,10,1) = 1
		)
	INSERT INTO [DataBase].[dbo].[AFD_FILE](
		 [CARTAO]
		,[DATA]
		,[HORA]
		,[IDRELOGIO]
		,[NSR]
		,[NFR]
		)   
		SELECT  
			 SUBSTRING(line,23,12) AS CARTAO
			,CAST(CONCAT(SUBSTRING(line,15,4),'-',SUBSTRING(line,13,2),'-',SUBSTRING(line,11,2)) AS DATETIME) AS DATA
			,concat(SUBSTRING(line,19,2),':',SUBSTRING(line,21,2)) AS HORA
			,900 AS [IDRELOGIO]
			,SUBSTRING(line,1,9) AS NSR
			,SUBSTRING(@NFR ,PATINDEX('%[a-z,1-9]%',@NFR ),LEN(@NFR ))  AS NFR
		FROM #textfile
		WHERE
			LEN(LINE) = 34 
			AND (TRY_CAST(CONCAT(SUBSTRING(line,15,4),'-',SUBSTRING(line,13,2),'-',SUBSTRING(line,11,2)
			) AS DATETIME)) IS NOT NULL
			AND SUBSTRING(line,10,1) = 3
	DROP TABLE #textfile
END