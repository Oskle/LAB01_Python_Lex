
# LABORATORIO 1 — Análisis Léxico (Lex/Flex + C)

Este paquete implementa el analizador léxico solicitado para un **subconjunto de Python** siguiendo el enunciado del laboratorio.

## 📦 Contenido
- `lexer.l` — Especificación **Flex** con todas las reglas de tokens.
- `Makefile` — Compilación rápida en Ubuntu (Flex + GCC).
- `samples/entrada.py` — Programa de ejemplo (del enunciado) para probar.
- `samples/salida_esperada.txt` — Salida de referencia aproximada.
- `USO.md` — Manual de instalación, compilación y ejecución (puedes exportarlo a PDF).

## ✅ Cobertura de tokens
- **Palabras reservadas** (en mayúscula al imprimir): `and, else, is, return, break, for, not, while, continue, if, or, def, import, pass, elif, in, print`.
- **Operadores**: `+ - * ** / // % << >> & | ^ ~ < > <= >= == != <>` y **asignaciones compuestas** `= ; , : . >>= <<= += -= *= /= //= &= |= ^= **= %=`.
- **Identificadores**: `[A-Za-z_][A-Za-z0-9_]*` con **enumeración estable** `idN=nombre` y **resumen final**.
- **Números**: enteros (con signo opcional), `long` (`L/l`), decimales (incl. exponencial), e **imaginarios** sufijados con `j/J`.
- **Strings**: `'...'` o `"..."` (no cruzan salto de línea).
- **Comentarios**: `#` hasta fin de línea (**ignorados**).
- **Errores léxicos**: token no reconocido → `ERROR=<lexema>`. Se **continúa** el análisis y se reporta el total al final.

## 🛠️ Requisitos (Ubuntu)
```bash
sudo apt-get update
sudo apt-get install -y flex build-essential
```

## 🧱 Compilación
```bash
make
```
Genera el ejecutable `./lab01_lex`.

## ▶️ Ejecución
```bash
./lab01_lex samples/entrada.py > salida.txt
```
La salida incluye:
- Código de entrada con tokens anotados.
- **Listado de identificadores** (conteo + `IdN=nombre`).
- **Conteo de errores** léxicos.

> Nota: Los rótulos de salida siguen el estilo del ejemplo del enunciado (p.ej., `parabre=(`, `parcierr=)`, `dospunt=:`). Puedes ajustar etiquetas impresas en `lexer.l` si tu profesor exige coincidencia 1:1 con el ejemplo.

## 🔎 Diferencias respecto al ejemplo de salida
- Para el operador `=` se imprime `asign==` (puedes cambiar a `asig= =` editando la acción asociada a `ASSIGN`).
- Para operadores simples se imprimen etiquetas compactas (`suma=+`, `menos=-`, `mult=*`, etc.).
- El **formato exacto** puede personalizarse fácilmente buscando las acciones `printf(...)` en `lexer.l`.

## 📄 Conversión del manual a PDF
El manual `USO.md` está listo para exportar a PDF con cualquier editor Markdown (VSCode, Typora, Obsidian) o con Pandoc:
```bash
pandoc USO.md -o MANUAL.pdf
```

---

> Trabajo basado en el enunciado del laboratorio provisto por el docente.
