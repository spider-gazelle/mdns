FROM 84codes/crystal:latest-alpine as build
WORKDIR /app
RUN mkdir -p /app/bin
RUN mkdir -p /app/deps

# Create a non-privileged user, defaults are appuser:10001
ARG IMAGE_UID="10001"
ENV UID=$IMAGE_UID
ENV USER=appuser

# See https://stackoverflow.com/a/55757473/12429735
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    "${USER}"

# Add dependencies commonly required for building crystal applications
# hadolint ignore=DL3018
RUN apk add \
  --update \
  --no-cache \
    git

RUN git clone https://github.com/spider-gazelle/mdns.git
WORKDIR /app/mdns
RUN shards update --ignore-crystal-version --skip-postinstall --skip-executables

# Build application
RUN crystal build ./examples/query_responder.cr --release --error-trace
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
RUN mv ./query_responder ../bin/query_responder

# Extract binary dependencies (uncomment if not compiling a static build)
RUN for binary in /app/bin/*; do \
        ldd "$binary" | \
        tr -s '[:blank:]' '\n' | \
        grep '^/' | \
        xargs -I % sh -c 'mkdir -p $(dirname deps%); cp % deps%;'; \
    done

# Build a minimal docker image
FROM scratch
WORKDIR /
ENV PATH=$PATH:/

# Copy the user information over
COPY --from=build etc/passwd /etc/passwd
COPY --from=build /etc/group /etc/group

# These are required for communicating with external services
COPY --from=build /etc/hosts /etc/hosts

# This is your application
COPY --from=build /app/deps /
COPY --from=build /app/bin /

# Use an unprivileged user.
USER appuser:appuser

# Run the app
ENTRYPOINT ["/query_responder"]
CMD ["/query_responder"]
