
Create database DBSISTEMA_VENTA

go 

use DBSISTEMA_VENTA

go

create table ROL(
IdRol int primary key identity,
Descripcion varchar(50),
FechaRegistro datetime default getdate()
)

go

create table PERMISO(
IdPermiso int primary key identity,
IdRol int references ROL(IdRol),
NombreMenu varchar(100),
FechaRegistro datetime default getdate()
)

go

create table PROVEEDOR(
IdProveedor int primary key identity,
Documento varchar (50),
RazonSocial varchar(50),
Correo varchar (50),
Telefono varchar (50),
Estado bit,
FechaRegistro datetime default getdate()
)

go


create table CLIENTE(
IdCliente int primary key identity,
Documento varchar (50),
NombreCliente varchar(50),
Correo varchar (50),
Telefono varchar (50),
Estado bit,
FechaRegistro datetime default getdate()
)

go

create table USUARIO(
IdUsuario int primary key identity,
Documento varchar (50),
NombreCompleto varchar(50),
Correo varchar (50),
Clave varchar (50),
IdRol int references ROL(IdRol),
Estado bit,
FechaRegistro datetime default getdate()
)

go

create table CATEGORIA(
idCategoria int primary key identity,
Descripcion varchar (100),
Estado bit,
FechaRegistro datetime default getdate()
)

go

create table PRODUCTO(
idProducto int primary key identity,
Codigo varchar (50),
Nombre varchar (50),
Descripcion varchar (50),
idCategoria int references CATEGORIA(idCategoria),
Stock int not null default 0,
PrecioCompra decimal (10,2) default 0,
PrecioVenta decimal (10,2) default 0,
Estado bit,
FechaRegistro datetime default getdate()
)

go

create table COMPRA(
IdCompra int primary key identity,
IdUsuario int references USUARIO(IdUsuario),
IdProveedor int references PROVEEDOR(IdProveedor),
TipoDocumento varchar (50),
NumeroDocumento varchar(50),
MontoTotal decimal(10,2),
FechaRegistro datetime default getdate()
)

go

create table DETALLECOMPRA(
IdDetalleCompra int primary key identity,
IdCompra int references COMPRA(IdCompra),
IdProducto int references PRODUCTO(IdProducto),
PrecioCompra decimal(10,2) default 0,
PrecioVenta decimal(10,2) default 0,
Cantidad int,
MontoTotal decimal (10,2),
FechaRegistro datetime default getdate()
)

go

create table VENTA(
IdVenta int primary key identity,
IdUsuario int references USUARIO(IdUsuario),
TipoDocumento varchar (50),
NumeroDocumento varchar(50),
DocumentoCliente varchar (50),
NombreCliente varchar (100),
MontoPago decimal(10,2),
MontoCambio decimal(10,2),
MontoTotal decimal(10,2),
FechaRegistro datetime default getdate()
)

go

create table DETALLEVENTA(
IdDetalleVenta int primary key identity,
IdVenta int references VENTA(IdVenta),
IdProducto int references PRODUCTO(IdProducto),
PrecioVenta decimal(10,2) default 0,
Cantidad int,
SubTotal decimal (10,2),
FechaRegistro datetime default getdate()
)
exec sp_rename
'USUARIO.NombreCliente',
'NombreCompleto',
'Column'


Select * from USUARIO
/*
insert into ROL(Descripcion)
values('EMPLEADO')

insert into USUARIO(Documento,NombreCompleto,Correo,Clave,IdRol,Estado)
values('2020','EMPLEADO','@GMAIL.COM','456',2,1)
*/

Select * from ROL

select p.IdRol,p.NombreMenu from PERMISO p
inner join ROL r on r.IdRol = p.IdRol
inner join USUARIO u on u.IdRol = r.IdRol
where u.IdUsuario = 2

/*
insert into PERMISO(IdRol,NombreMenu)values
(1,'menuusuarios'),
(1,'menumantenedor'),
(1,'menuventas'),
(1,'menucompras'),
(1,'menuclientes'),
(1,'menuproveedores'),
(1,'menureportes'),
(1,'menuacercade')

insert into PERMISO(IdRol,NombreMenu)values
(2,'menuventas'),
(2,'menucompras'),
(2,'menuclientes'),
(2,'menuproveedores'),
(2,'menuacercade')
*/


select u.IdUsuario,u.Documento,u.NombreCompleto,u.Correo,u.Clave,u.Estado,r.IdRol,r.Descripcion from usuario u
inner join rol r on r.IdRol = u.IdRol

update USUARIO set Estado = 0 where IdUsuario = 2


create proc SP_REGISTRARUSUARIO(
@Documento varchar(50),
@NombreCompleto varchar(100),
@Correo varchar(100),
@Clave varchar(100),
@IdRol int,
@Estado bit,
@IdUsuarioResultado int output,
@Mensaje varchar(500) output
)  
as
begin
     set @IdUsuarioResultado = 0
	 set @Mensaje = ''

	 if not exists(select * from USUARIO where Documento = @Documento)
	 begin
	      insert into usuario(Documento,NombreCompleto,Correo,Clave,IdRol,Estado)values
		  (@Documento,@NombreCompleto,@Correo,@Clave,@IdRol,@Estado)

		  set @IdUsuarioResultado = SCOPE_IDENTITY()
		  set @Mensaje = ''
	 end
	 else
	     set @Mensaje = 'No se puede repetor el documento para mas de un usuario'
end

go



create proc SP_EDITARUSUARIO(
@IdUsuario int,
@Documento varchar(50),
@NombreCompleto varchar(100),
@Correo varchar(100),
@Clave varchar(100),
@IdRol int,
@Estado bit,
@Respuesta bit output,
@Mensaje varchar(500) output
)  
as
begin
     set @Respuesta = 0
	 set @Mensaje = ''

	 if not exists(select * from USUARIO where Documento = @Documento and IdUsuario != @IdUsuario)
	 begin
	      update usuario set
		  Documento = @Documento,
		  NombreCompleto = @NombreCompleto,
		  Correo = @Correo,
		  Clave = @Clave,
		  IdRol = @IdRol,
		  Estado = @Estado
		  where IdUsuario = @IdUsuario
		  

		  set @Respuesta = 1
		  set @Mensaje = ''
	 end
	 else
	     set @Mensaje = 'No se puede repetor el documento para mas de un usuario'
end

go





create proc SP_ELIMINARUSUARIO(
@IdUsuario int,
@Respuesta bit output,
@Mensaje varchar(500) output
)  
as
begin
     set @Respuesta = 0
	 set @Mensaje = ''
	 declare @pasoreglas bit = 1

	 if exists(SELECT * FROM COMPRA c
	 inner join USUARIO  u on  u.IdUsuario = c.IdUsuario
	 WHERE u.IdUsuario = @IdUsuario
	 )
	 BEGIN
	      set @pasoreglas = 0
	      set @Respuesta = 0
	      set @Mensaje = @Mensaje + 'No se puede eliminar porque el usuario se encuentra relacionado a una compra\n'
     End


	 if exists(SELECT * FROM VENTA v
	 inner join USUARIO  u on  u.IdUsuario = v.IdUsuario
	 WHERE u.IdUsuario = @IdUsuario
	 )
	 BEGIN
	      set @pasoreglas = 0
	      set @Respuesta = 0
	      set @Mensaje = @Mensaje + 'No se puede eliminar porque el usuario se encuentra relacionado a una venta\n'
     End


	 if(@pasoreglas = 1)
	 begin
		  delete from USUARIO where IdUsuario = @IdUsuario
		  set @Respuesta = 1 
	 end 

end








declare @Respuesta bit
declare @mesaje varchar(500)

exec SP_EDITARUSUARIO 2,'123','pruebas 2','test@gmail.com','456',2,1,@Respuesta output,@mesaje output

select @Respuesta
select @Mensaje

select * From USUARIO




/*.......PROCEDIMIRNTO PARA CATEGORIA....*/

--PROCEDIMIENTO PARA GUARDAR CATEGPORIA
Create PROC SP_RegistrarCategoria(
@Descripcion varchar(50),
@Estado bit,
@Resultado int output,
@Mensaje varchar(500) output
)as
begin 
	SET @Resultado = 0
	IF NOT EXISTS (SELECT * FROM CATEGORIA WHERE Descripcion = @Descripcion)
	begin
		insert into CATEGORIA(Descripcion,Estado) values (@Descripcion,@Estado)
		set @Resultado = SCOPE_IDENTITY()
	END
	ELSE
		 set @Mensaje = 'No se puede repetor el documento para mas de un usuario'
		
end

go

--PROCEDIMIENTO PARA MODIFICAR CATEGORIA
CREATE PROC SP_EditarCategoria(
@IdCategoria int,
@Descripcion varchar(50),
@Estado bit,
@Resultado int output,
@Mensaje varchar(500) output
)as
begin 
	SET @Resultado = 1
	IF NOT EXISTS (SELECT * FROM CATEGORIA WHERE Descripcion = @Descripcion and idCategoria != @IdCategoria)
		
		UPDATE CATEGORIA set
		Descripcion = @Descripcion,
		Estado = @Estado
		WHERE idCategoria = @IdCategoria
	ELSE
	begin
		 set @Resultado = 0
		 set @Mensaje = 'No se puede repetor el documento para mas de un usuario'
	end

		
end

go

--PROCEDIMIENTO PARA MODIFICAR CATEGORIA
CREATE PROC SP_EliminarCategoria(
@IdCategoria int,
@Resultado int output,
@Mensaje varchar(500) output
)as
begin 
	SET @Resultado = 1
	IF NOT EXISTS (
	select * from CATEGORIA c
	inner join PRODUCTO p on p.idCategoria = c.idCategoria
	where c.idCategoria = @IdCategoria
	)
	begin
	delete top(1) from CATEGORIA where idCategoria = @IdCategoria
	end	
	ELSE
	begin
		 set @Resultado = 0
		 set @Mensaje = 'La categoria se encuentra relacionada a un producto'
	end

		
end


select idCategoria,Descripcion,Estado from CATEGORIA


select * from PRODUCTO

insert into CATEGORIA(Descripcion,Estado) values ('Telefonos',1)
insert into CATEGORIA(Descripcion,Estado) values ('Computadoras',1)
insert into CATEGORIA(Descripcion,Estado) values ('Audifonos',1)

update CATEGORIA set Estado = 1



/*...PROCEDIMIENTOS ALMACENADOS PRODUCTO..*/
create PROC sp_RegistrarProducto(
@Codigo varchar(20),
@Nombre varchar(30),
@Descripcion varchar(30),
@IdCategoria int,
@Estado bit,
@Resultado int output,
@Mensaje varchar(500) output
)as
begin
	SET @Resultado = 0
	IF NOT EXISTS (SELECT * FROM producto WHERE Codigo = @Codigo)
	begin
		insert into producto(Codigo,Nombre,Descripcion,idCategoria,Estado) values (@Codigo,@Nombre,@Descripcion,@IdCategoria,@Estado)
		set @Resultado = SCOPE_IDENTITY()
	end
	ELSE
	Set @Mensaje = 'Ya existe un producto con el mismo codigo'
end

go

create procedure sp_ModificarProducto(
@IdProducto int,
@Codigo varchar(20),
@Nombre varchar(30),
@Descripcion varchar(30),
@IdCategoria int,
@Estado bit,
@Resultado int output,
@Mensaje varchar(500) output
)as
begin 
	Set @Resultado = 1
	IF not exists (select * from producto where codigo = @Codigo and idProducto = @IdProducto)
		
		update PRODUCTO set
		Codigo = @Codigo,
		Nombre = @Nombre,
		Descripcion = @Descripcion,
		idCategoria = @IdCategoria,
		Estado = @Estado
		where idProducto = @IdProducto
	Else
	begin
		SET @Resultado = 0
		SET @Mensaje = 'Ya existe un producto con el mismo codigo'
	end
end

go

create PROC SP_EliminarProducto(
@IdProducto int,
@Resultado int output,
@Mensaje varchar(500) output
)as
begin
	set @Respuesta = 0
	set @Mensaje = ''
	declare @Pasoreglas bit = 1

	IF EXISTS (SELECT * FROM DETALLECOMPRA dc
	INNER JOIN PRODUCTO p ON p.idProducto = dc.IdProducto
	WHERE p.idProducto = @IdProducto
	)
	begin
		set @Pasoreglas = 0
		set @Respuesta = 0
		set @Mensaje = @Mensaje +'No se puede eliminar por que esta relacionado a una COMPRA/n'
	end

	IF Exists (select * from DETALLEVENTA dv
	inner join PRODUCTO p on p.idProducto = dv.IdProducto
	where p.idProducto = @IdProducto
	)
	begin
		set @Pasoreglas = 0
		set @Respuesta = 0
		set @Mensaje = @Mensaje +'No se puede eliminar por que esta relacionado a una VENTA/n' 
	end

	 if(@Pasoreglas = 1)
	 begin
		delete from PRODUCTO where idProducto = @IdProducto
		set @Respuesta = 1
	end
end

select idProducto,Nombre,Codigo,p.Descripcion,c.idCategoria,c.Descripcion[DescripcionCategoria],Stock,PrecioCompra,PrecioVenta,p.Estado from PRODUCTO p
inner join CATEGORIA c on c.idCategoria = p.idCategoria


insert into PRODUCTO(Codigo,Nombre,Descripcion,idCategoria) values ('101010','SAMSUNG','SAMSUNG J7 PRIME',1)

update PRODUCTO set Estado = 1


select * from PRODUCTO


--proveedores

create PROC sp_RegistrarProveedor(
@Documento varchar(50),
@RazonSocial varchar(50),
@Correo varchar(50),
@Telefono varchar(50),
@Estado bit,
@Resultado int output,
@Mensaje varchar(500) output
)as
begin
	set @Resultado = 0
	declare @Idpersona int
	IF not exists (select * from PROVEEDOR where Documento = @Documento)
	begin
		insert into  proveedor(Documento,RazonSocial,Correo,Telefono,Estado) values(
		@Documento,@RazonSocial,@Correo,@Telefono,@Estado)

		set  @Resultado =SCOPE_IDENTITY()
	end
	else 
		set @Mensaje = 'El numero documento ya existe'
end

go 

create PROC sp_ModificarProveedor(
@IdProveedor int,
@Documento varchar(50),
@RazonSocial varchar(50),
@Correo varchar(50),
@Telefono varchar(50),
@Estado bit,
@Resultado int output,
@Mensaje varchar(500) output
)as
begin
	set @Resultado = 1
	Declare @IDPERSONA int 
	if not exists (select * from PROVEEDOR where Documento = @Documento and IdProveedor != @IdProveedor)
	begin
		update PROVEEDOR set
		Documento = @Documento,
		RazonSocial = @RazonSocial,
		Correo = @Correo,
		Telefono = @Telefono,
		Estado = @Estado
		where IdProveedor = @IdProveedor
	end
	else
	begin
		set @Resultado = 0
		set @Mensaje = 'el numero de documento ya existe'
	end
end

go

create PROC sp_EliminarProveedor(
@IdProveedor int,
@Resultado int output,
@Mensaje varchar(500) output
)as
begin
	set @Resultado = 1
	If not exists (
	select * from PROVEEDOR p
	inner join COMPRA c on p.IdProveedor = c.IdProveedor
	where p.IdProveedor = @IdProveedor
	)
	begin
		delete top(1) from PROVEEDOR where IdProveedor = @IdProveedor
	end
	ELSE
	begin
		set @Resultado = 0 
		set @Mensaje = 'El proveedor se encuantra relacionado con una compra'
	end
end


select IdProveedor,Documento,RazonSocial,Correo,Telefono,Estado from PROVEEDOR