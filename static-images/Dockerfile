FROM cgr.dev/chainguard/go AS builder

WORKDIR /work

COPY go.mod /work/
COPY cmd /work/cmd
COPY internal /work/internal

RUN CGO_ENABLED=0 go build -o hello ./cmd/server

ENTRYPOINT ["/work/hello"]

FROM cgr.dev/chainguard/static

COPY --from=builder /work/hello /hello
ENTRYPOINT ["/hello"]
