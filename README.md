# Project 3 Overview — Azure Network Security

## Problem Statement
The hybrid environment required enterprise-grade
network security — moving from a flat network model
to a segmented, firewall-protected topology that
enforces Zero Trust network principles and provides
full traffic visibility.

## Solution
Deployed a Hub-and-Spoke network architecture with
Azure Firewall as the central inspection point —
micro-segmenting workloads across dedicated subnets
with NSG deny-all baselines and forced tunnelling
ensuring all traffic flows through the firewall.

## Key Decisions

### Why Hub-and-Spoke?
Hub-and-Spoke is the Microsoft recommended network
topology for enterprise Azure environments. It
provides centralised security services (firewall,
DNS, connectivity) in the Hub while allowing
workloads to be isolated in dedicated Spokes —
preventing lateral movement between workload tiers.

### Why Azure Firewall over NSGs only?
NSGs operate at Layer 4 (TCP/UDP ports).
Azure Firewall operates at Layer 4 AND Layer 7
(application layer) — enabling FQDN filtering,
threat intelligence, and full traffic inspection
that NSGs alone cannot provide.

### Why Force Tunnelling?
Without forced tunnelling, workload VMs can
bypass the firewall and communicate directly
to the internet. UDR routes with 0.0.0.0/0
pointing to the firewall private IP ensures
ALL outbound traffic is inspected — eliminating
a common security blind spot.

### Why Deny-All NSG Baseline?
An explicit deny-all inbound rule as the lowest
priority ensures no traffic reaches workloads
unless explicitly permitted by higher-priority
allow rules. This is the correct Zero Trust
network approach — default deny, explicit allow.

## Challenges & Solutions

| Challenge | Solution |
|-----------|----------|
| Firewall subnet sizing | /26 minimum enforced for AzureFirewallSubnet |
| Route table conflicts | Separate UDR per spoke with explicit prefixes |
| Peering gateway transit | AllowGatewayTransit on Hub side |
| Flow log storage | Dedicated storage account for flow logs |

## Business Value
- Zero internet-exposed workloads
- Full traffic inspection via Azure Firewall
- Lateral movement prevention via micro-segmentation
- Complete network traffic audit via flow logs
- Foundation for Private Endpoints (Project 4)
## Author
## Uzma Shabbir
