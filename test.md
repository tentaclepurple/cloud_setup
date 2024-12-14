# Mi Página con Panel Lateral y Posts

Este proyecto es una página web sencilla con un diseño que incluye:

1. Un **panel lateral** con una lista de navegación.
2. Un **cuerpo principal** donde se muestran publicaciones tipo blog.

## 📚 Características
- **Panel lateral**: Ideal para categorías, enlaces rápidos o índices.
- **Cuerpo principal**: Muestra publicaciones con títulos, fechas y contenido breve.
- Diseño responsive utilizando HTML y CSS.

## 🎨 Vista previa
Aquí tienes una captura de cómo se ve la página:

<div align="center">
    <img src="https://via.placeholder.com/600x400" alt="Vista previa de la página">
</div>

## 💻 Estructura del diseño
```html
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Página con Panel Lateral</title>
    <style>
        body {
            display: flex;
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
        }
        .side-panel {
            width: 25%;
            background-color: #f4f4f4;
            padding: 20px;
            border-right: 1px solid #ddd;
        }
        .side-panel ul {
            list-style-type: none;
            padding: 0;
        }
        .side-panel li {
            margin: 10px 0;
        }
        .main-content {
            flex: 1;
            padding: 20px;
        }
        .post {
            border-bottom: 1px solid #ddd;
            padding: 10px 0;
        }
        .post h2 {
            margin: 0 0 10px 0;
        }
        .post p {
            color: #555;
        }
    </style>
</head>
<body>
    <div class="side-panel">
        <h3>Categorías</h3>
        <ul>
            <li><a href="#">Tecnología</a></li>
            <li><a href="#">Ciencia</a></li>
            <li><a href="#">Arte</a></li>
        </ul>
    </div>
    <div class="main-content">
        <div class="post">
            <h2>Título del Post 1</h2>
            <p><small>Publicado el 12 de diciembre de 2024</small></p>
            <p>Este es un breve resumen del contenido del post.</p>
        </div>
        <div class="post">
            <h2>Título del Post 2</h2>
            <p><small>Publicado el 10 de diciembre de 2024</small></p>
            <p>Este es otro resumen con contenido relevante.</p>
        </div>
    </div>
</body>
</html>
