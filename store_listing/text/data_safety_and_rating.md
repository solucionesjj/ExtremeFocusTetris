# Referencia: Data Safety y clasificación de contenido (Play Console)

Estas son las respuestas correctas a marcar en Play Console, según el
comportamiento real de la app (confirmado en el código: `AndroidManifest.xml`
no declara el permiso `INTERNET`, no hay ningún SDK de red, analítica,
publicidad ni backend — ver `CLAUDE.md` / `AGENT.md`, restricciones no
negociables).

---

## 1. Data Safety ("Seguridad de los datos")

**Play Console → tu app → Política y programas → Seguridad de los datos**

### Paso "¿Recopila o comparte tu app alguno de los tipos de datos de usuario requeridos?"

- **Respuesta: No.**

Al responder "No" aquí, Play Console salta automáticamente todas las
subpreguntas de categorías de datos (ubicación, información personal,
mensajes, fotos, etc.) — no hay que marcar nada en esas secciones porque
la app no recolecta ningún dato.

### Paso "¿Tu app tiene una política de privacidad?"

- **Respuesta: Sí.**
- URL: `https://solucionesjj.github.io/ExtremeFocusTetris/privacy.html`
  (una vez publicada — ver `github_pages_setup.md`).

### Paso "Prácticas de seguridad" (encriptación en tránsito, eliminación de datos)

- Como no se recolecta ni transmite ningún dato, estas preguntas quedan
  fuera de alcance (Play Console no las muestra si ya respondiste "No"
  en el primer paso).

### Resultado esperado

La ficha de la app mostrará el sello **"No se comparten datos con
terceros"** / **"No collects data"** en la sección de seguridad de datos.

---

## 2. Clasificación de contenido (cuestionario IARC)

**Play Console → tu app → Política y programas → Clasificación de contenido**

### Categoría de la app

- **Utilidad / Juego** → elegir **"Juego"** (Game), sub-categoría **Puzzle**.

### Cuestionario IARC — respuestas

| Pregunta | Respuesta |
|---|---|
| Violencia | Ninguna |
| Sangre | Ninguna |
| Contenido sexual / desnudos | Ninguno |
| Lenguaje soez / groserías | Ninguno |
| Referencias a drogas, alcohol o tabaco | Ninguna |
| Juego de azar simulado / apuestas | No |
| Contenido generado por el usuario (chat, imágenes, etc.) | No |
| Comparte la ubicación del usuario | No |
| Comparte información personal con terceros | No |
| Compras digitales dentro de la app | No |
| Acceso a internet sin restricciones | No |

### Resultado esperado

Con estas respuestas, el cuestionario debería asignar automáticamente la
clasificación más baja en todos los sistemas:

- **IARC genérico:** 3+
- **ESRB (EE. UU.):** Everyone
- **PEGI (Europa):** PEGI 3
- **USK (Alemania):** 0
- **Otros sistemas regionales:** equivalente "para todo público"

---

## Notas

- Estas respuestas solo son válidas mientras la app siga sin red, sin
  cuentas, sin anuncios y sin compras — si en el futuro se agrega
  cualquiera de esas capacidades, hay que volver a completar ambos
  formularios reflejando el nuevo comportamiento.
- Google puede reformular ligeramente el texto de las preguntas entre
  versiones de Play Console; el criterio de respuesta (honesto, "no" a
  todo salvo lo indicado) se mantiene igual.
