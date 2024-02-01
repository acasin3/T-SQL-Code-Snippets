DECLARE @ConstraintName nvarchar(128)
DECLARE @TableName nvarchar(128)
DECLARE @ColumnName nvarchar(128)
DECLARE @ReferencedTableName nvarchar(128)
DECLARE @ParentColumnName nvarchar(128)
DECLARE @ReferencedColumnName nvarchar(128)
DECLARE @UpdateReferentialAction nvarchar(128)
DECLARE @DeleteReferentialAction nvarchar(128)
DECLARE @SQL nvarchar(MAX)

DECLARE cur CURSOR FOR
SELECT	fk.name AS ForeignKeyName,
		OBJECT_NAME(fk.parent_object_id) AS TableName,
		STRING_AGG(col.name, ', ') AS ColumnName,
		OBJECT_NAME(fkc.referenced_object_id) AS ReferencedTableName,
		STRING_AGG(ref.name, ', ') AS ReferencedColumnName,
		fk.update_referential_action_desc,
		fk.delete_referential_action_desc
FROM sys.foreign_keys fk
	JOIN sys.foreign_key_columns fkc ON fkc.constraint_object_id = fk.object_id
	JOIN sys.columns col ON fkc.parent_column_id = col.column_id AND fkc.parent_object_id = col.object_id
	JOIN sys.columns ref ON fkc.referenced_column_id = ref.column_id AND fkc.referenced_object_id = ref.object_id
GROUP BY fk.name, fk.parent_object_id, fkc.referenced_object_id, fk.update_referential_action_desc, fk.delete_referential_action_desc

OPEN cur

FETCH NEXT FROM cur INTO @ConstraintName, @TableName, @ColumnName, @ReferencedTableName, @ReferencedColumnName, @UpdateReferentialAction, @DeleteReferentialAction

WHILE @@FETCH_STATUS = 0
BEGIN
	SET	@ColumnName = '[' + REPLACE(@ColumnName, ', ', '], [') + ']'
	SET	@ReferencedColumnName = '[' + REPLACE(@ReferencedColumnName, ', ', '], [') + ']'

	SET @SQL = 'ALTER TABLE ' + QUOTENAME(@TableName) + ' WITH CHECK ADD CONSTRAINT ' + QUOTENAME(@ConstraintName) + ' FOREIGN KEY (' + @ColumnName + ')' 
				+ CHAR(13) + 'REFERENCES ' + QUOTENAME(@ReferencedTableName) + '(' + @ReferencedColumnName + ')'
	
	IF @UpdateReferentialAction <> 'NO_ACTION'
		SET @SQL = @SQL + CHAR(13) + 'ON UPDATE ' + @UpdateReferentialAction 

	IF @DeleteReferentialAction <> 'NO_ACTION'
		SET @SQL = @SQL + CHAR(13) + 'ON DELETE ' + @DeleteReferentialAction 

	SET	@SQL = @SQL 
				+ CHAR(13) + 'GO'
				+ CHAR(13)
    PRINT @SQL

	SET @SQL = 'ALTER TABLE ' + QUOTENAME(@TableName) + ' CHECK CONSTRAINT ' + QUOTENAME(@ConstraintName)
				+ CHAR(13) + 'GO'
				+ CHAR(13)
    PRINT @SQL

    FETCH NEXT FROM cur INTO @ConstraintName, @TableName, @ColumnName, @ReferencedTableName, @ReferencedColumnName, @UpdateReferentialAction, @DeleteReferentialAction
END

CLOSE cur
DEALLOCATE cur
