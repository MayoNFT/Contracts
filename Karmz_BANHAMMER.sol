// SPDX-License-Identifier: MIT

/**
    
*/

// Amended by Ayyyliens_NFT

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract Karmz is ERC721, Ownable {
  using Strings for uint256;
  using Counters for Counters.Counter;

  Counters.Counter private supply;

  string public uriPrefix = "";
  string public uriSuffix = ".json";
  
  uint256 public MAX_SUPPLY = 3333;
  uint256 MINT_SUPPLY;
  
  mapping(address => uint256) CLAIMED_MINTS;
  mapping(uint256 => bool) BAN_HAMMER;

  bool public paused = false;

  constructor() ERC721("Karmz", "KRMZ") {
    
  }

// Supply -------------------------------------------------

  function totalSupply() public view returns (uint256) {
    return supply.current();
  }

// MINT FUNCTIONS -------------------------------------------------

  modifier mintCompliance(uint256 NUMBER_OF_TOKENS) { 
    require(supply.current() + NUMBER_OF_TOKENS <= MAX_SUPPLY, "Max supply exceeded!");
    require(NUMBER_OF_TOKENS > 0, "Invalid mint amount!");
    _;
  }

  function _mintLoop(address _receiver, uint256 NUMBER_OF_TOKENS) internal {
    for (uint256 i = 0; i < NUMBER_OF_TOKENS; i++) {
      supply.increment();
      _safeMint(_receiver, supply.current());
    }
  }

  function mint(uint256 NUMBER_OF_TOKENS) public payable mintCompliance(NUMBER_OF_TOKENS) {
        uint256 FREE_MINTS = IERC721(0xD396706543979149f7510839E9EB0B0608E8bc23).balanceOf(msg.sender);
        uint256 TOKEN_COUNT = CLAIMED_MINTS[msg.sender];
    require(!paused, "The contract is paused!");
    require(FREE_MINTS >= 1, "You don't own any Karmeleons");
    require(TOKEN_COUNT + NUMBER_OF_TOKENS <= FREE_MINTS, "Max per free mint exceeded");
        for(uint i=0; i < FREE_MINTS; i++) {
                uint256 TOKEN_ID = IERC721Enumerable(0xD396706543979149f7510839E9EB0B0608E8bc23).tokenOfOwnerByIndex(msg.sender, i);
                require(BAN_HAMMER[TOKEN_ID] != true, "This Karmeleon has been banned from minting");}
    
        CLAIMED_MINTS[msg.sender] += NUMBER_OF_TOKENS;
    _mintLoop(msg.sender, NUMBER_OF_TOKENS);
    
}
            
  function mintForAddress(uint256 NUMBER_OF_TOKENS, address _receiver) public mintCompliance(NUMBER_OF_TOKENS) onlyOwner {
    _mintLoop(_receiver, NUMBER_OF_TOKENS);
  }

// Sale Functions -------------------------------------------------

  function setPaused(bool _state) public onlyOwner {
    paused = _state;
  }

// BAN HAMMER -------------------------------------------------
  
  function setBANHAMMER(uint256 TOKEN_ID, bool STATUS) public onlyOwner {
    BAN_HAMMER[TOKEN_ID] = STATUS;
  }

// URI Functions -------------------------------------------------  

  function setUriPrefix(string memory _uriPrefix) public onlyOwner {
    uriPrefix = _uriPrefix;
  }

  function setUriSuffix(string memory _uriSuffix) public onlyOwner {
    uriSuffix = _uriSuffix;
  }

// Public Functions -------------------------------------------------

    function ClaimedMINTS(address owner) external view returns (uint256) {
        return CLAIMED_MINTS[owner];
    }

    function RemainingMINTS(address owner) external view returns (uint256) {
        uint256 FREE_MINTS = IERC721(0xD396706543979149f7510839E9EB0B0608E8bc23).balanceOf(owner);
        uint256 REMAINING_MINTS = FREE_MINTS -= CLAIMED_MINTS[owner];
        return REMAINING_MINTS;
    }

  function walletOfOwner(address _owner)
    public
    view
    returns (uint256[] memory)
  {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory ownedTokenIds = new uint256[](ownerTokenCount);
    uint256 currentTokenId = 1;
    uint256 ownedTokenIndex = 0;

    while (ownedTokenIndex < ownerTokenCount && currentTokenId <= MAX_SUPPLY) {
      address currentTokenOwner = ownerOf(currentTokenId);

      if (currentTokenOwner == _owner) {
        ownedTokenIds[ownedTokenIndex] = currentTokenId;

        ownedTokenIndex++;
      }

      currentTokenId++;
    }

    return ownedTokenIds;
  }

  function tokenURI(uint256 _tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(_tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, _tokenId.toString(), uriSuffix))
        : "";
  }

  function _baseURI() internal view virtual override returns (string memory) {
    return uriPrefix;
  }

// Withdraw -------------------------------------------------

    function withdraw() public onlyOwner {
    (bool os, ) = payable(owner()).call{value: address(this).balance}("");
    require(os);
  }
}
