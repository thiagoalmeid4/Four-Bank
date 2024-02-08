# Use a imagem base do OpenJDK 17
FROM openjdk:17

# Defina o diretório de trabalho como /app
WORKDIR /app

# Copie o arquivo JAR da sua aplicação para o contêiner
COPY dist/api-0.0.1-SNAPSHOT.jar app.jar

# Exponha a porta em que a aplicação está sendo executada
EXPOSE 8080

# Comando para executar a aplicação quando o contêiner for iniciado
CMD ["java", "-jar", "app.jar"]
