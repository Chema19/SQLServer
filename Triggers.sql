

CREATE TABLE Categorias
(
 	IdCategoria int IDENTITY(1,1)PRIMARY KEY,
 	Nombre nvarchar(50),
 	NroProductos int DEFAUlT 0,
 	Estado nvarchar(1) -- A = activo e I=inactivo
)
GO

CREATE TABLE Productos
(
 	IdProducto int PRIMARY KEY,
 	IdCategoria int,
 	Nombre nvarchar(50),
 	NroProductos int CHECK (nroproductos >= 2),
 	Estado nvarchar(1), -- A = activo e I=inactivo
 	Precio decimal(6,2)
 	CONSTRAINT FK_Productos_Categorias FOREIGN KEY (IdCategoria)     
    	REFERENCES Categorias (IdCategoria)     
)
GO

INSERT INTO Categorias VALUES (1,'Bebidas',0,'A')


--WHEN i WANT TO INSERT--
CREATE TRIGGER tg_InsProducts
ON Productos AFTER INSERT 
AS
	BEGIN
		DECLARE @NroProductos int
		DECLARE @IdCategoria int
		SELECT @IdCategoria = IdCategoria FROM inserted
		SELECT @NroProductos = count(*) FROM Productos Where IdCategoria = @IdCategoria

		UPDATE Categorias SET NroProductos = @NroProductos Where IdCategoria = @IdCategoria
	END 
GO

INSERT INTO Productos VALUES (1,2,'Inca Kola',5,'A',2)

--WHEN I WANT TO DELETE--
CREATE TRIGGER tg_DelProducts
ON Productos AFTER DELETE
AS
	BEGIN
		DECLARE @IdCategoria int
		SELECT @IdCategoria = IdCategoria FROM DELETED

		UPDATE Categorias SET NroProductos = NroProductos - 1
		Where IdCategoria = @IdCategoria
	END 
GO

DELETE FROM Productos Where IdProducto = 1


--ACTION INSTEAD OF DELETE--
CREATE TRIGGER tg_DelCategorias
ON Categorias INSTEAD OF DELETE
AS
	BEGIN
		DECLARE @IdCategoria int
    	SELECT @IdCategoria = IdCategoria FROM deleted

    	UPDATE Categorias SET Estado = 'I' WHERE IdCategoria = @IdCategoria
	END

DELETE FROM Categorias WHERE IdCategoria = 2


--ALTER TRIGGER tg_DelCategorias--
 CREATE TRIGGER trIO_DelCategorias
 ON Categorias INSTEAD OF DELETE
 AS
   	BEGIN
    	DECLARE @IdCategoria int
    	SELECT @IdCategoria = IdCategoria FROM deleted

    	UPDATE Categorias SET Estado = 'I' WHERE IdCategoria = @IdCategoria
		UPDATE Productos SET Estado = 'I' WHERE IdCategoria = @IdCategoria
   END


    DELETE FROM Categorias WHERE IdCategoria = 2
    GO

CREATE  TRIGGER trIO_InsProductos
ON Productos INSTEAD OF INSERT
AS
  	BEGIN
   		Declare @Nombre nvarchar(50) = ''
   		SELECT @Nombre = UPPER(RTRIM(LTRIM(Nombre))) FROM inserted
   		--IF EXISTS(Select * FROM Productos WHERE UPPER(RTRIM(LTRIM(Nombre))) = @Nombre)
   		IF EXISTS(Select p.* FROM Productos p 
		JOIN inserted i on UPPER(RTRIM(LTRIM(p.Nombre))) = UPPER(RTRIM(LTRIM(i.Nombre))))
    		BEGIN
	 			print 'No es posible insertar debido a que ya existe un producto con el mismo nombre ' + @nombre
			END
   		ELSE
    		BEGIN
	 			INSERT INTO Productos SELECT * FROM inserted
     			print 'Se insertó ' + @nombre
			END
  	END

INSERT INTO Productos VALUES (4,2,'Ideal',14,'I',3.60)
INSERT INTO Productos VALUES (5,2,'Ideal',14,'I',3.60)

CREATE TABLE Empleados
(
 	IdEmpleado int not null primary key,
 	Nombre nvarchar(50),
 	FecNacimiento datetime
)
GO
CREATE TABLE LogEmpleados
(
 	Idlog int identity(1,1) not null primary key,
 	IdEmpleado int not null,
 	Nombre nvarchar(50),
 	FecNacimiento datetime,
 	FechaAccion datetime,
 	TipoAccion nvarchar(5),
 	Usuario nvarchar(10),
 	Maquina nvarchar(10)
)
GO


CREATE TRIGGER trAF_Empleados
ON Empleados AFTER INSERT,UPDATE,DELETE
AS
	BEGIN
	    Declare @Fecha datetime,@Usuario nvarchar(10),@Maquina nvarchar(10)
		Set @Fecha = GETDATE()
		Set @Usuario = USER_NAME()
		Set @Maquina = HOST_NAME()
		--select * from inserted
		--select * from deleted
		IF (EXISTS(Select * from deleted) and EXISTS(select * from inserted))
		 	BEGIN
		   		print 'UPDATE'
		   		insert into LogEmpleados
		   		select IdEmpleado,Nombre,FecNacimiento,@Fecha,'NU-UP',@Usuario,@Maquina from inserted

		   		insert into LogEmpleados
		   		select IdEmpleado,Nombre,FecNacimiento,@Fecha,'AN-UP',@Usuario,@Maquina from deleted
		 	END
		ELSE
		  	BEGIN  
			  IF EXISTS(Select * from deleted) 
			     BEGIN
				   	print 'DELETE'
				   	insert into LogEmpleados
				   	select IdEmpleado,Nombre,FecNacimiento,@Fecha,'DE-DE',@Usuario,@Maquina from deleted
				 END
			  ELSE
			     BEGIN
				   	print 'INSERTAR'
				   	insert into LogEmpleados
				   	select IdEmpleado,Nombre,FecNacimiento,@Fecha,'IN-IN',@Usuario,@Maquina from inserted
                 END
		  	END
    END 

INSERT INTO Empleados VALUES (1,'Maria Pérez','1984-01-05')
INSERT INTO Empleados VALUES (2,'Carla Rojas','1988-02-21')
UPDATE Empleados Set Nombre = 'Juana la Cubana' Where IdEmpleado = 1
DELETE FROM Empleados Where IdEmpleado = 1


delete from Productos where IdProducto = 4
select * from Categorias
select * from Productos
 
Select * from Empleados
Select * from LogEmpleados