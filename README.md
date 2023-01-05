# Practicas_en_empresa

En este repositorio se encuentra el workflow para la homogeneización de datos que he adaptado del trabajo de Lenters et al., 2021 (DOI: 10.1016/J.ECOINF.2020.101206).


## Funcionamiento
1. Adjudicar el nombre para el rasgo (trait)
2. Rellenar el formulario con el nombre individual EXACTO del trait en cada archivo a homogeneizar
3. Indicar las unidades de medida de cada rasgo
4. Pasar a la hoja "output" del formulario.xlsx y copiar la columna **metadata** al archivo metadatos.xlsx y la columna **units** al archivo unidades.xlsx
5. En el encabezado de los archivos excel, indicar el nombre de los respectivos archivos de datos de origen
6. Ejecutar el *workflow*


## Notas
- *En caso que se hayan cambiado los nombres de los traits en el **paso 1**, será necesario cambiar tambien la columna **names** de los archivos excel metadatos y unidades. Tener en cuenta también que será necesario indicar si se tratan o no de "traits" y si son "numeric" o "character" en el archivo metadatos*.
- *Los pasos 2-4 se tiene que repetir tantas veces como la cantidad de archivos a homogeneizar. Sin embargo, sólo deben resultar un único archivo metadatos.xlsx y un único archivo unidades.xlsx*.
