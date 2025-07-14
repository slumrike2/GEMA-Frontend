/**
 * @fileoverview Configuración de Drizzle ORM para GEMA Backend
 * 
 * Este archivo configura Drizzle Kit para la generación de migraciones
 * y el manejo del esquema de base de datos. Define la ubicación del
 * esquema, el directorio de salida para migraciones y las credenciales
 * de la base de datos.
 * 
 * @author GEMA Development Team
 * @version 1.0.0
 */

import { config } from 'dotenv';
import { defineConfig } from 'drizzle-kit';

// Carga las variables de entorno desde el archivo .env
config({ path: '.env' });

/**
 * Configuración de Drizzle Kit
 * 
 * Esta configuración define:
 * - schema: Ruta al archivo que contiene el esquema de la base de datos
 * - out: Directorio donde se generarán las migraciones
 * - dialect: Tipo de base de datos (PostgreSQL)
 * - dbCredentials: Credenciales de conexión a la base de datos
 */
export default defineConfig({
	schema: './src/db/schema/schema.ts', // Ruta al archivo de esquema
	out: './supabase/migrations', // Directorio de salida para migraciones
	dialect: 'postgresql', // Tipo de base de datos
	dbCredentials: {
		url: process.env.DATABASE_URL! // URL de conexión desde variables de entorno
	}
});
