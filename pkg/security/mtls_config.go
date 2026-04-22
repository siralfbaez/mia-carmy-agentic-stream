package security

import (
	"crypto/tls"
	"crypto/x509"
	"fmt"
	"os"
)

// LoadmTLSConfig handles the heavy lifting of Zero Trust certificate validation
func LoadmTLSConfig(caCertPath, serverCertPath, serverKeyPath string) (*tls.Config, error) {
	// 1. Load the CA certificate (The trust anchor for cArmy/ECMA)
	caCert, err := os.ReadFile(caCertPath)
	if err != nil {
		return nil, fmt.Errorf("failed to read CA cert: %w", err)
	}

	caCertPool := x509.NewCertPool()
	if ok := caCertPool.AppendCertsFromPEM(caCert); !ok {
		return nil, fmt.Errorf("failed to append CA cert to pool")
	}

	// 2. Load the Service's own Certificate and Private Key
	cert, err := tls.LoadX509KeyPair(serverCertPath, serverKeyPath)
	if err != nil {
		return nil, fmt.Errorf("failed to load server key pair: %w", err)
	}

	// 3. Construct the hardened TLS Configuration
	return &tls.Config{
		Certificates: []tls.Certificate{cert},
		ClientCAs:    caCertPool,
		// RequireAndVerifyClientCert is the "Mutual" in mTLS
		ClientAuth: tls.RequireAndVerifyClientCert,
		// STIG Requirement: Force TLS 1.3 to avoid legacy cipher vulnerabilities
		MinVersion: tls.VersionTLS13,
		CurvePreferences: []tls.CurveID{tls.CurveP521, tls.CurveP384},
	}, nil
}
