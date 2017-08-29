pragma solidity ^0.4.15;

import "./lib/token/StandardToken.sol";
import "./lib/ownership/Ownable.sol";
import "./lib/math/SafeMath.sol";

/**
 * @title StandardToken
 * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `StandardToken` functions.
 */

contract OclsToken is StandardToken, Ownable {

  using SafeMath for uint256;

  string public constant name = "OCLS Token";
  string public constant symbol = "OCLS";
  uint256 public constant decimals = 18;
  uint256 public constant initial_supply = 200000000 * 10**18;

  address public owner;

  /**
   * @dev Contructor that gives msg.sender all of existing tokens.
   */
  function OclsToken( ) {
    totalSupply = initial_supply;
    balances[msg.sender] = initial_supply;
    owner = msg.sender;
  }

}
