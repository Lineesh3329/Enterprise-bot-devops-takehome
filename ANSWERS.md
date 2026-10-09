
## Part 5 — Gateway API Migration Plan

I would migrate from Kubernetes Ingress to Gateway API gradually to minimise downtime and make rollback easier.

### 1. Install and Validate

First, I would check the Kubernetes version and install the required Gateway API CRDs and a compatible Gateway API controller. Gateway API resources alone do not handle traffic without a controller.

### 2. Configure Routing

I would create a `GatewayClass` and a `Gateway` with the required listeners and ports. Then I would create an `HTTPRoute` to direct requests to the existing Kubernetes Services.

### 3. Test Before Switching Traffic

I would keep the existing Ingress running while testing the new routes. I would verify hostname routing, backend connectivity, health endpoints, and TLS if required. I would also check that the controller accepts and programs the routes correctly.

### 4. Migrate and Monitor

After testing, I would gradually move traffic to the Gateway using the appropriate load-balancer or DNS configuration. I would monitor HTTP errors, latency, and application availability.

### 5. Rollback

If problems occur, I would redirect traffic to the existing Ingress while troubleshooting. I would remove the old Ingress only after the new configuration had been validated.

I have not implemented this migration in the current project; this is the approach I would follow in a real environment.
