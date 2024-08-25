﻿using CapaDatos;
using CapaEntidad;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CapaNegocio
{
    public class CN_Producto
    {
        private CD_Productos objcd_Producto = new CD_Productos();

        public List<Producto> Listar()
        {
            return objcd_Producto.Listar();
        }

        public int Registrar(Producto obj, out string Mensaje)
        {
            Mensaje = string.Empty;

            if (obj.Codigo == "")
            {
                Mensaje += "Es nesesario la Codigo del Producto\n";
            }
            
            if (obj.Nombre == "")
            {
                Mensaje += "Es nesesario la Nombre del Producto\n";
            }


            if (obj.Descripcion == "")
            {
                Mensaje += "Es nesesario la Descripcion de la Producto\n";
            }

            if (Mensaje != string.Empty)
            {
                return 0;
            }
            else
            {
                return objcd_Producto.Registrar(obj, out Mensaje);
            }
        }

        public bool Editar(Producto obj, out string Mensaje)
        {
            Mensaje = string.Empty;

            if (obj.Codigo == "")
            {
                Mensaje += "Es nesesario la Codigo del Producto\n";
            }

            if (obj.Nombre == "")
            {
                Mensaje += "Es nesesario la Nombre del Producto\n";
            }

            if (obj.Descripcion == "")
            {
                Mensaje += "Es nesesario la Descripcion de la Producto\n";
            }

            if (Mensaje != string.Empty)
            {
                return false;
            }
            else
            {
                return objcd_Producto.Editar(obj, out Mensaje);
            }
        }

        public bool Eliminar(Producto obj, out string Mensaje)
        {
            return objcd_Producto.Eliminar(obj, out Mensaje);
        }
    }
}
