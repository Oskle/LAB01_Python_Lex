
# Manual de instalación, compilación y ejecución

## Instalación (Ubuntu 20.04+)
1. Actualiza índices:
   ```bash
   sudo apt-get update
   ```
2. Instala **Flex** y **GCC**:
   ```bash
   sudo apt-get install -y flex build-essential
   ```

## Compilación
En la carpeta del proyecto:
```bash
make
```
Esto:
- Corre Flex sobre `lexer.l` → genera `lexer.c`.
- Compila `lexer.c` con GCC y enlaza `-lfl` → produce `lab01_lex`.

## Ejecución
```bash
./lab01_lex ruta/al/archivo.py > salida.txt
```
- Los **comentarios** se ignoran.
- Las **palabras reservadas** salen **en mayúscula**.
- Los **identificadores** aparecen como `idN=nombre` y se listan al final con su conteo.
- Los **números** se clasifican en `entero`, `real`, `long`, `imaginario`.
- Los **delimitadores** y **operadores** se imprimen con etiquetas (`parabre=(`, `dospunt=:`, `suma=+`, etc.).
- Cualquier **token no soportado** se reporta como `ERROR=<lexema>` y se continúa el análisis.

## Pruebas rápidas
```bash
./lab01_lex samples/entrada.py
```

## Personalización de etiquetas
Abre `lexer.l` y ajusta los `printf(...)`. Ejemplos:
- Cambiar `asign==` por `asig= =`:
  ```c
  {ASSIGN} { printf("asig= = "); }
  ```
- Cambiar `mult=*` por `*`:
  ```c
  {STAR} { printf("* "); }
  ```

## Estructura del proyecto
```
.
├── lexer.l
├── Makefile
├── USO.md
└── samples
    ├── entrada.py
    └── salida_esperada.txt
```

## Notas didácticas
- El analizador es **léxico**: no valida **estructuras** de alto nivel (no es error léxico si falla la gramática).
- La opción `%option case-insensitive` permite reconocer palabras clave sin depender de mayúsculas/minúsculas en la entrada.
- Las reglas para números priorizan **imaginarios**, luego `long`, luego `reales`, luego `enteros` para **greedy matching** correcto.
- Las **asignaciones compuestas** y operadores de múltiples caracteres se listan **antes** que operadores simples (máxima masticación).

¡Éxitos!
