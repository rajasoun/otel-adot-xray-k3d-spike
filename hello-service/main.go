package main

import (
	"os"
	"os/signal"
	"syscall"

	"github.com/rajasoun/hello-service/service"
)

func main() {
	svc := &service.ServiceImpl{}
	svc.Start()

	// Create a channel to listen for the interrupt or terminate signal
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	svc.Stop()
}
