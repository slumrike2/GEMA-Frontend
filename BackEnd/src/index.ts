/**
 * @fileoverview Punto de entrada principal de la aplicación GEMA Backend
 * 
 * Este archivo inicia el servidor Express y configura el puerto de escucha.
 * La aplicación se ejecuta en el puerto especificado en la variable de entorno PORT,
 * o en el puerto 3000 por defecto.
 * 
 * @author GEMA Development Team
 * @version 1.0.0
 */

import app from './app'

// Configuración del puerto de escucha del servidor
// Prioriza la variable de entorno PORT, si no existe usa el puerto 3000
const port = process.env.PORT || 3000;

// Inicia el servidor Express y muestra un mensaje de confirmación
app.listen(port, () => {
    console.log('Server is running in ' + port);
})