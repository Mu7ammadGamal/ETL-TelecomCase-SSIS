# ETL-TelecomCase-SSIS

##### Case Study for Extract, Transform and Load data of telecom company  

## Table Of Contents
- [Problem Description](#problem)
- [Prerequisite](#pre) 
- [Implementation](#imp)
- [Result](#res)
- [Resources](#reso)

<a name="problem"></a>
## Problem Description

- Telecom company system stores its transactions periodically in `.CSV` format contains:

|Column Name|Data Type|Length|Is Nullable|Sample|
|----|----|----|----|----|
|ID|Int||False|123|
|IMSI|String|9|False|310120265|
|IMEI|String|14|True|490154203237518|
|CELL|Int||False|123|
|LAC|Int||False|123|
|EVENT_TYPE|String|1|True|1|
|EVENT_TS|Timestamp||False|16/1/2020 7:45:43|


- Transformation needed:

|Column Name|Mapping Rule|Target Model|
|----|----|----|
|ID|As-is|Transaction_id|
|IMSI|As-is, reject the record if null|IMSI|
|IMSI|Join with IMSI reference and get subscriber id, replace by -99999 if null|subscriber_id|
|IMEI|First 8 chars, if null or size is less than 15 replace by -99999|TAC|
|IMEI|Last 6 chars, if null or size is less than 15 replace by -99999|SNR|
|IMEI|As-is|IMEI|
|CELL|As-is, reject the record if null|CELL|
|LAC|As-is, reject the record if null|LAC|
|EVENT_TYPE|As-is|EVENT_TYPE|
|EVENT_TS|Validate the timestamp format to be YYYY-MM-DD HH:MM:SS, reject the record if null|EVENT_TS|

- Rejected records will be stored separately in another table.
- Auditing is required for data quality.
- After finshing storing data in database, move source csv file into another folder (Archiving).

<a name="pre"></a>
## Prerequisite
- Database and DWH concepts
- SQL (MS SQL Server)
- Data Integration Tool (SSIS)

<a name="imp"></a>
## Implementation

##### Setup Database Objects
First we need to create a database object `TelecomCase_GrgEdu`:
```sql
IF EXISTS (SELECT
    *
  FROM sys.databases
  WHERE [name] = 'TelecomCase_GrgEdu')

  DROP DATABASE TelecomCase_GrgEdu

CREATE DATABASE TelecomCase_GrgEdu
```

Create target table (destination):
```sql
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
)
```

Create table that holds errors of insertinng data into target table:
```sql
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
```

Create table that holds errors of extracting data from source files:
```sql
CREATE TABLE Err_Source_Input (
  id int IDENTITY (1, 1),
  [Flat File Source Error Output Column] varchar(max),
  ErrorCode int,
  ErrorColumn int,
  audit_id int not null default(-1)
)
```

Create table that holds auditinng information:
```sql
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
```

IMSI_Reference table that used to get `subscriber_id` is attached in this repo , check it from [here](https://github.com/Mu7ammadGamal/ETL-TelecomCase-SSIS/blob/master/IMSI%20%20Reference%20Script.sql) and excute it in the same database object `TelecomCase_GrgEdu`.

##### Setup ETL Job

- Control Flow

![control flow](https://user-images.githubusercontent.com/47898196/206879303-28b46bdc-7c5e-4b88-a25c-9dc3184a63bc.png)

- Data Flow

![data flow](https://user-images.githubusercontent.com/47898196/206879311-c00cb0db-b93b-49bd-85d1-97ee8e2a3e9e.png)


<a name="res"></a>
## Result

Transactional Table

![transaction](https://user-images.githubusercontent.com/47898196/206879282-6c188807-7447-4d72-b3f6-e5b4735c7a8a.png)


Source Errors

![src err](https://user-images.githubusercontent.com/47898196/206879287-09e935de-cdcb-4197-a650-1e51d5ed471e.png)


Destenation Errors

![dest err](https://user-images.githubusercontent.com/47898196/206879295-4b874cf4-3c6c-49d5-9725-8ad511a2484b.png)


Auditing

![audit](https://user-images.githubusercontent.com/47898196/206879315-908e42ce-e442-46f1-8947-761e87492671.png)


<a name="reso"></a>
## Resources
This project introduced in these tutorials on YouTube channels:
 [Garage Education](https://www.youtube.com/playlist?list=PLxNoJq6k39G_R3AA108CLE8w6n_CCCmDf),
[Et3lm Online](https://www.youtube.com/playlist?list=PLcAbhg_RWLaK-lCH5GxnaVfyeGjrm3QH8)
