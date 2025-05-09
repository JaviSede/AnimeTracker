# AnimeTracker

AnimeTracker es una aplicación iOS diseñada para ayudar a los usuarios a realizar un seguimiento de las series de anime que están viendo, han visto o planean ver. Permite a los usuarios gestionar su biblioteca personal de anime, descubrir nuevas series y mantener un registro de su progreso.

## Características Principales

*   **Gestión de Biblioteca Personal**: Los usuarios pueden añadir animes a diferentes listas (viendo, completado, en espera, abandonado).
*   **Seguimiento de Progreso**: Permite marcar episodios vistos y llevar un control del avance en cada serie.
*   **Descubrimiento de Anime**: (Funcionalidad futura) Integración con APIs de bases de datos de anime para buscar y añadir nuevas series.
*   **Autenticación Segura**: Sistema de registro e inicio de sesión de usuarios con almacenamiento seguro de credenciales utilizando Keychain.
*   **Perfil de Usuario**: Cada usuario tiene un perfil donde puede ver sus estadísticas y gestionar su información.
*   **Interfaz Intuitiva**: Diseño de interfaz de usuario amigable y fácil de navegar, desarrollada con SwiftUI.

## Requisitos Técnicos

*   **Plataforma**: iOS
*   **Lenguaje**: Swift
*   **UI Framework**: SwiftUI
*   **Persistencia de Datos**: SwiftData para la base de datos local.
*   **Autenticación**: Gestión de sesión de usuario mediante Keychain para mayor seguridad.
*   **Dependencias**: CryptoKit (para hashing de contraseñas).

## Estructura del Proyecto

El proyecto sigue una estructura organizada para facilitar el desarrollo y mantenimiento:

```
AnimeTracker/
├── AnimeTrackerApp.swift       # Punto de entrada de la aplicación
├── Assets.xcassets/          # Recursos gráficos (iconos, imágenes)
├── ContentView.swift           # Vista principal inicial
├── Diagramas/                  # Diagramas UML (clases, flujo, etc.)
├── Preview Content/            # Recursos para previews de SwiftUI
├── model/                      # Modelos de datos (SwiftData entities, structs)
│   ├── AnimeStats.swift
│   ├── AnimeStatus.swift
│   ├── StreamingService.swift
│   ├── User.swift
│   ├── UserLibrary.swift
│   └── UserModel.swift         # Modelo de usuario para SwiftData
├── service/                    # Lógica de negocio y servicios
│   ├── AnimeService.swift      # Servicio para la gestión de animes
│   ├── AuthService.swift       # Servicio de autenticación (ObservableObject)
│   └── auth/                   # Componentes específicos de autenticación
│       ├── AuthRepository.swift # Repositorio para operaciones de autenticación
│       ├── AuthValidator.swift  # Validadores para datos de entrada
│       ├── KeychainManager.swift# Gestor para interactuar con Keychain
│       └── Validator.swift      # Protocolo base para validadores
└── view/                       # Vistas de la interfaz de usuario (SwiftUI)
    ├── AnimeDetailView.swift
    ├── AnimeStatusSelectionView.swift
    ├── EditProfileView.swift
    ├── HomeView.swift
    ├── LibraryView.swift
    ├── MainTabView.swift       # Vista principal con pestañas
    ├── ProfileView.swift
    ├── SearchView.swift
    ├── SettingsView.swift
    └── auth/                   # Vistas de autenticación
        ├── LoginView.swift
        └── RegisterView.swift
```

## Instalación y Ejecución

1.  **Clonar el Repositorio**:
    ```bash
    git clone https://github.com/tu-usuario/AnimeTracker.git
    cd AnimeTracker
    ```
2.  **Abrir en Xcode**:
    Abre el archivo `AnimeTracker.xcodeproj` o el workspace si existe.
3.  **Configurar el Entorno**:
    *   Asegúrate de tener Xcode actualizado y configurado para desarrollo iOS.
    *   Selecciona un simulador de iOS o un dispositivo físico conectado.
4.  **Ejecutar la Aplicación**:
    Presiona el botón de "Play" (Build and Run) en Xcode.

## Sistema de Autenticación y Seguridad

La aplicación implementa un sistema de registro e inicio de sesión para los usuarios. Las contraseñas se almacenan hasheadas utilizando SHA256 con salt para mayor seguridad. La gestión de la sesión del usuario (ID de usuario) se realiza a través de **Keychain**, lo que proporciona un almacenamiento seguro y persistente para esta información sensible, en lugar de utilizar `UserDefaults`.

El archivo `KeychainManager.swift` encapsula la lógica para guardar, obtener, actualizar y eliminar datos de Keychain. `AuthRepository.swift` utiliza este gestor para manejar el ID del usuario durante el login, registro y cierre de sesión.

## Contribuciones

Las contribuciones son bienvenidas. Si deseas contribuir al proyecto, por favor:

1.  Haz un fork del repositorio.
2.  Crea una nueva rama para tu feature (`git checkout -b feature/nueva-funcionalidad`).
3.  Realiza tus cambios y haz commit (`git commit -am 'Añade nueva funcionalidad'`).
4.  Sube tus cambios a la rama (`git push origin feature/nueva-funcionalidad`).
5.  Abre un Pull Request.
