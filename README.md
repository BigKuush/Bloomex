# Bloomex — Web3 Infrastructure for the Agricultural Sector

**Bloomex** is a blockchain platform built on **Arbitrum**, designed to optimize the agri-food industry through:

- Transparent distribution of agricultural products (social initiative)  
- Product sales and swaps via NFT  
- IDO-style crowdfunding for farmers  
- Integration with DeFi protocols and AI-driven automation  

The goal is to build a **fully digital, decentralized infrastructure** — no intermediaries, full transparency.

Website: https://www.bloomex.xyz
Founder: Alina Kushnareva
https://www.linkedin.com/in/alinakushnareva/

---

## Project Architecture

### Phase 1 — Social Program (MVP)
- `FoodRescueNFT.sol` — NFT representation of food batches with metadata  
- `VolunteerRewards.sol` — stablecoin-based reward system for volunteers  
- `QualityRating.sol` — farmer and volunteer ratings based on verified actions  
- `FarmerReward.sol` — subsidy logic for farmers participating in food donation programs  

### Phase 2 — Financial Layer
- `ProductSwap.sol` — NFT-based swap system for product sales  
- `PaymentEscrow.sol` — secure payment system between buyers and farmers  
- `IDOInvestmentPool.sol` — direct IDO pools for decentralized farm funding  

### Phase 3 — DAO Governance
- `BloomexDAO.sol` — governance, arbitration, and funding distribution logic  
- `GovernanceToken.sol` *(optional)* — platform governance token  

### Phase 4 — Integrations
- `AaveIntegration.sol` — access to decentralized lending via Aave  
- `RedalcoIntegration.sol` — API bridge with ESG and nonprofit partners  

---

## AI Infrastructure

Located in `services/ai/`, the AI logic is organized by modules:

- `reward/` — allocation of bonuses and IDO rewards  
- `productivity/` — scoring of farmer performance  
- `validation/` — fraud detection and volunteer verification  
- `sync/` — data logging and off-chain bridge  

For the MVP stage, the system uses a **rule-based approach**, but it's structured to scale into a full AI microservice for predictive analytics and decision-making.

---

## Repository Structure

```
bloomex-contracts/
├── contracts/             # Smart contracts (Solidity)
│   ├── Social/            # Product and volunteer logic
│   ├── Financial/         # Sales, IDO, lending
│   ├── DAO/               # Governance
│   ├── Integrations/      # DeFi & NGO bridges
├── services/ai/           # Automation and AI (Node.js)
├── tests/                 # Unit & integration tests
├── scripts/               # Deployment and integrations
├── config/                # Hardhat configuration
├── frontend/              # API and frontend logic (in progress)
└── README.md
```

---

## How to Use

### Requirements
- Node.js  
- Hardhat  
- Arbitrum-compatible wallet  

### Installation

```bash
npm install
npx hardhat compile
```

### Deployment (Goerli / Arbitrum testnet)

```bash
npx hardhat run scripts/deploy.js --network arbitrumGoerli
```

### Testing

```bash
npx hardhat test
```

---

## License

This project is licensed under the MIT License.

---

## Contact

Founder: Alina Kushnareva
https://www.linkedin.com/in/alinakushnareva/ 
Website: www.bloomex.xyz
Email: info@bloomex.xyz