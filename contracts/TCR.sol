pragma solidity ^0.5.1;


contract TokenCuratedRegistry {
    
    address public owner;
    struct CandidateInfo {
        address owner; 
        string domainName;
        string title;
        string author;
        string org;
        bool isListed;
    } //candidate details
    struct Voter {
        address owner;
        string stance;
        bool hasVoted;
    }
    mapping(address => bool) beenListed;
    mapping(address => uint256) public balanceOf; //balance of tokens for each address
    mapping(address => uint256) public depositedBalance; //stake 
    mapping(address => uint8) public indexOfListing; //listing position in the array
    
    
    CandidateInfo[10] public allCandidates;
    Voter[5] public allVoters;
    uint256 public listingCost;
    uint256 public tokenPrice;
    uint8 public count = 0;
    uint8 public forvar = 0;
    uint8 public againstvar = 0;
    
    
    constructor (uint256 _listingCost, uint256 _tokenPrice) public {
        owner = msg.sender;
        balanceOf[address(0)] = 1000000000000;
        listingCost = _listingCost;
        tokenPrice = _tokenPrice;
        
    }
    
    function _transfer(address to, address sender, uint256 amt) internal {
        require(balanceOf[sender] >= amt, "Error: you don't have enough tokens for that");
        balanceOf[to] += amt;
        balanceOf[sender] -= amt;
        
    }
    
    function buyTokens() public payable {
        require(msg.value >= tokenPrice, "Error: you must send enough ether");
        require(balanceOf[address(0)] >= msg.value / tokenPrice, "Error not enough tokens for sale");
        _transfer(msg.sender, address(0), msg.value / tokenPrice);
    }
    
    function tranferTokens(address to, uint256 amt) public {
        require(balanceOf[msg.sender] >= amt, "Error: not enough tokens to do that");
        _transfer(to, msg.sender, amt);
    }
    
    function getFreeListingIndex() public view returns (uint8) {
        for (uint8 i =0; i<10; i++){
            if (allCandidates[i].isListed == false)
            return i;
            }
        revert("Error: no free listing");
    }
    
    function getFreeVotingIndex() public view returns (uint8) {
        for (uint8 i =0; i<5; i++){
            if (allVoters[i].hasVoted == false)
            return i;
            }
        revert("Error: all votes are done");
    }
    
    function getListed(
        string memory domainName,
        string memory title,
        string memory author,
        string memory org) public {
            
            require(balanceOf[msg.sender] >= listingCost, "Error: not enough tokens to get listed");
            require(depositedBalance[msg.sender] != listingCost, "Error: a single address cannot list more than one candidate");
            uint8 freeIndex = getFreeListingIndex();
            
            indexOfListing[msg.sender] -= freeIndex;
            balanceOf[msg.sender] -= listingCost;
            depositedBalance[msg.sender] += listingCost;
            
            allCandidates[freeIndex].owner = msg.sender;
            allCandidates[freeIndex].domainName = domainName;
            allCandidates[freeIndex].title = title;
            allCandidates[freeIndex].author = author;
            allCandidates[freeIndex].org = org;
            allCandidates[freeIndex].isListed = true;
        }
        
        function removeListing() public {
            require(depositedBalance[msg.sender] == listingCost, "Error: you must have a listing to remove one");
            uint8 index = indexOfListing[msg.sender];
            delete allCandidates[index];
            balanceOf[msg.sender] += listingCost;
            depositedBalance[msg.sender] -= listingCost;
        }
        
        function getListing(uint8 listIndex) public view returns(address owner,
        string memory domainName,
        string memory title,
        string memory author,
        string memory org) {
            require(allCandidates[listIndex].isListed == true, "Error: nothing listed at this index");
            return (
                allCandidates[listIndex].owner, 
                allCandidates[listIndex].domainName, 
                allCandidates[listIndex].title,
                allCandidates[listIndex].author,
                allCandidates[listIndex].org);
        }
        
        function Vote(string memory stance) public {
            require(balanceOf[msg.sender]>0, "Error: you must have enough tokens to vote");
            uint8 freeIndex = getFreeVotingIndex();
            balanceOf[msg.sender] -= 1;
            allVoters[freeIndex].owner = msg.sender;
            allVoters[freeIndex].stance = stance;
            allVoters[freeIndex].hasVoted = true;
            if(keccak256(abi.encodePacked((stance))) == keccak256(abi.encodePacked(("for")))){
            count = count+1;
            forvar = forvar +1;
            }
            else if(keccak256(abi.encodePacked((stance))) == keccak256(abi.encodePacked(("against")))){
            count = count-1;
            againstvar = againstvar+1;
            }
            
        }
        
        function EndVote() public{
        
            if(count<=0){
                removeListing();
                for(uint8 i=0;i<5;i++){
                    if(keccak256(abi.encodePacked((allVoters[i].stance))) == keccak256(abi.encodePacked(("against"))))
                        balanceOf[allVoters[i].owner] += listingCost/againstvar;
                    }
                }
            else if(count>0)
                for(uint8 i=0;i<5;i++){
                    if(keccak256(abi.encodePacked((allVoters[i].stance))) == keccak256(abi.encodePacked(("for"))))
                        balanceOf[allVoters[i].owner] += listingCost/forvar;
                    }
                
            }
            }
        
        
            
        
        
        
