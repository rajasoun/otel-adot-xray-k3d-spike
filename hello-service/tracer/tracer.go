package tracer

import (
	"context"
	"fmt"
	"log"
	"os"

	"go.opentelemetry.io/contrib/propagators/aws/xray"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc"
	"go.opentelemetry.io/otel/sdk/resource"
	sdktrace "go.opentelemetry.io/otel/sdk/trace"
	semconv "go.opentelemetry.io/otel/semconv/v1.10.0"
	"go.opentelemetry.io/otel/trace"
	"google.golang.org/grpc"
)

// Tracer is an interface for initializing the tracer and retrieving the X-Ray trace ID
type Tracer interface {
	New(serviceName string) *sdktrace.TracerProvider
	GetXrayTraceID(span trace.Span) string
}

// TracerImpl is an implementation of Tracer
type TracerImpl struct{}

// TracerProvider is an instance of Tracer
var Otel Tracer = &TracerImpl{}

// New initializes the tracer
func (t *TracerImpl) New(serviceName string) *sdktrace.TracerProvider {
	ctx := context.Background()
	endpoint := getOTLPEndpointFromEnv()

	traceExporter, err := createOTLPTraceExporter(ctx, endpoint)
	if err != nil {
		log.Fatalf("failed to create OTLP trace exporter: %v", err)
		return nil
	}
	log.Println("After initializing console trace exporter")

	traceProvider := createTraceProvider(traceExporter, serviceName)
	otel.SetTracerProvider(traceProvider)
	otel.SetTextMapPropagator(xray.Propagator{})
	return traceProvider
}

// GetXrayTraceID gets the X-Ray trace ID
func (t *TracerImpl) GetXrayTraceID(span trace.Span) string {
	xrayTraceID := span.SpanContext().TraceID().String()
	result := fmt.Sprintf("1-%s-%s", xrayTraceID[0:8], xrayTraceID[8:])
	return result
}

// getOTLPEndpointFromEnv gets the OTLP endpoint from the environment
func getOTLPEndpointFromEnv() string {
	endpoint := os.Getenv("OTEL_EXPORTER_OTLP_ENDPOINT")
	if endpoint == "" {
		endpoint = "0.0.0.0:4317"
	}
	log.Println("OTLP endpoint: ", endpoint)
	return endpoint
}

// createOTLPTraceExporter creates the OTLP trace exporter
func createOTLPTraceExporter(ctx context.Context, endpoint string) (*otlptrace.Exporter, error) {
	traceExporter, err := otlptracegrpc.New(ctx,
		otlptracegrpc.WithInsecure(),
		otlptracegrpc.WithEndpoint(endpoint),
		otlptracegrpc.WithDialOption(grpc.WithBlock()),
	)
	if err != nil {
		return nil, fmt.Errorf("failed to create OTLP trace exporter: %w", err)
	}
	return traceExporter, nil
}

// createTraceProvider creates the trace provider
func createTraceProvider(traceExporter *otlptrace.Exporter, serviceName string) *sdktrace.TracerProvider {
	idg := xray.NewIDGenerator()

	res := resource.NewWithAttributes(
		semconv.SchemaURL,
		semconv.ServiceNameKey.String(serviceName),
	)

	tp := sdktrace.NewTracerProvider(
		sdktrace.WithSampler(sdktrace.AlwaysSample()),
		sdktrace.WithResource(res),
		sdktrace.WithBatcher(traceExporter),
		sdktrace.WithIDGenerator(idg),
	)
	return tp
}
