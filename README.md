# SentinelVault

A **self-revoking, behavior-triggered smart wallet** for the Stacks blockchain that enforces spending limits and provides emergency access controls through guardian-based authorization.

## Overview

SentinelVault implements advanced wallet security by combining daily spending limits with role-based access control. If daily spending exceeds configured thresholds, the wallet automatically locks itself, requiring guardian authorization to unlock. Perfect for users who want behavioral guardrails on their self-custodial funds.

## Key Features

✅ **Daily Spending Limits** - Automatic wallet lock when daily limit is exceeded  
✅ **Dual-Authority Model** - Owner for normal operations, Guardian for emergency unlock  
✅ **Behavioral Triggers** - Self-revoking access when security thresholds breached  
✅ **Manual Controls** - Owner can manually lock wallet anytime  
✅ **Real-Time Tracking** - Monitor daily spending and wallet status  
✅ **Configurable Limits** - Update daily spending thresholds on-demand  

## How It Works

1. **Owner** transfers funds normally as long as daily spending stays within the configured limit
2. **Spending Tracker** accumulates all transfers in a 24-hour period
3. **Limit Exceeded** → Wallet auto-locks, blocking all transfers
4. **Guardian Unlock** → Only the guardian can unlock the wallet in emergencies
5. **Status Monitoring** → Query wallet state anytime via `get-status`

## Installation

### Prerequisites
- Stacks blockchain environment (testnet or mainnet)
- Clarity contract deployment tools (e.g., Clarinet)

### Deploy

```bash
# Using Clarinet
clarinet contract publish SentinelVault.clar
