/*Procedures con XML*/
 CREATE DATABASE PRUEBAPROCEDUREXML
 GO

 USE PRUEBAPROCEDUREXML
 GO
 
 Create Table tbl_Vehiculos
 (
  Id nvarchar(50),
  Nombre nvarchar(50),
  Lanzamiento nvarchar(50)
 )

 go
 Create PROCEDURE usp_InsertarXMLAutos
 @xmlAutos XML
 AS
 BEGIN
  SET NOCOUNT ON;

  INSERT INTO tbl_Vehiculos
  SELECT
   vehiculo.value('(vehiculo_id/text())[1]','nvarchar(50)') as Id,
   vehiculo.value('(vehiculo_nombre/text())[1]','nvarchar(50)') as Nombre,
   vehiculo.value('(vehiculo_lanzamiento/text())[1]','nvarchar(50)') as Lanzamiento
  FROM @xmlAutos.nodes('/vehiculos/vehiculo') as TEMPTABLE(vehiculo)

 END

 --<?xml version="1.0" standalone="yes">
 Declare @xmlxml XML
 Set @xmlxml =
 '<vehiculos>
	<vehiculo>
		<vehiculo_id>1</vehiculo_id>
		<vehiculo_nombre>Carro1</vehiculo_nombre>
		<vehiculo_lanzamiento>2014</vehiculo_lanzamiento>
	</vehiculo>
	<vehiculo>
		<vehiculo_id>2</vehiculo_id>
		<vehiculo_nombre>Carro2</vehiculo_nombre>
		<vehiculo_lanzamiento>2017</vehiculo_lanzamiento>
	</vehiculo>
 </vehiculos>'

 
 --Ejecutar
 Declare @return_value int
 exec @return_value = usp_InsertarXMLAutos @xmlAutos = @xmlxml

 select * from tbl_Vehiculos