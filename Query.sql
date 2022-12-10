select * from [dbo].[Fact_Transaction]
select * from [dbo].[Err_Destination_Output]
--select * from [dbo].[Err_Source_Input]
select * from [dbo].[Dim_Audit]


select * from [dbo].[Err_Destination_Output]  E
JOIN [dbo].[Dim_Audit] D
ON E.audit_id = D.id

--ALTER TABLE Fact_Transaction
--DROP CONSTRAINT fk_fact_transaction_dim_audit
--TRUNCATE TABLE [dbo].[Fact_Transaction]

