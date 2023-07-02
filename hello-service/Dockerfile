# Stage 1: Build
FROM golang:1.20 as build
WORKDIR /app/
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -o main main.go

# Stage 2: Final Image
FROM scratch
COPY --from=build /app/main /app/main
CMD ["/app/main"]
