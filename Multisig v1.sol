ragma solidity ^0.8.11;

contract Multisig {  
    event Deposit(address indexed sender, uint amount, uint balance);
    event Submittx(
        address indexed owner,
        uint indexed txindex,
        address indexed to,
        uint value,
        bytes data
    );
    event Confirmtx (address indexed owner, uint indexed txindex);
    event Revokeconfirmation (address indexed owner, uint indexed txindex);
    event Executetx (address indexed owner, uint indexed txindex);

    address[] public owners;
    mapping (address => bool) isowner;
    uint public reqconf;
    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
        uint numconf; 
    }
    mapping(uint => mapping( address => bool)) public isconf;
    Transaction[] public trax;

    modifier onlyOwner() {
        require(isowner[msg.sender], "not owner");
        _;
    }
    modifier txExists(uint _txIndex) {
        require(_txIndex < trax.length, "tx does not exist");
        _;
    }
     modifier notExecuted(uint _txIndex) {
        require(!trax[_txIndex].executed, "tx already executed");
        _;
    }
    modifier notConfirmed(uint _txIndex) {
        require(!isconf[_txIndex][msg.sender], "tx already confirmed");
        _;
    }

    constructor (address[] memory _owners, uint _reqconf){
        require(_owners.length >0, "owner required");
        require(_reqconf >0 && _reqconf <= _owners.length);
        for (uint i=0; i<_owners.length; i++){
            address owner= _owners[i];
            require(owner!=address(0), "invalid owner");
            require(!isowner[owner],"owner not unique");
            isowner[owner]=true;
            owners.push(owner);
        }
        reqconf=_reqconf;

    }
    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
        }

    function proposetx(address _to, uint _value, bytes memory _data) public onlyOwner {
        uint txindex = trax.length;

        trax.push(
            Transaction({
                to: _to,
                value: _value,
                data: _data,
                executed: false,
                numconf: 0
            })
        );
        emit Submittx(msg.sender, txindex, _to, _value, _data);
    }
    
    function confirmtx(uint _txindex)public
        onlyOwner
        txExists(_txindex)
        notExecuted(_txindex)
        notConfirmed(_txindex)
    {
        Transaction storage transaction = trax[_txindex];
        transaction.numconf +=1;
        isconf[_txindex][msg.sender]=true;
        emit Confirmtx(msg.sender, _txindex);
    }
    function executetx(uint _txindex)public 
        txExists(_txindex)
        notExecuted(_txindex)
    {
        Transaction storage transaction=trax[_txindex];
        require(transaction.numconf>=reqconf,"cannot execute tx");
        transaction.executed=true;
        (bool success,)=transaction.to.call{value:transaction.value}(transaction.data);
        require(success,"tx failed");
        emit Executetx(msg.sender,_txindex);

    }
    function deposit()payable external{
        emit Deposit(msg.sender,msg.value,address(this).balance);
    }
}
