--function Escalar--

CREATE FUNCTION nombre
(
	@Parametro tipo_de_Dato
)
RETURNS tipo_de_Dato
AS
BEGIN
	DECLARE @Variable_Retorno tipo_de_Dato  

	RETURN @Variable_Retorno
END

--function InLine--

CREATE FUNCTION nombre
(
	@Parametro tipo_de_Dato
)
RETURNS TABLE
AS
RETURN 
(
	SELECT ..... Where dato = @Parametro
)

--function multiline--

CREATE FUNCTION nombre
(
	@Parametro tipo_de_Dato
)
RETURNS @Variable_Retorno TABLE ( Campo1 tipo_de_Dato NOT NULL, campo2 tipo_de_Dato NOT NULL)
AS
BEGIN
	INSERT @Variable_Retorno
	SELECT .........
	RETURN
END