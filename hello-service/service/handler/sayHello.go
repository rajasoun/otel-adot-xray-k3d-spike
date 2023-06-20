package handler

import (
	"context"
	"net/http"

	"github.com/gin-gonic/gin"
)

// const (
// 	serviceTraceName = "hello-service"
// )

// SayHello says hello
func SayHello(c *gin.Context) {
	ctx := c.Request.Context()
	message := "Hello, World! (without telemetry)"
	greet(ctx, c, message)
}

// SayHelloWithTelemetry says hello with telemetry
func SayHelloWithTelemetry(c *gin.Context) {
	ctx := c.Request.Context()
	// ctx, span := tracer.Otel.StartSpan(ctx, serviceTraceName)
	// defer span.End()
	greet(ctx, c, "Hello, World! (with telemetry)")

}

// greet greets the user
func greet(ctx context.Context, c *gin.Context, message string) {
	// _, span := tracer.Otel.StartSpan(ctx, serviceTraceName)
	// defer span.End()
	c.JSON(http.StatusOK, gin.H{
		"message": message,
	})
}
