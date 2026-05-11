# Build stage
FROM golang:1.25-alpine AS builder

# version comes form https://github.com/pdf/zfs_exporter.git
ARG ZFS_EXPORTER_VERSION=2.3.12

# Install build dependencies
RUN apk add --no-cache git make gcc musl-dev

# Set working directory
WORKDIR /build

# Clone the repository
RUN if [ "$ZFS_EXPORTER_VERSION" = "latest" ]; then \
      git clone https://github.com/pdf/zfs_exporter.git .; \
    else \
      git clone --branch v${ZFS_EXPORTER_VERSION} --depth 1 https://github.com/pdf/zfs_exporter.git .; \
    fi

# Download dependencies
# RUN go mod download

# Build the binary
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o zfs_exporter .

# Final stage
FROM alpine:latest

# Install ZFS utilities (required for the exporter to work)
RUN apk add --no-cache zfs

# Copy the binary from builder
COPY --from=builder /build/zfs_exporter /usr/local/bin/zfs_exporter

# Make it executable
RUN chmod +x /usr/local/bin/zfs_exporter

# Expose the default metrics port
EXPOSE 9134

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/zfs_exporter"]
