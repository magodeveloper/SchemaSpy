docker pull schemaspy/schemaspy:latest

docker run --rm ^
-v "C:\SchemaSpy\output:/output" ^
-v "C:\SchemaSpy\drivers:/drivers" ^
-v "C:\SchemaSpy\config:/config" ^
schemaspy/schemaspy:latest ^
-t mssql17 ^
-host host.docker.internal ^
-port 1433 ^
-db zkbiotime ^
-u sa ^
-p Y0urs3cretSqL7& ^
-s dbo ^
-connprops /config/connprops.properties

# Notas
# - El entrypoint ya monta /output y /drivers por defecto (no pasar -o ni -dp)
# - Tipo correcto para SQL Server 2017+: mssql17
# - connprops.properties contiene: trustServerCertificate=true
