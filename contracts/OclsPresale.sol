pragma solidity ^0.4.11;

import "./lib/math/SafeMath.sol";
import "./lib/ownership/Ownable.sol";
import "./OclsToken.sol";

contract OclsPresale is Ownable, OclsToken {

    using SafeMath for uint256;
    
    address public ethFundDepositAddress;   // The address for eth funding deposits
    address public owner;                                     // The owner of the OclsPresalePreSale contract
    mapping (address => bool) public whiteList;
    bool isFinalized;
    uint256 price = 1 * 10e15;
    uint256 treshold1;
    uint256 treshold2;


    // presale parameters
    // Minimum goal with regards to funding of the presale
    uint256 public constant presaleMinLimit = 250 ether;
    // Maximum goal with regards to funding of the presale
    uint256 public constant presaleMaxLimit = 1500 ether;
    // Minimum contribution per person
    uint256 public constant minContribution = 10 ether;
    // Maximum contribution per person
    uint256 public constant maxContribution = 150 ether;
    /// Total amount of tokens allocated for the Presale
    uint256 public presaleSupply;

    /// @notice This will keep track of all contributions from participants
    /// @dev compliant with ERC20 token standard,
    /// etherscan should recognize and show the balance of the address
    mapping (address => uint256) public contributions;


    // events
    event Contribution(address indexed _to, uint256 _value);

    // @dev constructor
    function OclsPresale(
      address _ethFundDepositAddress, 
      uint256 _treshold1,
      uint256 _treshold2
      ) {
       //controls Presale through crowdsale state
      ethFundDepositAddress = _ethFundDepositAddress;
      isFinalized = false;
      owner = msg.sender;
      treshold1 = _treshold1.mul(10e18);
      treshold2 = _treshold2.mul(10e18);
    }

      /// @notice Participants sends a contribution to the eth funding address
      /// @notice Only contributing of above 5 eth and below 150 eth will be accepted, else refunded.
      /// @notice Contribution will be rejected if the maximum funding of the presale has been collected.

    function () payable {
      uint256 checkedSupply = SafeMath.add(presaleSupply, msg.value);
        uint256 priceWithDiscount = price;
        uint256 value = 0;     
        require (msg.value >= minContribution);                      // The contributing amount needs to be above 5 Eth
        require (contributions[msg.sender] <= maxContribution);      // The contributing amount needs to be below 150 Eth
        require (!isFinalized);                                      // Cannot accept Eth after the contract has been finalized
        require (checkedSupply <= presaleMaxLimit);                                                            // checkedSupply must be smaller than the presale cap for finalization to be false
        require (whiteList[msg.sender] == true);
        contributions[msg.sender] = SafeMath.add(balances[msg.sender], msg.value);
        Contribution(msg.sender, msg.value);
        if (msg.value <= treshold1) {
          priceWithDiscount = price.sub(price.div(5));
          value = msg.value.div(priceWithDiscount);                   //20% discount on original price
        } else if (msg.value <= treshold2) {
          priceWithDiscount = price.sub((price.div(10)).mul(3));
          value = msg.value.div(priceWithDiscount);  
        } else {
          priceWithDiscount = price.sub((price.div(5)).mul(2));
          value = msg.value.div(priceWithDiscount);
        }
        require(balances[this] >= value);
        balances[msg.sender] = balances[msg.sender].add(value);
        balances[this] = balances[this].sub(value);
        Transfer(this, msg.sender, value);
    }

    function checkPresaleSupply() returns (uint256) {
      return balances[this];
    }

    // @dev functionality to whitelist an investors Ethereum address to the presale
    function addToWhiteList(address _whitelisted) onlyOwner {
      whiteList[_whitelisted] = true;
    }

    // @dev functionality to remove whitelisted investors Ethereum address from the presale
    function removeFromWhiteList(address _whitelisted) onlyOwner {
      whiteList[_whitelisted] = false;
    }

    /// @dev Finalizes the presale and sends the funded eth to the multi-sig address of the team
    function finalize() external onlyOwner {
      require (!isFinalized);
      isFinalized = true;                           // move to operational state
      ethFundDepositAddress.transfer(this.balance); // sends the funded eth amount to the OCLS multi-sig
    }
}
