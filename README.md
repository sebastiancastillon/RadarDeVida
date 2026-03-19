# 🩸 Radar de Vida
> **Sistema inteligente de gestión y registro de donantes de sangre en tiempo real.**

![Vercel Deployment](https://img.shields.io/badge/Vercel-000000?style=for-the-badge&logo=vercel&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![JavaScript](https://img.shields.io/badge/JavaScript-F7DF1E?style=for-the-badge&logo=javascript&logoColor=black)

---

## 📱 Sobre el Proyecto
**Radar de Vida** es una plataforma diseñada para conectar donantes de sangre con centros de salud de manera inmediata. El sistema consta de una aplicación móvil para el registro en sitio y un panel administrativo web para el control de la flotilla de donantes.

### 🔑 Funciones Clave
* **Registro Biométrico:** Los donantes suben una selfie y sus datos básicos desde la App.
* **Panel de Control Dark Mode:** Interfaz administrativa de alto rendimiento para visualización de datos.
* **Arquitectura Serverless:** Backend escalable que no requiere mantenimiento de servidores físicos.
* **Gestión de Registros:** Capacidad de actualizar y eliminar registros en tiempo real.

---

## 🛠️ Stack Tecnológico

| Componente | Tecnología |
| :--- | :--- |
| **App Móvil** | Flutter (Dart) |
| **Backend** | Vercel Edge Functions (Node.js) |
| **Frontend Web** | HTML5 / CSS3 / JavaScript Moderno |
| **Infraestructura** | Vercel Cloud |

---
---

## 📸 Screenshots del Sistema

A continuación se muestra el flujo de la plataforma, desde la aplicación móvil hasta el panel de control administrativo web.

<table width="100%">
  <tr>
    <td width="50%" align="center">
      <h3>📱 App Móvil: Inicio</h3>
      <img src="/screenshots/app_inicio.jpeg" alt="App de Inicio de Radar de Vida" width="90%" style="border-radius:12px;">
      <p><i>Pantalla de bienvenida para donantes.</i></p>
    </td>
    <td width="50%" align="center">
      <h3>📱 App Móvil: Registro</h3>
      <img src="/screenshots/app_registro.jpeg" alt="App de Registro de Donantes" width="90%" style="border-radius:12px;">
      <p><i>Formulario con captura de selfie biométrica.</i></p>
    </td>
  </tr>
  <tr>
    <td width="50%" align="center">
      <h3>🗺️ Mapa de Donantes</h3>
      <img src="/screenshots/app_mapa.jpeg" alt="Mapa de Donantes en Colima" width="90%" style="border-radius:12px;">
      <p><i>Ubicación en tiempo real de la flotilla disponible.</i></p>
    </td>
    <td width="50%" align="center">
      <h3>🖥️ Web: Panel de Administración</h3>
      <img src="/screenshots/web_admin.jpeg" alt="Panel de Administrador Web de Vercel" width="90%" style="border-radius:12px;">
      <p><i>Control total con Dark Mode profesional.</i></p>
    </td>
  </tr>
</table>

---

## 📂 Estructura del Repositorio

```text
├── api/                # Backend: Funciones Serverless en Node.js
├── public/             # Frontend: Panel de administración web
├── lib/                # Móvil: Código fuente de la App en Flutter
├── vercel.json         # Configuración de CORS y Rutas
└── README.md           # Documentación


