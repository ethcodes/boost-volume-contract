import "./interfaces/IERC20.sol";
import "./interfaces/IPancakePair.sol";
import "./interfaces/IPancakeRouter.sol";
import "./interfaces/IUniswapV2Factory.sol";
import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IUniswapV2Router02.sol";

import "./lib/Address.sol";
import "./lib/PancakeLibrary.sol";
import "./lib/SafeMath.sol";

pragma solidity ^0.6.12;
// SPDX-License-Identifier: Unlicensed

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

     /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = now + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(now > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

contract BoostVolume is Context, Ownable {
    using SafeMath for uint256;
    using Address for address;

    address public immutable factory;

    IUniswapV2Router02 public immutable uniswapV2Router;


    constructor (address _factory, address _router) public {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_router);
        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;
        factory = _factory;
    }

    function addSwapRemoveLiquidity(IERC20 tokenA, IERC20 tokenB, uint256 tokenAAmount, uint256 tokenBAmount) public {
        // split the tokenAAmount into halves
        uint256 halfTokenA = tokenAAmount.div(2);
        uint256 otherHalfTokenA = tokenAAmount.sub(halfTokenA);

        // split the tokenBAmount into halves
        uint256 halfTokenB = tokenBAmount.div(2);
        uint256 otherHalfTokenB = tokenAAmount.sub(halfTokenB);

        address[] memory path = new address[](2);
        path[0] = address(tokenA);
        path[1] = address(tokenB);

        tokenA.approve(address(this), tokenAAmount);
        tokenB.approve(address(this), tokenBAmount);

        // add the liquidity
        uniswapV2Router.addLiquidity(
            address(tokenA),
            address(tokenB),
            halfTokenA,
            halfTokenB,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );

        // swapTokensForExactTokens
        uniswapV2Router.swapTokensForExactTokens(
            0, // accept any amount of tokenB
            otherHalfTokenA,
            path,
            address(this),
            block.timestamp
        );

        // swapTokensForExactTokens
        uniswapV2Router.swapExactTokensForTokens(
            otherHalfTokenB,
            0, // accept any amount of tokenA
            path,
            address(this),
            block.timestamp
        );

        address pair = PancakeLibrary.pairFor(factory, address(tokenA), address(tokenB));
        uint256 liquidity = IERC20(pair).balanceOf(address(this));

        // removeLiquidity
        uniswapV2Router.removeLiquidity(
            address(tokenA),
            address(tokenB),
            liquidity,
            0, // accept any amount of tokenA
            0, // accept any amount of tokenB
            address(this),
            block.timestamp
        );
    }
}
