import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

# Cargar dataset exportado desde MySQL
df = pd.read_csv(
    r'c:\Users\herre\OneDrive\Desktop\Proyectos DATA\Delitos de odio\analisis_politico_delitos_odio.csv',
    sep=';',
    header=None,
    na_values='\\N'
)

# Nombrar columnas
df.columns = [
    "año",
    "delitos_odio",
    "delitos_totales",
    "peso_delitos_odio_pct",
    "partido",
    "porcentaje_voto"
]

# Mostrar primeras filas
print(df.head())

# Eliminar filas con valores nulos (ej: año 2014 sin datos electorales)
df = df.dropna()

# Convertir columnas a formato numérico
df["porcentaje_voto"] = df["porcentaje_voto"].astype(float)
df["peso_delitos_odio_pct"] = df["peso_delitos_odio_pct"].astype(float)

# Calcular correlación
corr = df["porcentaje_voto"].corr(df["peso_delitos_odio_pct"])

print("Correlación entre voto y peso de delitos de odio:", corr)

# Crear gráfico de regresión
plt.figure(figsize=(8,5))

sns.regplot(
    data=df,
    x="porcentaje_voto",
    y="peso_delitos_odio_pct"
)

plt.title("Relación entre apoyo electoral y peso de delitos de odio")
plt.xlabel("Porcentaje de voto")
plt.ylabel("Peso de delitos de odio (%)")

# Guardar imagen para el repositorio
plt.savefig("regresion_delitos_voto.png", dpi=300)

# Mostrar gráfico
plt.show()