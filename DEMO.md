# FitnessCenter · App móvil Flutter

Demo de la app móvil para socios de **FitnessCenter**, una solución de gestión
de gimnasios que construí de punta a punta: app móvil, panel web de
administración y API.

La app móvil es la pieza central y es lo que se muestra aquí.

> **English summary at the end of this page.**

---

## Acceso a la demo

| | |
|---|---|
| **Video (1-2 min)** | `<pendiente: enlace al video>` |
| **APK Android** | `<pendiente: enlace de descarga>` |
| **Correo** | `<pendiente>` |
| **Contraseña** | `<pendiente>` |

La cuenta es de **rol socio**. El entorno es un tenant aislado con datos de
demostración: nada de lo que hagas afecta a otros entornos, y se puede
restablecer a su estado inicial cuando haga falta.

No hay cuenta de administrador para este tenant. El panel web de
administración existe, pero queda fuera de esta demo.

### Qué probar

1. Iniciar sesión con las credenciales de arriba.
2. En **Inicio**, ver el resumen de próximas reservas e historial.
3. Ir a **Directorio** para explorar disciplinas, entrenadores y tipos de clase.
4. Desde **Reservas → Reservar una clase**, revisar la disponibilidad real y
   tomar un cupo.
5. Volver a **Mis reservas**: la reserva aparece en la tabla.
6. Abrir el menú de acciones de la fila y **anular la reserva**.

La app está en español. El catálogo (clases, entrenadores, horarios) también.

---

## Qué hace la app

Cliente móvil para socios de un gimnasio:

- **Directorio** de disciplinas, entrenadores, tipos de clase y planes.
- **Disponibilidad en tiempo real**, filtrable por disciplina, entrenador o
  tipo de clase.
- **Reserva y anulación** de clases, con las reglas de negocio validadas en el
  backend (cupo del plan, estados válidos de una reserva).
- **Mis reservas** con historial y detalle de cada sesión.
- **Perfil** del socio, con foto y datos personales.
- **Notificaciones push** vía Firebase Cloud Messaging.

---

## Arquitectura

### App móvil (Flutter · Dart · Firebase)

**MVVM sobre una arquitectura por funcionalidades.** Cada feature vive en
`lib/features/<feature>` y se divide en `data / domain / presentation`, con su
propio módulo de inyección de dependencias.

Tres herramientas de estado, cada una con un rol acotado:

| Responsabilidad | Herramienta |
|---|---|
| Rutas, localizador de servicios, navegación | GetX |
| Estado de cada feature (MVVM) | `ChangeNotifier` sobre `ViewModelBase` |
| Estado de UI con ciclo de vida propio | Riverpod |

La mayor parte del estado son ViewModels `ChangeNotifier` leídos con
`ListenableBuilder`. Eso mantiene la lógica testeable sin depender de un
framework, y es la razón por la que los flujos de reserva y anulación se
prueban con fakes simples.

Riverpod se usa en un solo lugar: los filtros de disponibilidad, donde
`StateNotifierProvider.autoDispose.family` da a cada instancia de pantalla su
propio estado que se descarta con ella.

Es un compromiso, no una regla: la alternativa era implementar a mano ese
ciclo de vida o migrar toda la app a Riverpod por el beneficio de una pantalla.

### API (FastAPI · PostgreSQL · SQLAlchemy · Firebase Admin)

Backend multi-tenant por capas (`routers → services → repositories`). La
autenticación la verifica Firebase y la autorización la resuelve la base de
datos: el rol nunca se toma del cliente. El aislamiento entre empresas se
aplica en la capa de sesión del ORM, no en cada consulta.

### Panel web (Nuxt · Vue · TypeScript · Tailwind)

Panel para el personal, con vistas según rol. Fuera del alcance de esta demo.

---

## Decisiones que vale la pena mencionar

**El español es el idioma del producto, no una traducción.** La app usa
`flutter_localizations` con catálogos ARB y español por defecto; el inglés
queda como alternativa.

Lo interesante fue que los textos vivían dentro de los ViewModels, que no
tienen locale. `BookingActionResult` devolvía títulos y mensajes ya armados en
inglés. Ahora reporta un `BookingAction` y un `BookingActionOutcome`, y la capa
de widgets los traduce. Los mensajes que vienen del backend pasan sin traducir,
porque el servidor ya responde en el idioma del usuario.

**Las reglas de negocio se prueban, no se asumen.** Los tests cubren el guard
de reentrada que impide que un doble toque genere dos reservas, la máquina de
estados de confirmar/anular, el respaldo local cuando falla el refresco
posterior a una anulación, y la regla que oculta estados administrativos del
selector del socio.

**Accesibilidad verificada en CI.** `accessibility_test.dart` usa los matchers
de Flutter (`androidTapTargetGuideline`, `labeledTapTargetGuideline`,
`textContrastGuideline`). No es decorativo: la primera ejecución encontró que
el botón principal de la lista de reservas tenía un área táctil de 40px, por
debajo del mínimo de 48px de Android.

**El video es un test.** La grabación la produce el mismo
`integration_test` que corre como prueba E2E; con `DEMO_PACING=0` se ejecuta
rápido en CI y con pausas cuando se graba. Así el video no se desincroniza de
la app.

---

## Estado actual y límites

Prefiero ser explícito sobre lo que no está:

- **Android.** El proyecto tiene como objetivo Android hoy. Flutter cubre
  ambas plataformas y la arquitectura no asume nada específico de Android,
  pero no sería honesto afirmar que está probado en iOS: no he compilado ni
  verificado el target de iOS, y hacerlo requiere un equipo macOS.
- **La traducción al español cubre el recorrido de la demo** (inicio de
  sesión, inicio, reservas, navegación, paginación). Quedan en inglés pantallas
  secundarias como el perfil y parte del directorio.
- **Los horarios de la demo se generan en el momento de la siembra**, así que
  un entorno sin uso durante semanas muestra disponibilidad vacía. Hay un
  script que lo restablece.
- La cobertura de tests se concentra en la lógica de reservas y en los
  contratos de datos, no en toda la app.

---

## Repositorios

| Componente | Stack |
|---|---|
| App móvil | Flutter · Dart · Firebase |
| API | FastAPI · Python · PostgreSQL · SQLAlchemy |
| Panel web | Nuxt · Vue · TypeScript · Tailwind |

---

## English summary

Demo of the **FitnessCenter** member mobile app, part of a gym management
suite I built end to end: mobile app, admin web panel and API. The mobile app
is the centrepiece.

**Access:** credentials and the video link are in the table at the top of this
page. The account is **member-role**, in an isolated demo tenant with its own
seeded data. There is no admin account for this tenant.

**What it does:** browse disciplines, trainers and class types; check live
availability; book and cancel classes with the business rules enforced
server-side; review booking history; receive push notifications.

**Architecture:** MVVM over a feature-first structure. `ChangeNotifier`
view-models hold feature state, GetX handles routing and service location, and
Riverpod covers one screen's scoped filter state. The backend is a multi-tenant
FastAPI service where Firebase verifies the token and the database resolves the
role, with tenant isolation applied at the ORM session layer.

**Worth highlighting:** Spanish is the product language rather than a
translation layer, which required moving user-facing copy out of the
view-models into a localized widget layer. Business rules are covered by unit
tests, including the re-entrancy guard against double booking. Accessibility is
asserted in CI with Flutter's own guideline matchers, which caught a real
40px tap target on the primary action. The demo video is produced by the same
`integration_test` that runs as an E2E check, so it cannot drift from the app.

**Limits:** Android today. Flutter targets both platforms and nothing in the
architecture is Android-specific, but the iOS target has not been built or
verified and doing so needs a macOS machine. The Spanish migration covers the
demo path; some secondary screens are still English.
