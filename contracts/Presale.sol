pragma solidity 0.8.0;

import 'OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol';
//import './Token.sol';
interface tokens{
    function transfer(address receiver , uint amount) external;
}

contract Crowdsale {
    
    using SafeMath for uint256;
    
    address public beneficiary; //who is selling tokens
    uint public fundingGoal; //target
    uint public amountRaised; //funds get
    uint public deadline; //duration of presale
    uint public price; //setting price for tokens
     // BEP20Token public tokenReward;
    tokens public tokenReward;
    mapping(address => uint256) public balancOf;
    bool fundingGoalReached;
    bool crowdsaleClosed;
   uint public time = now; 
 
    
    event GoalReached(address recipient , uint totalAmountRaised);
    event FundTransfer(address backer, uint amount , bool isContribution);
    
/*function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
*/
    constructor (
        address ifSuccessfulSendTo, 
        uint funding_Goal_InBNB,
        uint duration_In_Mnutes,
        uint BNBCost_ForEach_Token,
        address addressOf_TokenUsed_As_Reward
        )public {
        
        beneficiary = ifSuccessfulSendTo;
        //price taken in ether so 1BNB = 0.131247 Ethers
        fundingGoal = funding_Goal_InBNB * 1 wei;
        //fundingGoal = funding_Goal_InBNB * (0.131247 * 1 ether);
         deadline = now + duration_In_Mnutes * 1 days;
        //deadline = now + duration_In_Mnutes * 1 seconds;
        price = BNBCost_ForEach_Token * 1 wei;
        //price = BNBCost_ForEach_Token * (0.131247 * 1 ether);
        //tokenReward = BEP20Token(addressOf_TokenUsed_As_Reward);
        tokenReward = tokens(addressOf_TokenUsed_As_Reward);
    }

    function TimeLeft() public view returns(uint) {
        return deadline - block.timestamp;
    }
    
  /* function buy(uint amt) payable public{
        require(!crowdsaleClosed,"crowdsaleClosed");
        uint amount = amt;
        balancOf[msg.sender] += amount;
        amountRaised += amount;
        tokenReward.transfer(msg.sender ,amount);
        emit FundTransfer(msg.sender, amount , true);
    }*/

    //fallback function
    function () payable public {
        require(crowdsaleClosed == false,"crowdsaleClosed");
        uint256 amount = div(msg.value, price,"not divided"); 
        balancOf[msg.sender] += amount;
        amountRaised += amount;
        tokenReward.transfer(msg.sender, amount);
        emit FundTransfer(msg.sender, amount , true);
    }
    
    modifier afterDeadline(){
        if(now >= deadline)
        _;
    }
    
    function checkGoalReached() afterDeadline public  {
        if(amountRaised>=fundingGoal){
            fundingGoalReached = true;
            emit GoalReached(beneficiary , amountRaised);
        }
            crowdsaleClosed = true;
            
    }
    
    function safeWithdrawl() public afterDeadline{
        if(!fundingGoalReached){
           uint amount = balancOf[msg.sender];
           balancOf[msg.sender] = 0;
           if(amount > 0 ){
               if(msg.sender.send(amount)){
                   emit FundTransfer(msg.sender,amount, false);
               }
               else{
                   balancOf[msg.sender] = amount;
               }
           }
        }
        if(fundingGoalReached && beneficiary == msg.sender){
            if(beneficiary.send(amountRaised)){
                emit FundTransfer(beneficiary, amountRaised,false);
            }
            else{
                fundingGoalReached = false;
            }
        }
    }
    
}