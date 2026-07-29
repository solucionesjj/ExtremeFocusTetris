# Publicar la política de privacidad en GitHub Pages

El archivo ya está listo en `docs/privacy.html`. Pasos para publicarlo (los
tienes que hacer tú, ya que implican hacer push y cambiar configuración del
repositorio en GitHub):

1. **Commit y push** de la carpeta `docs/` a la rama `main`:
   ```bash
   git add docs/privacy.html
   git commit -m "Add privacy policy page for Google Play"
   git push origin main
   ```

2. En GitHub, entra al repo `solucionesjj/ExtremeFocusTetris` → **Settings**
   → **Pages** (menú lateral izquierdo, sección "Code and automation").

3. En **Build and deployment → Source**, elige **Deploy from a branch**.

4. En **Branch**, selecciona `main` y la carpeta `/docs`, luego **Save**.

5. Espera 1-2 minutos. GitHub mostrará la URL publicada, que será:
   ```
   https://solucionesjj.github.io/ExtremeFocusTetris/privacy.html
   ```

6. Verifica que la URL cargue correctamente desde el navegador (y desde el
   celular, para confirmar que se ve bien en pantallas pequeñas).

7. Usa esa URL exacta en Play Console, en:
   - **Configuración de la app → Contenido de la app → Política de privacidad**
   - Y en la ficha de la app (**App content → Privacy policy**) si Play Console
     la pide en un segundo lugar (a veces aparece duplicada en el flujo).

Nota: si en el futuro cambias `docs/privacy.html`, basta con hacer commit y
push de nuevo — no hace falta repetir la configuración de Pages.
