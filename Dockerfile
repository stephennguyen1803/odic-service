# Stage 1: Build the Go app with static linking
FROM golang:1.21.5 as builder

# Install necessary packages for building the app with ODBC support
RUN apt-get update && apt-get install -y --no-install-recommends unixodbc-dev

# Set working directory
WORKDIR /app

# Copy Go module files and download dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy the source code (assuming your main is in cmd/cli/)
COPY cmd/cli ./cmd/cli

# Build the Go application statically (no glibc dependencies)
RUN go build -o /app/main ./cmd/cli

# Stage 2: Set up the runtime environment
FROM debian:bookworm-slim

# Install ODBC and PostgreSQL ODBC driver
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    unixodbc-dev \
    unixodbc \
    odbcinst \
    vim \
    odbc-postgresql && \
    rm -rf /var/lib/apt/lists/*

# Set up ODBC DSN configuration for PostgreSQL
RUN echo "[POSTGRESDS]\nDriver = /usr/lib/x86_64-linux-gnu/odbc/psqlodbcw.so \nServername = 172.17.0.1\nPort = 5432\nDatabase = postgresDB\n" > /etc/odbc.ini

# Copy the statically built Go binary from the builder stage
COPY --from=builder /app/main /app/main

# Set the binary as the entry point
ENTRYPOINT [ "/app/main", "-dsn=POSTGRESDS", "-dbtype=postgres", "-user=admin","-password=admin" ]
# CMD ["/bin/bash"]