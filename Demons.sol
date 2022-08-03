pragma solidity ^0.8.0;
contract Demons_wth {




    string public standard = 'Demons_wth';
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    uint public nextPunkIndexToAssign = 0;

    bool public allPunksAssigned = false;
    uint public punksRemainingToAssign = 0;

    //mapping (address => uint) public addressToPunkIndex;
    mapping (uint => address) public punkIndexToAddress;

    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;

    struct Offer {
        bool isForSale;
        uint punkIndex;
        address seller;
        uint minValue;          // in ether
        address onlySellTo;     // specify to sell only to a specific person
    }


   
    mapping (uint => Offer) public punksOfferedForSale;

   
   

    mapping (address => uint) public pendingWithdrawals;

    uint256 public constant DemonPrice = 80000000000000000; 

    uint public constant maxDemonPurchase = 2000;

    uint256 public MAX_DEMONS;

    event Assign(address indexed to, uint256 punkIndex);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event PunkTransfer(address indexed from, address indexed to, uint256 punkIndex);
    event PunkOffered(uint indexed punkIndex, uint minValue, address indexed toAddress);
    event PunkBought(uint indexed punkIndex, uint value, address indexed fromAddress, address indexed toAddress);
    event PunkNoLongerForSale(uint indexed punkIndex);
    event ATransfer(uint indexed Index);

   
    function Demons() public payable {
       
        totalSupply = 10000;                       
        punksRemainingToAssign = totalSupply;
        name = "DEMONS.WTH";                                
        symbol = "DEMONSWTH";                             
        decimals = 0;                                     
    }

    function transferPunk(address to, uint punkIndex) public {
        require(allPunksAssigned);
        require(punkIndexToAddress[punkIndex] == msg.sender);
        require(punkIndex<=20000,"Token doesnt exist");
        if (punksOfferedForSale[punkIndex].isForSale) {
            NoLonger(punkIndex);
        }
        punkIndexToAddress[punkIndex] = to;
        balanceOf[msg.sender]--;
        balanceOf[to]++;
        emit ATransfer(punkIndex);
        emit PunkTransfer(msg.sender, to, punkIndex);
    }

    function Draw(Offer memory set, uint tIndex) public payable {
        Offer memory owner = punksOfferedForSale[tIndex];
        require(owner.isForSale,"Not allowed");
        require(owner.onlySellTo == address(0x0) && owner.onlySellTo == msg.sender,"Not allowed");
        require(msg.value > owner.minValue,"Not sufficient");

        address seller = owner.seller;

        punkIndexToAddress[tIndex] = msg.sender;
        balanceOf[seller]--;
        balanceOf[msg.sender]++;
        emit Transfer(seller, msg.sender, 1);

        NoLonger(tIndex);
        pendingWithdrawals[seller] += msg.value;
        emit PunkBought(tIndex, msg.value, seller, msg.sender);
    }

     function OFS(uint tIndex, uint minSalePriceInWei) public {
        require(punkIndexToAddress[tIndex] == msg.sender,"Not allowed");
        require(tIndex < 20000,"Toke doesn't exist");
        punksOfferedForSale[tIndex] = Offer(true, tIndex, msg.sender, minSalePriceInWei, address(0x0));
        emit PunkOffered(tIndex, minSalePriceInWei, address(0x0));
    }

    function NoLonger(uint tIndex) public {
        require(punkIndexToAddress[tIndex] == msg.sender);
        require(tIndex <= 20000,"Token doesnt exist");
        punksOfferedForSale[tIndex] = Offer(false, tIndex, msg.sender, 0, address(0x0));
        NoLonger(tIndex);
    }
    

    function withdraw() private {
        uint amount = pendingWithdrawals[msg.sender];
        // Remember to zero the pending refund before
        // sending to prevent re-entrancy attacks
        pendingWithdrawals[msg.sender] = 0;
        msg.sender.transfer(amount);
    }
}
