// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title QuestXP
/// @notice ERC20 token used as XP/points for the Monad Quests game.
/// @dev Owner (typically the QuestManager) is expected to have exclusive mint rights.
///      The constructor assigns initial ownership to `initialOwner` so you can
///      transfer ownership to a manager contract immediately after deployment.
contract QuestXP is ERC20, Ownable {
    /// @notice Emitted when tokens are burned.
    event Burn(address indexed from, uint256 amount);

    /// @param name_ Token name (e.g. "Monad Quest XP")
    /// @param symbol_ Token symbol (e.g. "MQXP")
    /// @param initialOwner Address that will be the initial owner (must be non-zero)
    constructor(
        string memory name_,
        string memory symbol_,
        address initialOwner
    ) ERC20(name_, symbol_) {
        require(initialOwner != address(0), "QuestXP: initial owner zero");
        _transferOwnership(initialOwner);
    }

    /// @notice Mint new XP tokens to `to`.
    /// @dev Callable only by owner (QuestManager). Amount uses 18 decimals.
    /// @param to Recipient address (non-zero)
    /// @param amount Amount to mint (in wei, e.g. 1 XP = 1e18)
    function mint(address to, uint256 amount) external onlyOwner {
        require(to != address(0), "QuestXP: mint to zero");
        require(amount > 0, "QuestXP: mint zero");
        _mint(to, amount);
    }

    /// @notice Burn tokens from caller.
    /// @dev Allows players to burn XP if you want a sink; optional feature.
    /// @param amount Amount to burn (in wei)
    function burn(uint256 amount) external {
        require(amount > 0, "QuestXP: burn zero");
        _burn(_msgSender(), amount);
        emit Burn(_msgSender(), amount);
    }

    /// @notice Recover ERC20 tokens accidentally sent to this contract.
    /// @dev Only owner can recover non-QuestXP tokens. Useful in production.
    /// @param token Address of the token to recover
    /// @param to Recipient address
    /// @param amount Amount to recover
    function recoverERC20(
        address token,
        address to,
        uint256 amount
    ) external onlyOwner {
        require(to != address(0), "QuestXP: recover to zero");
        require(token != address(this), "QuestXP: cannot recover native XP");
        IERC20(token).transfer(to, amount);
    }
}

