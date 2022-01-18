 pragma solidity ^0.8.11;
contract loancontract{
//should be able to collect money
//should be able to alocate money to a loan
//keep track of all loans and every individuals contribution
//calculating interest 
//status of loan default, completed, running
//keep track of repayment and maintain loan
//change interest rate
//Borrower should create loan
    uint interestrate;
    address owner;
    struct Loan {
        address borroweraddress;
        uint loantime;
        uint loanterm;
        uint loanamt;
        uint colateral;
        uint fundscollected;
        bool loanstatus;
        bool loansuccess;
    }
    Loan[] public loans;
    mapping(address=>uint)balance;
    mapping(uint=>mapping(address=>uint)) public loanbook;//map loan id to lender address and amount.   
    constructor (uint _interestrate){
        interestrate=_interestrate;
        owner=msg.sender;
    }
    function openloan(uint _amt,uint _term, uint _colateral)public payable {
        //amt term cannot be 0,
        uint loanindex=loans.length;
        transfertoken (msg.sender,this,_colateral);//should transfer colateral from borrower to the smart contract and also ensure success befor moveing forward.
        
        loans.push(
            Loan({
                borroweraddress: msg.sender,
                loantime: block.timestamp,
                loanterm: _term,
                loanamt: _amt,
                colateral: _colateral,
                fundscollected:0,
                loanstatus: true,
                loansuccess:false
            })
        );// should save this loan in the array of struct 
    }
    function transfertoken(address _from, address _to, uint amt) public returns (bool){

    }
    function pledge(uint loanid, uint _amt)private{
        require(loans[loanid].loanstatus=true,"loan is not open to invest");  
        loans[loanid].fundscollected+=_amt;
        
        if (loans[loanid].fundscollected>=loans[loanid].loanamt){
            //transfer fundscollected= from liquiditypool to borrower
            loans[loanid].loantime=block.timestamp;
            loans[loanid].loanstatus= false;                    
        }
    } 
}  
