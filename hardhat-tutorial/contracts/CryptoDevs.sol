//SPDX-Licence-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol" ;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IWhitelist.sol";
contract CryptoDevs is ERC721Enumerable,Ownable {
    string _baseTokenURI;
    uint256 public _price = 0.01 ether;
    bool public _paused;
    uint256 public maxTokenIds = 20;
    uint256 public tokensIds;
    IWhitelist whitelist;
    bool public presaleStarted;
    uint256 public presaleEnded;
    modifier onlyWhenNotPaused {
        require(!_paused,"Contract currently paused");
        _;
    }
    constructor (string memory baseURI,address whitelistContracts) ERC721("CryptoDevs","CD"){
        _baseTokenURI = baseURI;
        whitelist = IWhitelist(whitelistContracts);
    }
    function startPresale() public onlyOwner {
        presaleStarted = true;
        presaleEnded = block.timestamp + 5 minutes;

    }
    function presaleMint() public payable onlyWhenNotPaused{
        require(presaleStarted && block.timestamp < presaleEnded,"Presale is not running");
        require(whitelist.whitelistedAddresses(msg.sender),"You are not whitelisted");
        require(tokensIds < maxTokenIds,"Exceeds maximim Cryprto Devs supply");
        require(msg.value >= _price,"Ether sent is not corresct");
        tokensIds +=1;
        _safeMint(msg.sender,tokensIds);
    }
    function mint() public payable onlyWhenNotPaused{
        require(presaleStarted && block.timestamp >= presaleEnded,"Presale is not ended yet");
        require(tokensIds < maxTokenIds,"Exceed maximum Crypto Devs Suppply");
        require(msg.value >= _price,"Ehter sent is not correct");
        tokensIds += 1;
        _safeMint(msg.sender,tokensIds);
    }
    function _baseURI() internal view virtual override returns (string memory){
        return _baseTokenURI;
    }
    function setPaused(bool val) public onlyOwner{
        _paused = val;
    }
    function withhdraw() public onlyOwner{
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) = _owner.call{value:amount}("");
        require(sent,"Failed to sent ether");
    }
    receive() external payable {}
    fallback() external payable {}
}


