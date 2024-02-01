SELECT	fk.name AS ForeignKeyName,
		OBJECT_NAME(fk.parent_object_id) AS TableName,
		col.name AS ColumnName,
		OBJECT_NAME(fkc.referenced_object_id) AS ReferencedTableName,
		ref.name AS ReferencedColumnName,
		fk.update_referential_action_desc,
		fk.delete_referential_action_desc
FROM sys.foreign_keys fk
	JOIN sys.foreign_key_columns fkc ON fkc.constraint_object_id = fk.object_id
	JOIN sys.columns col ON fkc.parent_column_id = col.column_id AND fkc.parent_object_id = col.object_id
	JOIN sys.columns ref ON fkc.referenced_column_id = ref.column_id AND fkc.referenced_object_id = ref.object_id
