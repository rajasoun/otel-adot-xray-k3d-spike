package service

import (
	"context"
	"log"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/rajasoun/hello-service/service/handler"
)

// ServiceInterface is an interface for the service
type ServiceInterface interface {
	Start()
	Stop()
}

// ServiceImpl is an implementation of ServiceInterface
type ServiceImpl struct {
	server *http.Server
}

// Start starts the service
func (s *ServiceImpl) Start() {
	gin.SetMode(gin.ReleaseMode)
	ctx := context.Background()
	router := setupRouter()
	s.server = &http.Server{Addr: ":8080", Handler: router}
	go startServer(ctx, s.server)
}

// Stop stops the service
func (s *ServiceImpl) Stop() {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	shutdownServer(ctx, s.server)
}

// setupRouter sets up the router
func setupRouter() *gin.Engine {
	router := gin.Default()
	router.Use(gin.Recovery())
	router.Use(gin.Logger())
	router.SetTrustedProxies([]string{"0.0.0.0"})

	router.GET("/", handler.SayHello)
	router.GET("/otel", handler.SayHelloWithTelemetry)

	return router
}

// startServer starts the server
func startServer(ctx context.Context, server *http.Server) {
	if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		log.Fatalf("failed to listen and serve: %v", err)
	}
}

// shutdownServer shuts down the server
func shutdownServer(ctx context.Context, server *http.Server) {
	if err := server.Shutdown(ctx); err != nil {
		log.Fatalf("failed to shutdown server: %v", err)
	}
}
