// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract SupplyChain {
    address public owner;
    mapping(uint => Product) public products;
    uint public productCount = 0;
    mapping(uint => bool) public tokenized;
    mapping(uint => uint) public rewards;  // Rewards for fulfilling supply chains in time

    struct Product {
        uint id;
        string name;
        string description;
        uint quantity;
        bool isExpired;
    }

    event ProductCreated(uint productId, string name, uint quantity);
    event ProductUpdated(uint productId, uint quantity, bool isExpired);
    event ProductTokenized(uint productId);
    event RewardPaid(uint productId, uint reward);

    constructor() {
        owner = msg.sender;
    }

    function createProduct(string memory name, string memory description, uint quantity) public {
        require(msg.sender == owner, "Only owner can add products.");
        productCount ++;
        products[productCount] = Product(productCount, name, description, quantity, false);
        emit ProductCreated(productCount, name, quantity);
    }

    function updateProduct(uint id, uint quantity, bool isExpired) public {
        require(msg.sender == owner, "Only owner can update products.");
        Product storage product = products[id];
        product.quantity = quantity;
        product.isExpired = isExpired;
        emit ProductUpdated(id, quantity, isExpired);
    }

    function tokenizeProduct(uint id) public {
        require(msg.sender == owner, "Only owner can tokenize products.");
        require(!tokenized[id], "Product already tokenized.");
        tokenized[id] = true;
        emit ProductTokenized(id);
    }

    function payReward(uint id, uint reward) public {
        require(msg.sender == owner, "Only owner can pay rewards.");
        rewards[id] += reward;
        emit RewardPaid(id, reward);
    }

    function buyBackExpired(uint id) public {
        require(msg.sender == owner, "Only owner can initiate buyback.");
        Product storage product = products[id];
        require(product.isExpired, "Product is not expired.");
        product.quantity = 0;  // Assuming product is bought back completely
        // Integrate with social program API or internal logic
    }

    // Additional logic to interact with external APIs or other smart contracts can be added here
}
