/**
 * @fileoverview Configuración de la conexión a la base de datos PostgreSQL
 * 
 * Este archivo configura la conexión a la base de datos usando Drizzle ORM
 * y PostgreSQL. Carga las variables de entorno desde un archivo .env
 * y establece la conexión con la base de datos.
 * 
 * @author GEMA Development Team
 * @version 1.0.0
 */

import { config } from 'dotenv';
import { drizzle } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';

// Carga las variables de entorno desde el archivo .env
// Esto permite acceder a DATABASE_URL y otras configuraciones
config({ path: '.env' }); // or .env.local

// Crea el cliente de PostgreSQL usando la URL de la base de datos
// La URL debe estar definida en la variable de entorno DATABASE_URL
const client = postgres(process.env.DATABASE_URL!);

// Exporta la instancia de Drizzle configurada con el cliente PostgreSQL
// Esta instancia se usará en toda la aplicación para realizar operaciones de base de datos
export const db = drizzle({ client: client });
