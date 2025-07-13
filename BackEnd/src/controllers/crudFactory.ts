/**
 * @fileoverview Factory para operaciones CRUD genéricas
 * 
 * Este archivo proporciona una fábrica de funciones CRUD que pueden ser
 * utilizadas por cualquier controlador para implementar operaciones básicas
 * de base de datos (Create, Read, Update, Delete) de manera consistente.
 * 
 * Incluye validación automática de datos usando Zod, manejo de errores
 * estandarizado y logging para debugging.
 * 
 * @author GEMA Development Team
 * @version 1.0.0
 */

import { z, ZodSchema } from 'zod';
import { eq, and } from 'drizzle-orm';
import { AnyPgTable } from 'drizzle-orm/pg-core';
import { db } from '../db';
import { Request, Response } from 'express';
import { User } from '../db/schema/schema';
import { UserSchema } from '../db/schema/validationSchema';

/**
 * Construye una cláusula WHERE para claves primarias simples o compuestas
 * 
 * Esta función helper determina automáticamente si la tabla tiene una
 * clave primaria simple o compuesta y construye la cláusula WHERE apropiada.
 * 
 * @param table - Tabla de Drizzle ORM
 * @param pkValues - Objeto con los valores de la clave primaria
 * @returns Cláusula WHERE para la consulta
 */
function buildPkWhere(table: AnyPgTable, pkValues: Record<string, any>) {
	// Si hay una sola clave primaria, usa eq()
	if (Object.keys(pkValues).length === 1) {
		const [key, value] = Object.entries(pkValues)[0];
		return eq(table[key], value);
	}
	// Si hay múltiples claves primarias, usa and() para combinarlas
	return and(
		...Object.entries(pkValues).map(([key, value]) => eq(table[key], value))
	);
}

/**
 * Opciones para crear un controlador CRUD
 * 
 * Define la configuración necesaria para crear un controlador CRUD:
 * - table: Tabla de Drizzle ORM
 * - validationSchema: Esquema de validación Zod
 * - objectName: Nombre del objeto para mensajes de error (opcional)
 */
interface CrudFactoryOptions<S extends ZodSchema> {
	table: AnyPgTable;
	validationSchema: S;
	objectName?: string; // Default name for error messages
}

// Ejemplo de uso del factory para usuarios
const userBaseCrud = createCrud({
	table: User,
	validationSchema: UserSchema,
	objectName: 'User'
});

userBaseCrud.getByPk;

/**
 * Crea un controlador CRUD completo con todas las operaciones básicas
 * 
 * Esta función factory genera automáticamente todas las funciones CRUD:
 * - insert: Crear nuevos registros
 * - getByPk: Obtener registro por clave primaria
 * - getAll: Obtener todos los registros
 * - update: Actualizar registros existentes
 * - delete: Eliminar registros
 * 
 * Cada función incluye:
 * - Validación automática de datos
 * - Manejo de errores estandarizado
 * - Logging para debugging
 * - Respuestas HTTP apropiadas
 * 
 * @param options - Configuración del controlador CRUD
 * @returns Objeto con todas las funciones CRUD
 */
export function createCrud<S extends ZodSchema>({
	table,
	validationSchema,
	objectName = 'object' // Default name for error messages
}: CrudFactoryOptions<S>) {
	return {
		/**
		 * Crea un nuevo registro en la base de datos
		 * 
		 * Endpoint: POST /api/[resource]
		 * 
		 * Valida los datos de entrada usando el esquema proporcionado,
		 * inserta el registro en la base de datos y retorna el registro creado.
		 * 
		 * @param req - Request de Express con los datos del nuevo registro
		 * @param res - Response de Express
		 * @returns Registro creado con status 201 o error con status apropiado
		 */
		async insert(req: Request, res: Response) {
			console.log(`[${objectName}] Insert request:`, req.body);
			try {
				// Valida los datos de entrada usando Zod
				const validated = validationSchema.parse(req.body);
				
				// Inserta el registro en la base de datos
				const result = await db.insert(table).values(validated).returning();
				
				console.log(`[${objectName}] Insert result:`, result[0]);
				res.status(201).json(result[0]);
			} catch (error) {
				console.error(`[${objectName}] Insert error:`, error);
				
				// Maneja errores de validación
				if (error instanceof z.ZodError) {
					res.status(400).json({
						error: 'Validation Error for ' + objectName,
						details: error.errors
					});
				} else {
					// Maneja otros errores (base de datos, etc.)
					res.status(500).json({
						error: 'Error inserting data for ' + objectName,
						details: error.message
					});
				}
			}
		},

		/**
		 * Obtiene un registro por su clave primaria
		 * 
		 * Endpoint: GET /api/[resource]/:id
		 * 
		 * Construye la cláusula WHERE basada en los parámetros de la URL
		 * y retorna el registro encontrado o null si no existe.
		 * 
		 * @param req - Request de Express con los parámetros de la URL
		 * @param res - Response de Express
		 * @returns Registro encontrado con status 200 o null si no existe
		 */
		async getByPk(req: Request, res: Response) {
			console.log(`[${objectName}] GetByPk request:`, req.params);
			try {
				const pk = req.params;
				
				// Construye la cláusula WHERE y ejecuta la consulta
				const result = await db
					.select()
					.from(table)
					.where(buildPkWhere(table, pk));
				
				console.log(`[${objectName}] GetByPk result:`, result[0] || null);
				res.status(200).json(result[0] || null);
			} catch (error) {
				console.error(`[${objectName}] GetByPk error:`, error);
				res.status(500).json({
					error: 'Error fetching data for ' + objectName,
					details: error.message
				});
			}
		},

		/**
		 * Obtiene todos los registros de la tabla
		 * 
		 * Endpoint: GET /api/[resource]
		 * 
		 * Retorna todos los registros de la tabla sin filtros.
		 * 
		 * @param req - Request de Express
		 * @param res - Response de Express
		 * @returns Array con todos los registros con status 200
		 */
		async getAll(req: Request, res: Response) {
			console.log(`[${objectName}] GetAll request`);
			try {
				// Obtiene todos los registros de la tabla
				const result = await db.select().from(table);
				
				console.log(`[${objectName}] GetAll result:`, result);
				res.status(200).json(result);
			} catch (error) {
				console.error(`[${objectName}] GetAll error:`, error);
				res.status(500).json({
					error: 'Error fetching all data for ' + objectName,
					details: error.message
				});
			}
		},

		/**
		 * Actualiza un registro existente por su clave primaria
		 * 
		 * Endpoint: PUT /api/[resource]/:id
		 * 
		 * Valida los datos de actualización, construye la cláusula WHERE
		 * basada en los parámetros de la URL y actualiza el registro.
		 * 
		 * @param req - Request de Express con parámetros y datos de actualización
		 * @param res - Response de Express
		 * @returns Registro actualizado con status 200 o error con status apropiado
		 */
		async update(req: Request, res: Response) {
			console.log(`[${objectName}] Update request:`, { params: req.params, body: req.body });
			try {
				const pk = req.params;
				
				// Valida los datos de actualización
				const validated = validationSchema.parse(req.body);
				
				// Construye la cláusula WHERE y actualiza el registro
				const where = buildPkWhere(table, pk);
				const result = await db
					.update(table)
					.set(validated)
					.where(where)
					.returning();
				
				console.log(`[${objectName}] Update result:`, result[0] || null);
				res.status(200).json(result[0] || null);
			} catch (error) {
				console.error(`[${objectName}] Update error:`, error);
				
				// Maneja errores de validación
				if (error instanceof z.ZodError) {
					res.status(400).json({
						error: 'Validation Error for ' + objectName,
						details: error.errors
					});
				} else {
					// Maneja otros errores
					res.status(500).json({
						error: 'Error updating data for ' + objectName,
						details: error.message
					});
				}
			}
		},

		/**
		 * Elimina un registro por su clave primaria
		 * 
		 * Endpoint: DELETE /api/[resource]/:id
		 * 
		 * Construye la cláusula WHERE basada en los parámetros de la URL
		 * y elimina el registro de la base de datos.
		 * 
		 * @param req - Request de Express con los parámetros de la URL
		 * @param res - Response de Express
		 * @returns Registro eliminado con status 200 o error con status apropiado
		 */
		async delete(req: Request, res: Response) {
			console.log(`[${objectName}] Delete request:`, req.params);
			try {
				// Construye la cláusula WHERE y elimina el registro
				const where = buildPkWhere(table, req.params);
				const result = await db.delete(table).where(where).returning();
				
				console.log(`[${objectName}] Delete result:`, result[0] || null);
				res.status(200).json(result[0] || null);
			} catch (error) {
				console.error(`[${objectName}] Delete error:`, error);
				res.status(500).json({
					error: 'Error deleting data for ' + objectName,
					details: error.message
				});
			}
		}
	};
}
