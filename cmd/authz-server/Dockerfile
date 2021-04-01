FROM golang:1.15 as build

ENV GO111MODULE=on

WORKDIR /app

COPY go.mod .
COPY go.sum .
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o authz-server authz_server.go

FROM scratch
COPY --from=build /app/authz-server /

EXPOSE 50051

ENTRYPOINT ["/authz-server"]
