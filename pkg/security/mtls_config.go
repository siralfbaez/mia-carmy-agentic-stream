package security

import (
	"crypto/tls"
	"crypto/x509"
	"os"
)

// LoadmTLSConfig creates a TLS config that enforces mutual authentication
func LoadmTLSConfig(caCertPath, serverCertPath, serverKeyPath string) (*tls.Config, error) {
	// 1. Load the trusted CA certificate (The trust anchor)
	caCert, _ := os.ReadFile(caCertPath)
	caCertPool := x509.NewCertPool()
	caCertPool.AppendCertsFromPEM(caCert)

	// 2. Load the service's own cert/key pair
	cert, _ := tls.LoadX509KeyPair(serverCertPath, serverKeyPath)

	return &tls.Config{
		Certificates: []tls.Certificate{cert},
		ClientCAs:    caCertPool,
		// NIST 800-53 AC-3 & SC-8: Enforce Mutual Authentication
		ClientAuth:   tls.RequireAndVerifyClientCert, 
		MinVersion:   tls.VersionTLS13, // STIGs require TLS 1.2+, 1.3 preferred
	}, nil
}
