FROM 84codes/crystal:latest-alpine as build
WORKDIR /app
RUN mkdir -p /app/bin

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
WORKDIR /app
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

# These are required for communicating with external services
COPY --from=build /etc/hosts /etc/hosts

# This is your application
COPY --from=build /app/deps /
COPY --from=build /app/bin /

# Run the app
ENTRYPOINT ["/query_responder"]
CMD ["/query_responder"]
