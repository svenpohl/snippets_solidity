/*

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

Example and demonstration of a tokensale contract for the "Lovecoin"-Token.
"Hypothetical" SmartContract - 25.Jan.2018 Sven Pohl

NOT TESTED !!! - DO NOT USE THIS SOURCE FOR LIVE-ICO's

*/
pragma solidity ^0.4.19;



/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


// We need this interface to interact with out ERC20 - tokencontract
contract ERC20Interface {
      function totalSupply() public constant returns (uint);
      function balanceOf(address tokenOwner) public constant returns (uint balance);
      function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
      function transfer(address to, uint tokens) public returns (bool success);
      function approve(address spender, uint tokens) public returns (bool success);
      function transferFrom(address from, address to, uint tokens) public returns (bool success);
 
      event Transfer(address indexed from, address indexed to, uint tokens);
      event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
 } 


// ---
// Main tokensale class
//
contract Tokensale
{
using SafeMath for uint256;

address public owner;                  // Owner of this contract, may withdraw ETH and kill this contract
address public thisAddress;            // Address of this contract
string  public lastaction;             // WARNING! ONLY FOR TESTING PURPOSE, VALUES FAST CHANGING 
uint256 public constant RATE = 640000; // 1 ETH = 640000 LOV-Tokens
uint256 public raisedAmount     = 0;   // Raised amount in ETH
uint256 public available_tokens = 0;   // Last number of available_tokens BEFORE last payment

uint256 public lasttokencount;         // Last ordered token
bool    public last_transfer_state;    // Last state (bool) of token transfer



// ---
// Construktor
// 
function Tokensale () public
{
owner       = msg.sender;
thisAddress = address(this);
} // Construktor


 
 



// ---
// Pay ether to this contract and receive your tokens
//
function () payable public
{
address tokenAddress = 0x26B1FBE292502da2C8fCdcCF9426304d0900b703;
ERC20Interface loveContract = ERC20Interface(tokenAddress); // LOV's is 0x26B1FBE292502da2C8fCdcCF9426304d0900b703


//
// Minimum = 0.00125 ETH
//
if ( msg.value >= 1250000000000000 )
   {
   // Calculate tokens to sell
   uint256 weiAmount = msg.value;
   uint256 tokens = weiAmount.mul(RATE);
    
   // Our current token balance
   available_tokens = loveContract.balanceOf(thisAddress);    
    
   
   if (available_tokens >= tokens)
      {      
      
      	  lasttokencount = tokens;   
      	  raisedAmount   = raisedAmount.add(msg.value);
   
          // Send tokens to buyer
          last_transfer_state = loveContract.transfer(msg.sender,  tokens);
          
          if (!last_transfer_state)
             {
             revert();
             } else
               {
               lastaction = "Token transfer completed";
               }
      
      } // if (available_tokens >= tokens)
      else
          {
          revert();
          }
   
   
   
   } // if ( msg.value >= 1250000000000000 )
   else
       {
       revert();
       }





} // ()
 



//
// owner_withdraw - Ether withdraw (owner only)
//
function owner_withdraw () public
{
if (msg.sender != owner) return;

owner.transfer( this.balance );
lastaction = "Withdraw";  
} // owner_withdraw



//
// Kill (owner only)
//
function kill () public
{
if (msg.sender != owner) return;

owner.transfer( this.balance );
selfdestruct(owner);
} // kill


} /* contract Tokensale  */