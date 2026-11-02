# Two stages: a big image with the JDK builds the jar, a small image with only the JRE runs it.
# The final image holds no source code, no Maven and no compiler.

# ---- Stage 1: build ----
FROM eclipse-temurin:25-jdk-noble AS build
WORKDIR /app

# Copy only the build files first and download dependencies. Docker caches each step,
# so this slow download re-runs only when pom.xml changes, not on every code change.
COPY mvnw pom.xml ./
COPY .mvn .mvn
RUN chmod +x mvnw && ./mvnw -B -q dependency:go-offline

COPY src src
# Tests need a PostgreSQL database, which the build machine does not have.
# They run on Praveen's machine before every push instead.
RUN ./mvnw -B -q package -DskipTests

# ---- Stage 2: run ----
FROM eclipse-temurin:25-jre-noble
WORKDIR /app

# Run as an ordinary user, not root: a bug in the app then cannot change the container's system files.
RUN useradd --system --no-create-home spring
USER spring

COPY --from=build /app/target/portfolio-backend-*.jar app.jar

# The host sets PORT and the DB_* variables at run time; nothing secret is baked into the image.
# MaxRAMPercentage: let the Java heap use 75% of the container's memory (the JVM default is 25%,
# too little on a small free-tier instance).
ENTRYPOINT ["java", "-XX:MaxRAMPercentage=75", "-jar", "app.jar"]
