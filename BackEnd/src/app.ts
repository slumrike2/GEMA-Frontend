/**
 * @fileoverview Configuración principal de la aplicación Express para GEMA Backend
 * 
 * Este archivo configura el servidor Express, middleware, y define todas las rutas
 * de la API REST. Cada ruta está mapeada a su respectivo controlador y maneja
 * operaciones CRUD para diferentes entidades del sistema.
 * 
 * @author GEMA Development Team
 * @version 1.0.0
 */

import express, { Request, Response } from 'express';
import cors from 'cors';

// Importación de todas las rutas de la aplicación
import userRoutes from './routes/user.routes';
// import technicianSpecialitiesRoutes from './routes/technicianSpecialities.routes';
import technicianRoutes from './routes/technician.routes';
import technicalTeamRoutes from './routes/technicalTeam.routes';
import technicalLocationTypesRoutes from './routes/technicalLocationTypes.routes';
import brandRoutes from './routes/brand.routes';
import equipmentRoutes from './routes/equipment.routes';
import equipmentOperationalLocationRoutes from './routes/equipmentOperationalLocation.routes';
import reportOriginRoutes from './routes/reportOrigin.routes';
import reportRoutes from './routes/report.routes';
import reportUpdateRoutes from './routes/reportUpdate.routes';
import technicalLocationRoutes from './routes/technicalLocation.routes';
import technicianSpecialityEnumRoutes from './routes/technicianSpecialityEnum.routes';

// Creación de la instancia de Express
const app = express();

// Configuración de middleware
app.use(cors()); // Habilita CORS para todas las rutas
app.use(express.json()); // Parsea el cuerpo de las peticiones como JSON

/**
 * Configuración de rutas de la API
 * 
 * Cada ruta está prefijada con '/api' y maneja operaciones CRUD específicas:
 * - GET: Obtener datos (todos o por ID)
 * - POST: Crear nuevos registros
 * - PUT: Actualizar registros existentes
 * - DELETE: Eliminar registros
 */

// Ruta: /api/users
// Descripción: Gestión de usuarios del sistema
// Endpoints disponibles:
//   - GET /api/users - Obtener todos los usuarios
//   - GET /api/users/:uuid - Obtener usuario por UUID
//   - POST /api/users - Crear nuevo usuario
//   - PUT /api/users/:uuid - Actualizar usuario
//   - DELETE /api/users/:uuid - Eliminar usuario
app.use('/api/users', userRoutes);

// Ruta: /api/technicians
// Descripción: Gestión de técnicos del sistema
// Endpoints disponibles:
//   - GET /api/technicians - Obtener todos los técnicos
//   - GET /api/technicians/:uuid - Obtener técnico por UUID
//   - POST /api/technicians - Crear nuevo técnico
//   - PUT /api/technicians/:uuid - Actualizar técnico
//   - DELETE /api/technicians/:uuid - Eliminar técnico
app.use('/api/technicians', technicianRoutes);

// Ruta: /api/technical-teams
// Descripción: Gestión de equipos técnicos
// Endpoints disponibles:
//   - GET /api/technical-teams - Obtener todos los equipos técnicos
//   - GET /api/technical-teams/:id - Obtener equipo técnico por ID
//   - POST /api/technical-teams - Crear nuevo equipo técnico
//   - PUT /api/technical-teams/:id - Actualizar equipo técnico
//   - DELETE /api/technical-teams/:id - Eliminar equipo técnico
app.use('/api/technical-teams', technicalTeamRoutes);

// Ruta: /api/technical-locations
// Descripción: Gestión de ubicaciones técnicas
// Endpoints disponibles:
//   - GET /api/technical-locations - Obtener todas las ubicaciones técnicas
//   - GET /api/technical-locations/:technicalCode - Obtener ubicación por código técnico
//   - POST /api/technical-locations - Crear nueva ubicación técnica
//   - PUT /api/technical-locations/:technicalCode - Actualizar ubicación técnica
//   - DELETE /api/technical-locations/:technicalCode - Eliminar ubicación técnica
//   - GET /api/technical-locations/:technicalCode/children - Obtener ubicaciones hijas
app.use('/api/technical-locations', technicalLocationRoutes);

// Ruta: /api/technical-location-types
// Descripción: Gestión de tipos de ubicaciones técnicas
// Endpoints disponibles:
//   - GET /api/technical-location-types - Obtener todos los tipos de ubicaciones
//   - GET /api/technical-location-types/:id - Obtener tipo por ID
//   - POST /api/technical-location-types - Crear nuevo tipo de ubicación
//   - PUT /api/technical-location-types/:id - Actualizar tipo de ubicación
//   - DELETE /api/technical-location-types/:id - Eliminar tipo de ubicación
app.use('/api/technical-location-types', technicalLocationTypesRoutes);

// Ruta: /api/brands
// Descripción: Gestión de marcas de equipos
// Endpoints disponibles:
//   - GET /api/brands - Obtener todas las marcas
//   - GET /api/brands/:id - Obtener marca por ID
//   - POST /api/brands - Crear nueva marca
//   - PUT /api/brands/:id - Actualizar marca
//   - DELETE /api/brands/:id - Eliminar marca
app.use('/api/brands', brandRoutes);

// Ruta: /api/equipment
// Descripción: Gestión de equipos
// Endpoints disponibles:
//   - GET /api/equipment - Obtener todos los equipos
//   - GET /api/equipment/:uuid - Obtener equipo por UUID
//   - POST /api/equipment - Crear nuevo equipo
//   - PUT /api/equipment/:uuid - Actualizar equipo
//   - DELETE /api/equipment/:uuid - Eliminar equipo
app.use('/api/equipment', equipmentRoutes);

// Ruta: /api/equipment-operational-locations
// Descripción: Gestión de ubicaciones operacionales de equipos
// Endpoints disponibles:
//   - GET /api/equipment-operational-locations - Obtener todas las ubicaciones operacionales
//   - GET /api/equipment-operational-locations/:equipmentUuid/:locationTechnicalCode - Obtener ubicación operacional por claves
//   - POST /api/equipment-operational-locations - Crear nueva ubicación operacional
//   - PUT /api/equipment-operational-locations/:equipmentUuid/:locationTechnicalCode - Actualizar ubicación operacional
//   - DELETE /api/equipment-operational-locations/:equipmentUuid/:locationTechnicalCode - Eliminar ubicación operacional
app.use(
	'/api/equipment-operational-locations',
	equipmentOperationalLocationRoutes
);

// Ruta: /api/report-origins
// Descripción: Gestión de orígenes de reportes
// Endpoints disponibles:
//   - GET /api/report-origins - Obtener todos los orígenes de reportes
//   - GET /api/report-origins/:id - Obtener origen por ID
//   - POST /api/report-origins - Crear nuevo origen de reporte
//   - PUT /api/report-origins/:id - Actualizar origen de reporte
//   - DELETE /api/report-origins/:id - Eliminar origen de reporte
app.use('/api/report-origins', reportOriginRoutes);

// Ruta: /api/reports
// Descripción: Gestión de reportes
// Endpoints disponibles:
//   - GET /api/reports - Obtener todos los reportes
//   - GET /api/reports/:id - Obtener reporte por ID
//   - POST /api/reports - Crear nuevo reporte
//   - PUT /api/reports/:id - Actualizar reporte
//   - DELETE /api/reports/:id - Eliminar reporte
app.use('/api/reports', reportRoutes);

// Ruta: /api/report-updates
// Descripción: Gestión de actualizaciones de reportes
// Endpoints disponibles:
//   - GET /api/report-updates - Obtener todas las actualizaciones de reportes
//   - GET /api/report-updates/:id - Obtener actualización por ID
//   - POST /api/report-updates - Crear nueva actualización de reporte
//   - PUT /api/report-updates/:id - Actualizar actualización de reporte
//   - DELETE /api/report-updates/:id - Eliminar actualización de reporte
app.use('/api/report-updates', reportUpdateRoutes);

// Ruta: /api/technician-specialities-enum
// Descripción: Gestión de especialidades de técnicos (enumeración)
// Endpoints disponibles:
//   - GET /api/technician-specialities-enum - Obtener todas las especialidades
//   - GET /api/technician-specialities-enum/:id - Obtener especialidad por ID
//   - POST /api/technician-specialities-enum - Crear nueva especialidad
//   - PUT /api/technician-specialities-enum/:id - Actualizar especialidad
//   - DELETE /api/technician-specialities-enum/:id - Eliminar especialidad
app.use('/api/technician-specialities-enum', technicianSpecialityEnumRoutes);

/**
 * Ruta de prueba y verificación del servidor
 * 
 * Endpoint: GET /
 * Descripción: Ruta de prueba para verificar que el servidor está funcionando
 * Respuesta: Mensaje de confirmación del servidor
 */
app.get('/', (_: Request, res: Response) => {
	res.send('Hola desde un backend de TypeScript + Express + Drizzle');
});

export default app;
