🎌 AnimeTracker · Tu compañero para seguir tus animes favoritos
AnimeTracker es una aplicación iOS desarrollada en Swift que permite a los fanáticos del anime llevar un control completo de sus series: qué están viendo, qué han terminado, y qué quieren ver más adelante. Con una interfaz moderna y funcionalidades pensadas para la comunidad otaku, AnimeTracker hace que seguir tu progreso nunca haya sido tan fácil (¡ni tan estético!).

[![Plataforma](https://img.shields.io/badge/Plataforma-iOS-blue)]()
[![Lenguaje](https://img.shields.io/badge/Swift-5.9-orange)]()
[![UI](https://img.shields.io/badge/SwiftUI-%F0%9F%93%BA-green)]()
[![Persistencia](https://img.shields.io/badge/SwiftData-%F0%9F%92%BE-yellow)]()
[![Seguridad](https://img.shields.io/badge/Keychain%20%2B%20CryptoKit-%F0%9F%94%91-lightgrey)]()
[![Arquitectura](https://img.shields.io/badge/MVVM-%F0%9F%92%A1-blueviolet)]()
[![Licencia](https://img.shields.io/badge/Licencia-MIT-brightgreen)]()
[![Estado](https://img.shields.io/badge/Estado-En%20Desarrollo%20%F0%9F%9A%A7-red)]()

✨ Características Destacadas
📚 Gestión de Biblioteca Personal
Organiza tus animes en listas personalizadas: Viendo, Completado, En espera o Abandonado.

📺 Seguimiento de Episodios
Marca episodios vistos y sigue tu avance con estadísticas claras y motivadoras.

🔍 Exploración de Nuevos Animes (Próximamente)
Futura integración con APIs de anime para descubrir nuevas series directamente desde la app.

🔐 Autenticación Segura
Inicio de sesión y registro protegidos por Keychain y almacenamiento seguro de credenciales.

👤 Perfil de Usuario Personalizado
Visualiza tu progreso, edita tu información y gestiona tu biblioteca desde un solo lugar.

🧭 Interfaz Intuitiva y Moderna
Diseñada con SwiftUI para ofrecer una experiencia visual fluida y minimalista.

🛠️ Tecnologías Utilizadas
Categoría	Tecnología
Plataforma	iOS
Lenguaje	Swift
UI Framework	SwiftUI
Persistencia	SwiftData
Seguridad	Keychain, CryptoKit
Arquitectura	MVVM + Servicios

📂 Estructura del Proyecto
plaintext
Copiar
Editar
AnimeTracker/
├── AnimeTrackerApp.swift        # Punto de entrada
├── Assets.xcassets/             # Recursos gráficos
├── ContentView.swift            # Vista principal
├── Diagramas/                   # Diagramas UML
├── model/                       # Modelos de datos
├── service/                     # Lógica de negocio
│   └── auth/                    # Módulo de autenticación
└── view/                        # Vistas SwiftUI
    └── auth/                    # Vistas de login/registro
🚀 Cómo Ejecutar el Proyecto
Clona este repositorio:

bash
Copiar
Editar
git clone https://github.com/tu-usuario/AnimeTracker.git
cd AnimeTracker
Abre el proyecto en Xcode
Ejecuta AnimeTracker.xcodeproj o el workspace si usas paquetes.

Configura tu entorno

Verifica que Xcode esté actualizado.

Usa un simulador iOS o dispositivo físico.

Ejecuta la app
Haz clic en ▶️ Build and Run para ver AnimeTracker en acción.

🔐 Seguridad y Autenticación
La app protege la información del usuario mediante:

Hashing de contraseñas con CryptoKit (SHA256 + salt).

Almacenamiento seguro de credenciales mediante Keychain.

Gestión de sesión y autenticación desacoplada a través de AuthService y AuthRepository.

Toda la lógica relacionada se encuentra en la carpeta service/auth/, destacando el archivo KeychainManager.swift.

🤝 Contribuciones
¡Las contribuciones son bienvenidas! Si quieres aportar:

Haz un fork del proyecto.

Crea una nueva rama:

bash
Copiar
Editar
git checkout -b feature/mi-nueva-funcionalidad
Realiza tus cambios y haz commit:

bash
Copiar
Editar
git commit -m "Agrega nueva funcionalidad"
Haz push de tu rama:

bash
Copiar
Editar
git push origin feature/mi-nueva-funcionalidad
Abre un Pull Request explicando tus cambios.

🧡 ¿Te gusta el proyecto?
No olvides dejar una ⭐ en el repositorio si te parece útil o interesante. ¡Gracias por tu apoyo!
