# Application Gateway & Firewall Configuration and Test Guide

# ----------------------------------------
# 1. Configure Application Gateway (AGW)
# ----------------------------------------

# Backend Pool
#   - Copy the App Service Web App URL from Azure Portal.
#   - Paste the URL in the Backend Pool of Application Gateway.

# HTTP Settings
#   - Add HTTP setting with port 80.
#   - Override with host name from backend pool.

# Listener
#   - Add listener with port 80.

# Rule
#   - Add rule to link listener with backend pool and HTTP setting.

# ----------------------------------------
# 2. Test Application Gateway
# ----------------------------------------

#   - Open the Application Gateway URL in your browser to verify access.

# ----------------------------------------
# 3. Configure Firewall Routing
# ----------------------------------------

# Create a route table "rt-ingress-egress-agwiz" to route all traffic to the firewall:
#   - Add route:
#       - Name: route-to-fw
#       - Address prefix: (specify as needed)
#       - Next hop: Appliance (Firewall private IP: 10.20.0.68)
#       - VNET Link: AgwSubnet

# Associate the route table to the subnet where Application Gateway is integrated:
#   - Go to the subnet in Azure Portal.
#   - Under "Route Table", associate the route table created above.

# ----------------------------------------
# 4. Firewall Test Scenarios
# ----------------------------------------

#   - Try to access the App Service URL directly in browser: should be BLOCKED.
#   - Try to access the App Service URL via Application Gateway URL in browser: should be ALLOWED.
#   - Try to access the App Service URL via curl: should be BLOCKED.
#   - Try to access the App Service URL via Application Gateway URL with curl: should be ALLOWED.

# Example curl commands:
#   curl -v http://<app_service_name>.azurewebsites.net
#   curl -v http://<application_gateway_name>.<region>.cloudapp.azure.com

# ----------------------------------------
# 5. AGW HTTPS Configuration Reference
# ----------------------------------------

# Browser (443) >
#   Listener (443)
#     - Add Listener
#   Rules
#     - Listener (443)
#     - Backend Targets
#       - Backend Pools
#       - Backend Settings (Backend Port: 443)

# ----------------------------------------
# 6. Example AGW Public IP for Testing
# ----------------------------------------

#   https://104.43.76.0 (pip-plz34-stg-agwiz)
