# Decentralized Autonomous Organization (DAO) Project

## Overview

This project implements a Decentralized Autonomous Organization (DAO) on the Ethereum blockchain. The DAO allows stakeholders to propose, vote on, and fund projects autonomously without the need for traditional intermediaries.

## Features

- **Proposal Creation**: Stakeholders can create proposals for funding projects by providing details such as title, description, beneficiary, and funding amount.
- **Voting Mechanism**: Stakeholders can vote on proposals to determine whether they should be funded or not. Each stakeholder's vote is weighted based on their stake in the DAO.
- **Automatic Fund Distribution**: If a proposal receives enough votes, the specified amount is automatically transferred to the beneficiary.
- **Access Control**: The DAO employs access control mechanisms to differentiate between contributors and stakeholders, allowing only stakeholders to create and vote on proposals.
- **Transparent Governance**: All proposals, votes, and fund transfers are recorded on the blockchain, ensuring transparency and auditability of the DAO's governance processes.
- **User Interface**: A user-friendly web interface built with React allows stakeholders and contributors to interact with the DAO.

## Getting Started

### Prerequisites

- Ethereum Wallet (e.g., MetaMask) installed
- Ether for transactions on the Ethereum network
- Node.js and npm installed

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/madhavvijay/DAOPROJECT.git
   ```

2. Install dependencies for both the smart contract and the React UI:

   ```bash
   cd DAOPROJECT
   npm install
   ```

### Usage

1. Deploy the smart contract to the Ethereum network using Remix or Truffle.
2. Update the `DAOPROJECT/src/blockchain.jsx` file with the deployed contract address.
3. Run the React UI:

   ```bash
   cd DAOPROJECT
   npm start
   ```

4. Interact with the deployed contract using the React UI to create proposals, vote on proposals, and contribute funds.

## Contributing

Contributions are welcome! If you'd like to contribute to the project, please follow these steps:

1. Fork the repository.
2. Create a new branch (`git checkout -b feature/your-feature`).
3. Make your changes and commit them (`git commit -am 'Add new feature'`).
4. Push to the branch (`git push origin feature/your-feature`).
5. Create a new pull request.

## Contact

For questions or inquiries, please contact [Madhav Vijayvargiya](mailto:vijaywargiyamadhav@gmail.com).
