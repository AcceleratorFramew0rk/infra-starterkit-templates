# AI Foundry Deployment Validation

## Virtual Network
- **VNet Name:** `gcci-vnet-project`
- **Subnets:**
  - `AgentSubnet`
  - `ServiceSubnet`
    - Delegation: `Microsoft.Apps/environments`

## AI Foundry
- Public access **disabled**
  - In GCC, allow IPs from SEED Machines and GSIB Machines only
- Private endpoint connections configured
- Network injection enabled

## Access Verification
- Open [mi.azure.com](https://mi.azure.com) and confirm access to the **Agent** tab in the left navigation menu.

## AI Foundry Project

## Azure Cosmos DB Account

## Private DNS Zones & Private Endpoints

### Private Endpoints (Total: 4)
- AI Foundry
- Cosmos DB
- AI Search
- Storage

### Private DNS Zones (Total: 6)
- **AI Foundry (3 zones):**
  - AI Foundry endpoint
  - Cognitive Services endpoint
  - OpenAI endpoint
- **Cosmos DB (1 zone)**
- **AI Search (1 zone)**
- **Storage (1 zone)**
- All zones should be VNET linked to `gcci-vnet-project` or `vnet-<prefix>-aiagent`

## Storage Account

---

# Validation Steps

## 1. AI Foundry UI Access
- In Azure Portal, select **AI Foundry** and open the UI (`ai.azure.com`)
- Click **Agent** in the left navigation menu; confirm the agent page loads.

## 2. Agent Page Connections
- On the agent page, verify the following resource connections are visible:
  - **Azure AI Search:** `srch-<prefix>-aiagent-xxx`
  - **Azure Cosmos DB:** `cosmos<prefix>aiagentxxx`

## 3. Management Center Connections
- Go to **Management Center** and check connections under your project:
  - Cosmos DB: `cosmos<prefix>aiagentxxx`
  - Storage: `st<prefix>aiagentxxx`
  - AI Search: `srch-<prefix>-aiagent-xxx`

## 4. AI Foundry Project Assets
- Go to **AI Foundry Project**
  - Select **My Assets > Model + Endpoint** in the left navigation menu
  - Confirm that **ChatGPT 4.1** is already created

## 5. Agent Creation
- Go to **Agents**
  - Click **New Agent**; verify a new agent is created with the same Cosmos DB and AI Search connections
  - Each agent should follow capability host creation with the same Cosmos DB and AI Search connections

---
