# Step 1: Build Stage (MIA Nervous System - Signal Gateway)
FROM registry.access.redhat.com/ubi8/go-toolset:latest AS builder
WORKDIR /opt/app-root/src
COPY . .
RUN go build -o signal-gateway ./cmd/main.go

# Step 2: Hardened Runtime Stage
# Using RHEL 8 Universal Base Image (UBI) - Iron Bank Style
FROM registry.access.redhat.com/ubi8/ubi-minimal:latest

LABEL maintainer="Alf Baez <alf@urimagination.com>" \
      compliance="NIST-800-53-Rev5" \
      stig_version="RHEL-8-STIG-V1R10"

# STIG Requirement: Update all packages and remove package manager to reduce surface area
RUN microdnf update -y && \
    microdnf clean all && \
    rm -rf /var/cache/yum

# STIG Requirement: Create a non-privileged user (V-230239)
# Containers must NOT run as root in a cArmy/ECMA environment
RUN echo "mia-user:x:10001:10001:MIA App User:/home/mia-user:/sbin/nologin" >> /etc/passwd && \
    echo "mia-group:x:10001:" >> /etc/group && \
    mkdir -p /app && \
    chown -R 10001:10001 /app

# STIG Requirement: Enforce strict file permissions (V-230240)
COPY --from=builder --chown=10001:10001 /opt/app-root/src/signal-gateway /app/signal-gateway
RUN chmod 500 /app/signal-gateway

# Set environment for the "Nervous System"
ENV PATH="/app:${PATH}"
USER 10001
WORKDIR /app

# STIG Requirement: Remove shells or sensitive binaries if not needed
# (Optional: depends on if you need microdnf for runtime sidecars)

ENTRYPOINT ["/app/signal-gateway"]
