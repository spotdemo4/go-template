FROM gcr.io/distroless/static
ARG TARGETPLATFORM
ENTRYPOINT ["/usr/bin/go-template"]
COPY $TARGETPLATFORM/go-template /usr/bin/