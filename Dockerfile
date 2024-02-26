# Use a imagem base do OpenJDK 17 para compilar o projeto
FROM openjdk:17 as builder

# Defina o diretório de trabalho como /app
WORKDIR /app

# Copie os arquivos de configuração do projeto Maven
COPY pom.xml .
COPY src src

# Compile o projeto e gere o arquivo JAR
RUN ./mvnw package -DskipTests

FROM openjdk:17

# Defina o diretório de trabalho como /app
WORKDIR /app

# Copie o arquivo JAR gerado durante a fase de compilação
COPY --from=builder /app/target/api-0.0.1-SNAPSHOT.jar app.jar

# Exponha a porta em que a aplicação está sendo executada
EXPOSE 8080

# Comando para executar a aplicação quando o contêiner for iniciado
CMD ["java", "-jar", "app.jar"]
