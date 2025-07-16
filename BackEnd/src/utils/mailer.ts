import nodemailer from 'nodemailer';
import { string } from 'zod';

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER, 
    pass: process.env.EMAIL_PASS,
  },
});

export async function sendWelcomeEmail(email: string, password: string) {
  console.log('Esta entrando en la funcion Send')
  try {
    await transporter.sendMail({
      from: process.env.EMAIL_USER,
      to: email,
      subject: '¡Bienvenido a GEMA!',
      text: `Hola usuario,\n\nTu cuenta ha sido creada. Tu contraseña temporal es: ${password}\n\nPor favor cámbiala después de iniciar sesión.`,
      html: `<p>Hola usuario, </p><p>Tu cuenta ha sido creada.</p><p><b>Tu contraseña temporal es:</b> <code>${password}</code></p><p>Por favor cámbiala después de iniciar sesión.</p>`,
    });
    console.log('Correo enviado correctamente a: ', email);
  } catch (err) {
    console.log('Error enviando a correo: ', err);
    throw err;
  }
}