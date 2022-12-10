IF EXISTS (SELECT
    *
  FROM sys.databases
  WHERE [name] = 'TelecomCase_GrgEdu')

  DROP DATABASE TelecomCase_GrgEdu

CREATE DATABASE TelecomCase_GrgEdu
GO

USE TelecomCase_GrgEdu
GO

--Create Transactional 

CREATE TABLE Fact_Transaction (
  id int IDENTITY (1, 1),
  transaction_id int NOT NULL,
  imsi nvarchar(9) NOT NULL,
  subscriber_id int,
  tac nvarchar(8) NOT NULL,
  snr nvarchar(6) NOT NULL,
  imei nvarchar(14) NULL,
  cell int NOT NULL,
  lac int NOT NULL,
  event_type nvarchar(1) NULL,
  event_ts datetime NOT NULL,
  audit_id int NOT NULL DEFAULT (-1)

  --CONSTRAINT pk_fact_transaction_id PRIMARY KEY (id)
)

GO

CREATE TABLE Err_Destination_Output (
  id int,
  imsi nvarchar(9),
  imei nvarchar(14),
  cell int,
  lac int,
  event_type nvarchar(1),
  event_ts datetime,
  subscriber_id int,
  tac nvarchar(8),
  snr nvarchar(6),
  ErrorCode int,
  ErrorColumn int,
  audit_id int not null default(-1)
)

GO

CREATE TABLE Err_Source_Input (
  id int IDENTITY (1, 1),
  [Flat File Source Error Output Column] varchar(max),
  ErrorCode int,
  ErrorColumn int,
  audit_id int not null default(-1)
)

GO

CREATE TABLE Dim_Audit (
  id int IDENTITY (1, 1) NOT NULL PRIMARY KEY,
  batch_id int,
  package_name nvarchar(255) NOT NULL,
  file_path nvarchar(255) NOT NULL,
  rows_extracted int, -- rows in the source file
  rows_inserted int,
  rows_rejected int,
  created_at datetime DEFAULT (GETDATE()),
  updated_at datetime DEFAULT (GETDATE()),
  SuccessfulProcessingInd nchar(1) NOT NULL DEFAULT 'N'
)

GO

--ALTER TABLE Fact_Transaction
--ADD CONSTRAINT fk_fact_transaction_dim_audit FOREIGN KEY (audit_id) REFERENCES Dim_Audit (id)

--GO

--//Insert Unkown Record with id = -1

SET IDENTITY_INSERT Dim_Audit ON

INSERT INTO Dim_Audit (id, batch_id, package_name, file_path, rows_extracted, rows_inserted, rows_rejected)
  VALUES (-1, 0, 'Unknown', 'Unknown', NULL, NULL, NULL)

SET IDENTITY_INSERT Dim_Audit OFF

GO