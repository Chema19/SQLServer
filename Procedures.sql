CREATE PROCEDURE Production.GetReviews
AS
SELECT	Name, 
		ReviewDate,
		ReviewerName,
		Rating,
		Comments
FROM	Production.ProductReview Review
		INNER JOIN Production.Product Product ON Product.ProductID = Review.productid
ORDER BY Name, ReviewDate DESC
GO
-- Test stored procedure
EXECUTE Production.GetReviews
GO

ALTER PROCEDURE Production.GetReviews
	@ProductID int -- Parametro de ingreso o INPUT
AS
SELECT	Name, 
		ReviewDate,
		ReviewerName,
		Rating,
		Comments
FROM	Production.ProductReview Review
		INNER JOIN Production.Product Product ON Product.ProductID = Review.productid
WHERE	Review.ProductID = @ProductID
ORDER BY Name, ReviewDate DESC
GO

-- Test procedure with parameter
EXECUTE Production.GetReviews 937
EXECUTE Production.GetReviews
GO


ALTER PROCEDURE Production.GetReviews
	@ProductID int = 0 -- Parametro de ingreso o INPUT, que tiene un valor por defecto
AS
IF (@ProductID = 0)
	SELECT	Name, 
			ReviewDate,
			ReviewerName,
			Rating,
			Comments
	FROM	Production.ProductReview Review
			INNER JOIN Production.Product Product ON Product.ProductID = Review.productid
	ORDER BY Name, ReviewDate DESC
ELSE
	SELECT	Name, 
			ReviewDate,
			ReviewerName,
			Rating,
			Comments
	FROM	Production.ProductReview Review
			INNER JOIN Production.Product Product ON Product.ProductID = Review.productid
	WHERE	Review.ProductID = @ProductID -- filtra solo un producto
	ORDER BY Name, ReviewDate DESC
GO

-- Test procedure with parameter and default
EXECUTE Production.GetReviews 937
EXECUTE Production.GetReviews 
GO

ALTER PROCEDURE Production.GetReviews
	@ProductID int = 0, @NumberOfReviews int OUTPUT
AS
IF (@ProductID = 0)
	SELECT	Name, 
			ReviewDate,
			ReviewerName,
			Rating,
			Comments
	FROM	Production.ProductReview Review
			INNER JOIN Production.Product Product ON Product.ProductID = Review.productid
	ORDER BY Name, ReviewDate DESC
ELSE IF EXISTS(SELECT ProductID FROM Production.Product WHERE ProductID = @ProductID)
	SELECT	Name, 
			ReviewDate,
			ReviewerName,
			Rating,
			Comments
	FROM	Production.ProductReview Review
			INNER JOIN Production.Product Product ON Product.ProductID = Review.productid
	WHERE	Review.ProductID = @ProductID
	ORDER BY Name, ReviewDate DESC
ELSE
	RETURN -1

SET @NumberOfReviews = @@ROWCOUNT

RETURN 0
GO

-- Test output and return values
DECLARE @NumReviews int, @ReturnValue int

EXECUTE @ReturnValue = Production.GetReviews 937, @NumReviews OUTPUT
IF (@ReturnValue = 0)
	SELECT @NumReviews NumberOfReviews
ELSE
	SELECT 'ProductID does not exist' Error
GO

-- Drop the procedure
DROP PROC Production.GetReviews
GO


CREATE PROCEDURE usp_CU_Jugadores
--Agrega y/o actualiza a un jugador de acuerdo a su existencia por su ID
--Uso de TRY CATCH (commit y rollback)
  @IdJugador	int,
  @Nombres		nvarchar(50),
  @IdPais		int,
  @NroCamiseta	int,
  @Posicion		nvarchar(40) -- ARQU,DEFE,MEDI,DELA
AS
  BEGIN
	BEGIN TRY
	 BEGIN TRAN
		IF EXISTS(Select * From  TB_JUGADORES Where IdJugador = @IdJugador)
			BEGIN
			--actualizar
				print 'actualiza'
				UPDATE TB_JUGADORES SET Nombres		=	@Nombres,
										IdPais		=	@IdPais,
										NroCamiseta	=	@NroCamiseta,
										Posicion	=	@Posicion
				WHERE  IdJugador = @IdJugador	
			END
		ELSE
			BEGIN
			 print 'inserta'
				INSERT INTO TB_JUGADORES (Nombres,IdPais,NroCamiseta,Posicion)
							VALUES (@Nombres,@IdPais,@NroCamiseta,@Posicion)
 			 print 'actualiza cantidad de jugadores'
				UPDATE TB_PAIS SET NroJugadores = NroJugadores + 1,Estado = 'A' 
								WHERE IdPais = 1
			END
        print 'commit'
      COMMIT TRAN
	  RETURN
	END TRY
	BEGIN CATCH
		print 'select de error'
		SELECT  ERROR_NUMBER() AS ErrorNumber
				,ERROR_SEVERITY() AS ErrorSeverity
				,ERROR_STATE() AS ErrorState
				,ERROR_PROCEDURE() AS ErrorProcedure
				,ERROR_LINE() AS ErrorLine
				,ERROR_MESSAGE() AS ErrorMessage;
		print 'rollbak'
		ROLLBACK TRAN
	END CATCH
  END


CREATE PROCEDURE usp_Juego
 @IdPais1	int,
 @IdPais2	int,
 @Goles1	int,
 @Goles2	int
 AS
  BEGIN
    IF NOT EXISTS(Select * from TB_TABLA Where IdPais = @IdPais1)
		INSERT INTO TB_TABLA (IdPais) VALUES (@IdPais1)
    IF NOT EXISTS(Select * from TB_TABLA Where IdPais = @IdPais2)
		INSERT INTO TB_TABLA (IdPais) VALUES (@IdPais2)


	UPDATE TB_TABLA 
	SET PJugados = PJugados + 1,
		PGanados	=	PGanados	+ case when @Goles1 > @Goles2 then 1 else 0 end,
		PEmpatados	=	PEmpatados	+ case when @Goles1 = @Goles2 then 1 else 0 end,
		PPerdidos	=	PPerdidos	+ case when @Goles1 < @Goles2 then 1 else 0 end,
		GolesFavor	=	GolesFavor + @Goles1,
		GolesContra	=	GolesContra + @Goles2,
		Puntos		=	Puntos + case 
									when  @Goles1 > @Goles2 then 3
									when  @Goles1 = @Goles2 then 1
									else 0
								 end
	WHERE IdPais = @IdPais1
										
	UPDATE TB_TABLA 
	SET PJugados = PJugados + 1,
		PGanados	=	PGanados	+ case when @Goles2 > @Goles1 then 1 else 0 end,
		PEmpatados	=	PEmpatados	+ case when @Goles2 = @Goles1 then 1 else 0 end,
		PPerdidos	=	PPerdidos	+ case when @Goles2 < @Goles1 then 1 else 0 end,
		GolesFavor	=	GolesFavor + @Goles2,
		GolesContra	=	GolesContra + @Goles1,
		Puntos		=	Puntos + case 
									when  @Goles2 > @Goles1 then 3
									when  @Goles2 = @Goles1 then 1
									else 0
								 end
	WHERE IdPais = @IdPais2
  END
GO

CREATE FUNCTION ufx_PromedioGoles (@IdPais int)
RETURNS numeric(5,2)
AS
 begin
  DECLARE @PromGoles numeric(5,2)
  SELECT @PromGoles = GolesFavor / PJugados * 1.00
	FROM TB_TABLA WHERE IdPais = @IdPais
  RETURN @PromGoles
 end
GO

CREATE PROCEDURE usp_EstadisticaPais
@IdPais int
AS
 begin
	SELECT pa.Pais,tb.PJugados,tb.PGanados,tb.PEmpatados,tb.PPerdidos,tb.GolesFavor,tb.GolesContra,tb.Puntos,dbo.ufx_PromedioGoles(@IdPais) as PromedioGoles
	FROM TB_TABLA tb 
		JOIN TB_PAIS pa ON tb.IdPais = pa.IdPais
	WHERE pa.IdPais = @IdPais

 end

