FROM gcr.io/distroless/static:nonroot@sha256:cba10d7abd3e203428e86f5b2d7fd5eb7d8987c387864ae4996cf97191b33764
ARG TARGETPLATFORM
COPY $TARGETPLATFORM/go-template /usr/bin/
ENTRYPOINT ["/usr/bin/go-template"]