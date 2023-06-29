package service

import (
	"context"
	"log"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/rajasoun/hello-service/tracer"
)

type ServiceInterface interface {
	Start()
	Stop()
}

type ServiceImpl struct {
	server *http.Server
}

func (s *ServiceImpl) Start() {
	gin.SetMode(gin.ReleaseMode)
	router := setupRouter()

	s.server = &http.Server{
		Addr:    ":8080",
		Handler: router,
	}

	go startServer(s.server)
}

func (s *ServiceImpl) Stop() {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	shutdownServer(s.server, ctx)
}

func setupRouter() *gin.Engine {
	router := gin.Default()
	router.SetTrustedProxies([]string{"0.0.0.0"})

	router.GET("/", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message": "Hello, World! (without telemetry)",
		})
	})

	router.GET("/otel", func(c *gin.Context) {
		ctx := c.Request.Context()
		traceProvider := tracer.Otel.New("hello-service")

		log.Println("After initializing tracer provider")
		_, span := traceProvider.Tracer("hello-service").Start(ctx, "hello-service-handler-with-otel")
		defer span.End()
		c.JSON(http.StatusOK, gin.H{
			"message": "Hello, World! (with telemetry)",
		})

	})

	return router
}

func startServer(server *http.Server) {
	if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		panic(err)
	}
}

func shutdownServer(server *http.Server, ctx context.Context) {
	if err := server.Shutdown(ctx); err != nil {
		panic(err)
	}
}
