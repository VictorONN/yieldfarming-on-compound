pragma solidity ^0.5.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./CTokenInterface.sol";
import "./ComptrollerInterface.sol";

contract Compound {
    ComptrollerInterface public comptroller;

    constructor(address _comptroller) public {
        comptroller = ComptrollerInterface(_comptroller);
    }

    function supply(address cTokenAddress, uint256 underlyingAmount) internal {
        CTokenInterface cToken = CTokenInterface(cTokenAddress);
        address underlyingAddress = cToken.underlying();
        IERC20(underlyingAddress).approve(cTokenAddress, underlyingAmount);
        uint256 result = cToken.mint(underlyingAmount);
        require(
            result == 0,
            "cToken#mint() failed. See Compound ErrorReporter.sol for details"
        );
    }

    function redeem(address cTokenAddress, uint256 cTokenAmount) internal {
        CTokenInterface cToken = CTokenInterface(cTokenAddress);
        uint256 result = cToken.redeem(cTokenAmount);
        require(
            result == 0,
            "cToken#redeem() failed. See Compound ErrorReporter.sol for more details"
        );
    }

    function enterMarket(address cTokenAddress) internal {
        address[] memory markets = new address[](1);
        markets[0] = cTokenAddress;
        uint256[] memory results = comptroller.enterMarkets(markets);
        require(
            results[0] == 0,
            "comptroller#enterMarket() failed. See Compound ErrorReporter.sol for details"
        );
    }

    function borrow(address cTokenAddress, uint256 borrowAmount) internal {
        CTokenInterface cToken = CTokenInterface(cTokenAddress);
        uint256 result = cToken.borrow(borrowAmount);
        require(
            result == 0,
            "cToken#borrow() failed. See Compound ErrorReporter.sol for details"
        );
    }

    function repayBorrow(address cTokenAddress, uint256 underlyingAmount)
        internal
    {
        CTokenInterface cToken = CTokenInterface(cTokenAddress);
        address underlyingAddress = cToken.underlying();
        IERC20(underlyingAmount).approve(cTokenAddress, underlyingAmount);
        uint256 result = cToken.repayBorrow(underlyingAmount);
        require(result == 0, "cToken#borrow() failed");
    }

    function claimComp() internal {
        comptroller.claimComp(address(this));
    }

    function getCompAddress() internal view returns (address) {
        return comptroller.getCompAddress();
    }

    function getcTokenBalance(address cTokenAddress)
        public
        view
        returns (uint256)
    {
        return CTokenInterface(cTokenAddress).balanceOf(address(this));
    }

    function getBorrowBalance(address cTokenAddress) public returns (uint256) {
        return
            CTokenInterface(cTokenAddress).borrowBalanceCurrent(address(this));
    }
}
