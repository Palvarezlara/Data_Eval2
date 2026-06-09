# ============================================================
# Imagen de Base de Datos — MySQL 8.0
# No se aplica multi-stage porque MySQL no tiene etapa de build;
# se extiende la imagen oficial y se agrega solo la configuración.
#
# Build: docker build -t proyecto_db:1.0 .
# ============================================================
FROM mysql:8.0

# Metadatos
LABEL maintainer="Innovatech Chile"
LABEL description="Base de Datos MySQL 8.0 - proyecto_db"
LABEL version="1.0"

# Variables de entorno por defecto (sobreescribir en docker-compose o en runtime)
ENV MYSQL_DATABASE=proyecto_db
ENV MYSQL_ROOT_PASSWORD=root_password_change_me
ENV MYSQL_USER=app_user
ENV MYSQL_PASSWORD=app_password_change_me

# Copiar scripts SQL de inicialización.
# MySQL ejecuta automáticamente todos los archivos .sql y .sh
# que se encuentren en /docker-entrypoint-initdb.d/ al primer arranque.
COPY 01_creacion_base_datos.sql /docker-entrypoint-initdb.d/01_init.sql

# Configuración de MySQL: permitir conexiones desde cualquier IP
# y establecer el charset correcto
RUN echo "[mysqld]\n\
bind-address = 0.0.0.0\n\
character-set-server = utf8mb4\n\
collation-server = utf8mb4_unicode_ci\n\
default-authentication-plugin = mysql_native_password" \
    > /etc/mysql/conf.d/custom.cnf

# Puerto estándar de MySQL
EXPOSE 3306

# Healthcheck — verifica que MySQL esté listo para aceptar conexiones
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=5 \
  CMD mysqladmin ping -h localhost -u root -p"${MYSQL_ROOT_PASSWORD}" --silent || exit 1
