package handler

import (
	"context"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/rajasoun/hello-service/tracer"
)

const (
	serviceTraceName = "hello-service"
)

var (
	traceProvider = tracer.Otel.New(serviceTraceName)
)

// SayHello says hello
func SayHello(c *gin.Context) {
	ctx := c.Request.Context()
	message := "Hello, World! (without telemetry)"
	greet(ctx, c, message)
}

// SayHelloWithTelemetry says hello with telemetry
func SayHelloWithTelemetry(c *gin.Context) {
	ctx := c.Request.Context()
	ctx, span := traceProvider.Tracer(serviceTraceName).Start(ctx, "SayHelloWithTelemetry")
	defer span.End()
	greet(ctx, c, "Hello, World! (with telemetry)")
}

// greet greets the user
func greet(ctx context.Context, c *gin.Context, message string) {
	_, span := traceProvider.Tracer(serviceTraceName).Start(ctx, "greet")
	defer span.End()
	c.JSON(http.StatusOK, gin.H{
		"message": message,
	})
}
