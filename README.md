# 🪪 ZenPass – Cross-Chain POAP Minting System

## 🔗 Contract Deployments

### Base Sepolia
- **ZenPass POAP Contract**  
  [`0x48f6bf86809e0aC9E57F6c63FBB4fC31fdb903d3`](https://sepolia.basescan.org/address/0x48f6bf86809e0aC9E57F6c63FBB4fC31fdb903d3)  
  This is the source contract where the `crossChainMint()` function is invoked. The request is processed and forwarded cross-chain.

### Polygon Amoy
- **ZenPass POAP Contract**  
  [`0x245C4d85558bFB54E9F27C99b55DaAC2a6eaDb42`](https://amoy.polygonscan.com/address/0x245C4d85558bFB54E9F27C99b55DaAC2a6eaDb42#events)  
  This contract receives the cross-chain mint request and mints the POAP to the user's address.

![image](https://github.com/user-attachments/assets/dd1c62d6-1893-41ad-80ee-13267af0592f)


## 🌉 Cross-Chain Minting Flow

- The `crossChainMint()` function is called on **Base Sepolia**, initiating a message via **Chainlink CCIP**.
- The request is routed to **Polygon Amoy**, where the POAP is minted upon message receipt.

## 🧠 Powered by Nodit

- **Nodit Web3 Data APIs**  
  - Used to fetch all **minted ZenPass POAPs** for a given wallet address, ensuring real-time updates for user profiles.

- **Nodit Multichain Webhook Listener**  
  - Subscribed to the `CrossChainReceived` event.
  - Once triggered, Nodit sends a **push notification** confirming successful POAP minting on the destination chain.

---


## Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)

## Getting Started

1. Install packages

```
forge install
```

2. Compile contracts

```
forge build
```

3. Create a new file by copying the `.env.example` file, and name it `.env`. Fill in the required fields
```
# Polygon Amoy RPC URL
POLYGON_AMOY_RPC_URL="https://polygon-amoy-bor-rpc.publicnode.com"

# Base Sepolia RPC URL
BASE_SEPOLIA_RPC_URL="https://base-sepolia-rpc.publicnode.com"

# Base Sepolia configuration
BASE_CCIP_ROUTER=""
BASE_LINK_TOKEN=""
BASE_CHAIN_SELECTOR=""

# Polygon Amoy configuration
POLYGON_CCIP_ROUTER=""
POLYGON_LINK_TOKEN=""
POLYGON_CHAIN_SELECTOR=""

PRIVATE_KEY=""

# Gas limit
GAS_LIMIT="200000"

# Etherscan API keys
BASE_SEPOLIA_KEY=""
POLYGON_AMOY_KEY=""
```

4. Run tests

```
forge test
```

5. Deploy Mulichain Contracts with verified instances

```
forge script script/DeployCrossChainPoap.s.sol:DeployMultiChainCrossChainPOAP --slow --multi --broadcast --private-key <> --verify -- --env-file .env
```
![image](https://github.com/user-attachments/assets/92d992f0-876a-4767-b7dd-97aa88605c8c)

![image](https://github.com/user-attachments/assets/7aacff49-e351-442f-8c46-27f34b800c42)


