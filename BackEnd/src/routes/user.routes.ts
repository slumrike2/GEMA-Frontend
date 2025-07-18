import { Router } from 'express';
import { userController } from '../controllers/user.controller';

const router = Router();

// Obtener todos los usuarios
router.get('/', userController.getAll);

// Obtener usuarios disponibles (no técnicos)
router.get('/available', userController.getAvailableUsers);

// Obtener usuario por UUID
router.get('/:uuid', userController.getByPk);

// Crear nuevo usuario con email y enviar correo de bienvenida
router.post('/', userController.createWithEmail);

// Actualizar nombre (u otros campos) de usuario por UUID
router.put('/:uuid', userController.updateName);

// Eliminar usuario por UUID
router.delete('/:uuid', userController.delete);

export default router;
