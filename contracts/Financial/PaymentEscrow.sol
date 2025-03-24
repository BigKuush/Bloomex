// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PaymentEscrow is Ownable {
    IERC20 public stableToken;

    enum EscrowStatus { Pending, Confirmed, Refunded }

    struct Escrow {
        address buyer;
        address seller; // фермер
        uint256 amount;
        EscrowStatus status;
    }

    mapping(uint256 => Escrow) public escrows;
    uint256 public escrowCount;

    event EscrowCreated(uint256 indexed escrowId, address buyer, address seller, uint256 amount);
    event EscrowConfirmed(uint256 indexed escrowId);
    event EscrowRefunded(uint256 indexed escrowId);

    constructor(address _stableToken) Ownable(msg.sender) {
        stableToken = IERC20(_stableToken);
    }

    /**
     * @notice Покупатель создаёт escrow, отправляя деньги на контракт
     */
    function createEscrow(address seller, uint256 amount) external returns (uint256) {
        require(amount > 0, "Invalid amount");
        require(seller != address(0), "Invalid seller");

        escrowCount++;
        uint256 escrowId = escrowCount;

        // Перевод USDC/USDT на контракт
        require(
            stableToken.transferFrom(msg.sender, address(this), amount),
            "Token transfer failed"
        );

        escrows[escrowId] = Escrow({
            buyer: msg.sender,
            seller: seller,
            amount: amount,
            status: EscrowStatus.Pending
        });

        emit EscrowCreated(escrowId, msg.sender, seller, amount);
        return escrowId;
    }

    /**
     * @notice Подтверждение получения продукции — средства уходят фермеру
     */
    function confirmEscrow(uint256 escrowId) external {
        Escrow storage e = escrows[escrowId];
        require(e.status == EscrowStatus.Pending, "Escrow not pending");
        require(msg.sender == e.buyer, "Only buyer can confirm");

        e.status = EscrowStatus.Confirmed;
        stableToken.transfer(e.seller, e.amount);

        emit EscrowConfirmed(escrowId);
    }

    /**
     * @notice Возврат средств покупателю (в будущем — через DAO или арбитраж)
     */
    function refundEscrow(uint256 escrowId) external onlyOwner {
        Escrow storage e = escrows[escrowId];
        require(e.status == EscrowStatus.Pending, "Escrow not pending");

        e.status = EscrowStatus.Refunded;
        stableToken.transfer(e.buyer, e.amount);

        emit EscrowRefunded(escrowId);
    }

    function getEscrow(uint256 escrowId) external view returns (
        address buyer,
        address seller,
        uint256 amount,
        EscrowStatus status
    ) {
        Escrow storage e = escrows[escrowId];
        return (e.buyer, e.seller, e.amount, e.status);
    }

    /**
     * @notice Админ может вывести лишние средства с контракта (если что-то застряло)
     */
    function withdraw(address to, uint256 amount) external onlyOwner {
        stableToken.transfer(to, amount);
    }
}
