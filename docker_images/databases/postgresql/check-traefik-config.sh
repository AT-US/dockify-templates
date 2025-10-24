#!/bin/bash

# PostgreSQL Traefik Configuration Checker
# This script verifies that Traefik is properly configured for PostgreSQL TCP routing

echo "=========================================="
echo "PostgreSQL Traefik Configuration Checker"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl not found. Please install kubectl first.${NC}"
    exit 1
fi

echo "1. Checking Traefik Service for PostgreSQL port..."
echo "-------------------------------------------"

# Check if Traefik service has port 5432
if kubectl get service -A | grep -q traefik; then
    TRAEFIK_NAMESPACE=$(kubectl get service -A | grep traefik | head -1 | awk '{print $1}')
    TRAEFIK_SERVICE=$(kubectl get service -A | grep traefik | head -1 | awk '{print $2}')

    echo "Found Traefik service: $TRAEFIK_SERVICE in namespace: $TRAEFIK_NAMESPACE"

    # Check for port 5432
    if kubectl get service $TRAEFIK_SERVICE -n $TRAEFIK_NAMESPACE -o yaml | grep -q "port: 5432"; then
        echo -e "${GREEN}✅ Port 5432 is configured in Traefik service${NC}"

        # Get external IP/hostname
        EXTERNAL_IP=$(kubectl get service $TRAEFIK_SERVICE -n $TRAEFIK_NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
        EXTERNAL_HOSTNAME=$(kubectl get service $TRAEFIK_SERVICE -n $TRAEFIK_NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

        if [ ! -z "$EXTERNAL_IP" ]; then
            echo -e "${GREEN}✅ External IP: $EXTERNAL_IP${NC}"
        elif [ ! -z "$EXTERNAL_HOSTNAME" ]; then
            echo -e "${GREEN}✅ External Hostname: $EXTERNAL_HOSTNAME${NC}"
        else
            echo -e "${YELLOW}⚠️  No external IP/hostname found. LoadBalancer might be pending.${NC}"
        fi
    else
        echo -e "${RED}❌ Port 5432 NOT found in Traefik service!${NC}"
        echo ""
        echo "To fix, add this to your Traefik Helm values:"
        echo "-------------------------------------------"
        cat << EOF
ports:
  postgres:
    port: 5432
    expose: true
    exposedPort: 5432
    protocol: TCP
EOF
        echo "-------------------------------------------"
    fi
else
    echo -e "${RED}❌ Traefik service not found!${NC}"
fi

echo ""
echo "2. Checking Traefik Deployment for PostgreSQL entrypoint..."
echo "-------------------------------------------"

# Check Traefik deployment/daemonset for the entrypoint
if [ ! -z "$TRAEFIK_NAMESPACE" ]; then
    # Check for postgres entrypoint in args
    if kubectl get deployment -n $TRAEFIK_NAMESPACE 2>/dev/null | grep -q traefik; then
        DEPLOYMENT_NAME=$(kubectl get deployment -n $TRAEFIK_NAMESPACE | grep traefik | head -1 | awk '{print $1}')

        if kubectl get deployment $DEPLOYMENT_NAME -n $TRAEFIK_NAMESPACE -o yaml | grep -q "entrypoints.postgres"; then
            echo -e "${GREEN}✅ PostgreSQL entrypoint found in Traefik deployment${NC}"
        else
            echo -e "${YELLOW}⚠️  PostgreSQL entrypoint not explicitly found in deployment args${NC}"
            echo "   (It might be configured via ConfigMap or values file)"
        fi
    fi

    # Check for DaemonSet
    if kubectl get daemonset -n $TRAEFIK_NAMESPACE 2>/dev/null | grep -q traefik; then
        DAEMONSET_NAME=$(kubectl get daemonset -n $TRAEFIK_NAMESPACE | grep traefik | head -1 | awk '{print $1}')

        if kubectl get daemonset $DAEMONSET_NAME -n $TRAEFIK_NAMESPACE -o yaml | grep -q "entrypoints.postgres"; then
            echo -e "${GREEN}✅ PostgreSQL entrypoint found in Traefik daemonset${NC}"
        else
            echo -e "${YELLOW}⚠️  PostgreSQL entrypoint not explicitly found in daemonset args${NC}"
            echo "   (It might be configured via ConfigMap or values file)"
        fi
    fi
fi

echo ""
echo "3. Checking for PostgreSQL IngressRouteTCP resources..."
echo "-------------------------------------------"

# Check for IngressRouteTCP resources
INGRESS_COUNT=$(kubectl get ingressroutetcp -A 2>/dev/null | grep -c postgresql)

if [ $INGRESS_COUNT -gt 0 ]; then
    echo -e "${GREEN}✅ Found $INGRESS_COUNT PostgreSQL IngressRouteTCP resource(s)${NC}"
    echo ""
    echo "PostgreSQL IngressRouteTCP resources:"
    kubectl get ingressroutetcp -A | grep -E "NAMESPACE|postgresql"
else
    echo -e "${YELLOW}⚠️  No PostgreSQL IngressRouteTCP resources found${NC}"
    echo "   (This is normal if you haven't deployed PostgreSQL yet)"
fi

echo ""
echo "4. Network Connectivity Test..."
echo "-------------------------------------------"

if [ ! -z "$EXTERNAL_IP" ] || [ ! -z "$EXTERNAL_HOSTNAME" ]; then
    TARGET=${EXTERNAL_IP:-$EXTERNAL_HOSTNAME}

    echo "Testing TCP connectivity to $TARGET:5432..."

    # Use timeout command if available
    if command -v timeout &> /dev/null; then
        if timeout 3 bash -c "echo > /dev/tcp/$TARGET/5432" 2>/dev/null; then
            echo -e "${GREEN}✅ Port 5432 is accessible on $TARGET${NC}"
        else
            echo -e "${RED}❌ Cannot connect to port 5432 on $TARGET${NC}"
            echo ""
            echo "Possible causes:"
            echo "- Firewall/Security Group blocking port 5432"
            echo "- Traefik not configured with postgres entrypoint"
            echo "- LoadBalancer not exposing port 5432"
        fi
    else
        echo -e "${YELLOW}⚠️  'timeout' command not found. Skipping connectivity test.${NC}"
    fi
fi

echo ""
echo "=========================================="
echo "Summary"
echo "=========================================="

echo ""
echo "If you see any ❌ errors above, please:"
echo "1. Configure Traefik with the postgres TCP entrypoint"
echo "2. Ensure your firewall/security group allows TCP port 5432"
echo "3. Verify your LoadBalancer exposes port 5432"
echo ""
echo "For detailed configuration instructions, see TRAEFIK_CONFIG_REQUIRED.md"