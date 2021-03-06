pragma solidity 0.4.24;

import "../CtfFramework.sol";
import "../../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract TrustFund is CtfFramework{

    using SafeMath for uint256;

    uint256 public allowancePerYear;
    uint256 public startDate;
    uint256 public numberOfWithdrawls;
    bool public withdrewThisYear;
    address public custodian;

    constructor(address _ctfLauncher, address _player) public payable
        CtfFramework(_ctfLauncher, _player)
    {
        custodian = msg.sender;
        allowancePerYear = msg.value.div(10);        
        startDate = now;
    }

    function checkIfYearHasPassed() internal{
        if (now>=startDate + numberOfWithdrawls * 365 days){
            withdrewThisYear = false;
        } 
    }

    function withdraw() external ctf{
        require(allowancePerYear > 0, "No Allowances Allowed");
        checkIfYearHasPassed();
        require(!withdrewThisYear, "Already Withdrew This Year");
        if (msg.sender.call.value(allowancePerYear)()){
            withdrewThisYear = true;
            numberOfWithdrawls = numberOfWithdrawls.add(1);
        }
    }
    
    function returnFunds() external payable ctf{
        require(msg.value == allowancePerYear, "Incorrect Transaction Value");
        require(withdrewThisYear==true, "Cannot Return Funds Before Withdraw");
        withdrewThisYear = false;
        numberOfWithdrawls=numberOfWithdrawls.sub(1);
    }
}