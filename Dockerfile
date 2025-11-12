# Build stage
FROM golang:1.25-alpine AS builder

# Install build dependencies
RUN apk add --no-cache git make gcc musl-dev

# Set working directory
WORKDIR /build

# Clone the repository
RUN git clone https://github.com/pdf/zfs_exporter.git .

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
