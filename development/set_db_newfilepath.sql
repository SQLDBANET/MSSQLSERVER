SET NOCOUNT ON;

declare @data_folder varchar(max) = 'd:\mssql\data\'
declare @log_folder varchar(max) = 'e:\mssql\data\'
declare @tempdb_folder varchar(max) = 't:\mssql\data\'

create table #script_out ( script_order int, dbname varchar(max) ,file_type int, script  text )

insert into #script_out ( script_order , dbname  ,file_type, script  )
select '0' ,'_',0,'/*modify database file location*/'

insert into #script_out ( script_order , dbname  ,file_type, script  )
select '1' script_order , db_name(mf.database_id) dbname,type, 'use master' + CHAR(13)+CHAR(10) +'go'+ CHAR(13)+CHAR(10) +'alter database ' + db_name(mf.database_id) + ' modify file (name = ''' + name + ''', filename = ''' + case 
		when type = 0 and db_name(mf.database_id) !='tempdb'
			then @data_folder
		when type = 1 and db_name(mf.database_id) !='tempdb'
			then @log_folder
		when (type = 1 or type=0)  and db_name(mf.database_id) ='tempdb'
		then @tempdb_folder 
		end + reverse(left(reverse(physical_name), coalesce(nullif(charindex('\', reverse(physical_name)) - 1, - 1), len(physical_name)))) + ''')' + CHAR(13)+CHAR(10) +'go' script
from sys.master_files mf
where db_name(mf.database_id) not in (
		'master'
		,'model'
		,'msdb'
		)
order by database_id , type asc

insert into #script_out ( script_order , dbname  ,file_type, script  )
select '2' ,'_',0,'/*set database offline*/'

insert into #script_out ( script_order , dbname  ,file_type, script  )
select '3' script_order, name dbname ,0, 'use master' + CHAR(13)+CHAR(10) +'alter database ['+name+'] set offline with rollback immediate;' script from sys.databases
where db_name(database_id) not in (
		'master'
		,'model'
		,'msdb','tempdb'
		)
order by database_id 

insert into #script_out ( script_order , dbname  ,file_type, script  )
select '4' ,'_',0,'/*move files to data & log folders '+ CHAR(13)+CHAR(10) +'set database online once files have been moved*/'

insert into #script_out ( script_order , dbname  ,file_type, script  )
select '5' script_order, name dbname ,0, 'use master' + CHAR(13)+CHAR(10) +'go'+ CHAR(13)+CHAR(10) +'alter database ['+name+'] set online;' script from sys.databases
where db_name(database_id) not in (
		'master'
		,'model'
		,'msdb','tempdb'
		)
order by database_id 

select script from #script_out
order by script_order,dbname,file_type
drop table #script_out

-----------ROLLBACK--------

SET NOCOUNT ON;

declare @data_folder varchar(max) = 'd:\mssql\data\'
declare @log_folder varchar(max) = 'e:\mssql\data\'
declare @tempdb_folder varchar(max) = 't:\mssql\data\'

create table #script_out ( script_order int, dbname varchar(max) ,file_type int, script  text )

insert into #script_out ( script_order , dbname  ,file_type, script  )
select '0' ,'_',0,'/*modify database file location*/'

insert into #script_out ( script_order , dbname  ,file_type, script  )
select '1' script_order , db_name(mf.database_id) dbname,type, 'use master' + CHAR(13)+CHAR(10) +'go'+ CHAR(13)+CHAR(10) +'alter database ' + db_name(mf.database_id) + ' modify file (name = ''' + name + ''', filename = ''' + physical_name+''')' + CHAR(13)+CHAR(10) +'go' script
from sys.master_files mf
where db_name(mf.database_id) not in (
		'master'
		,'model'
		,'msdb'
		)
order by database_id , type asc

insert into #script_out ( script_order , dbname  ,file_type, script  )
select '2' ,'_',0,'/*set database offline*/'

insert into #script_out ( script_order , dbname  ,file_type, script  )
select '3' script_order, name dbname ,0, 'use master' + CHAR(13)+CHAR(10) +'alter database ['+name+'] set offline with rollback immediate;' script from sys.databases
where db_name(database_id) not in (
		'master'
		,'model'
		,'msdb','tempdb'
		)
order by database_id 

insert into #script_out ( script_order , dbname  ,file_type, script  )
select '4' ,'_',0,'/*move files to data & log folders '+ CHAR(13)+CHAR(10) +'set database online once files have been moved*/'

insert into #script_out ( script_order , dbname  ,file_type, script  )
select '5' script_order, name dbname ,0, 'use master' + CHAR(13)+CHAR(10) +'go'+ CHAR(13)+CHAR(10) +'alter database ['+name+'] set online;' script from sys.databases
where db_name(database_id) not in (
		'master'
		,'model'
		,'msdb','tempdb'
		)
order by database_id 

select script from #script_out
order by script_order,dbname,file_type
drop table #script_out
