// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ILendingPool {
    function deposit(address asset, uint256 amount, address onBehalfOf, uint16 referralCode) external;
    function withdraw(address asset, uint256 amount, address to) external returns (uint256);
    function borrow(address asset, uint256 amount, uint256 interestRateMode, uint16 referralCode, address onBehalfOf) external;
    function repay(address asset, uint256 amount, uint256 rateMode, address onBehalfOf) external returns (uint256);
}

contract CreditIntegration is Ownable {
    IERC20 public usdc;
    ILendingPool public lendingPool;

    struct Loan {
        uint256 borrowed;
        uint256 repaid;
        bool active;
    }

    mapping(address => Loan) public loans;
    uint256 public maxLoanAmount = 5000 * 1e6; // 5,000 USDC
    uint16 public referralCode = 0;

    event LoanRequested(address indexed farmer, uint256 amount);
    event LoanRepaid(address indexed farmer, uint256 amount);
    event USDCDeposited(uint256 amount);
    event USDCWithdrawn(uint256 amount);

    constructor(address _usdc, address _lendingPool) {
        usdc = IERC20(_usdc);
        lendingPool = ILendingPool(_lendingPool);
    }

    function depositToAave(uint256 amount) external onlyOwner {
        require(usdc.balanceOf(address(this)) >= amount, "Insufficient balance");

        usdc.approve(address(lendingPool), amount);
        lendingPool.deposit(address(usdc), amount, address(this), referralCode);

        emit USDCDeposited(amount);
    }

    function withdrawFromAave(uint256 amount) external onlyOwner {
        uint256 withdrawn = lendingPool.withdraw(address(usdc), amount, address(this));
        emit USDCWithdrawn(withdrawn);
    }

    function requestLoan(uint256 amount) external {
        require(amount > 0 && amount <= maxLoanAmount, "Invalid amount");
        require(!loans[msg.sender].active, "Loan already active");

        // Aave issues USDC to this contract; we send it to the farmer
        lendingPool.borrow(address(usdc), amount, 2, referralCode, address(this)); // 2 = variable interest

        usdc.transfer(msg.sender, amount);

        loans[msg.sender] = Loan({
            borrowed: amount,
            repaid: 0,
            active: true
        });

        emit LoanRequested(msg.sender, amount);
    }

    function repayLoan(uint256 amount) external {
        require(loans[msg.sender].active, "No active loan");

        usdc.transferFrom(msg.sender, address(this), amount);
        usdc.approve(address(lendingPool), amount);
        lendingPool.repay(address(usdc), amount, 2, address(this)); // 2 = variable interest

        loans[msg.sender].repaid += amount;

        if (loans[msg.sender].repaid >= loans[msg.sender].borrowed) {
            loans[msg.sender].active = false;
        }

        emit LoanRepaid(msg.sender, amount);
    }

    function getLoanStatus(address farmer) external view returns (
        uint256 borrowed,
        uint256 repaid,
        bool active
    ) {
        Loan storage l = loans[farmer];
        return (l.borrowed, l.repaid, l.active);
    }

    function setMaxLoanAmount(uint256 _amount) external onlyOwner {
        maxLoanAmount = _amount;
    }
}
