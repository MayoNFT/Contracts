// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
//import "@openzeppelin/contracts/utils/Strings.sol";

contract Brutus_Chimp_Club is ERC721A, Ownable {
    using Strings for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private Redeemed_Mints_Counter;

    bool public saleIsActive = true;
    string private _baseURIextended;

    bool public isAllowListActive = true;
    uint256 public constant MAX_SUPPLY = 4;
    uint256 public MAX_PUBLIC_MINT = 5;
    uint256 public PRICE_PER_TOKEN = 0.04 ether;
    uint256 public Free_Mint_Supply = 4;
    uint256 public Redeemed_Mints;

    mapping(address => uint8) private _allowList;

  string public uriPrefix = "";
  string public uriSuffix = ".json";
  string public hiddenMetadataUri;

  bool public paused = true;
  bool public revealed = false;
    

    string public baseURI = "ipfs://__CID__/hidden.json";

    constructor() ERC721A("Brutus Test", "BCC") {}

        function mintAllowList(uint8 numberOfTokens) external payable {
        uint256 ts = totalSupply();
        require(isAllowListActive, "Allow list is not active");
        require(numberOfTokens <= _allowList[msg.sender], "Exceeded max available free mints");
        require(numberOfTokens + Redeemed_Mints <= Free_Mint_Supply, "Max supply of free mints claimed");
        require(ts + numberOfTokens <= MAX_SUPPLY, "Purchase would exceed max tokens");
        
        Redeemed_Mints + numberOfTokens;
        for (uint i = 0; i < numberOfTokens; i++){
        Redeemed_Mints_Counter.increment();
        Redeemed_Mints = Redeemed_Mints_Counter.current();
        }
         _allowList[msg.sender] -= numberOfTokens;
        for (uint256 i = 0; i < numberOfTokens; i++) 
            _safeMint(msg.sender, numberOfTokens);}       
    

    function mint(uint256 quantity) external payable {
        // _safeMint's second argument now takes in a quantity, not a tokenId.
        require(quantity + _numberMinted(msg.sender) <= MAX_PUBLIC_MINT, "Exceeded the limit");
        require(totalSupply() + quantity <= MAX_SUPPLY, "Not enough tokens left");
        require(msg.value >= (PRICE_PER_TOKEN * quantity), "Not enough ether sent");
        _safeMint(msg.sender, quantity);
    }

    function Claimed_Mints() internal view returns (uint256) {
        return Redeemed_Mints;
    }
    function setSaleState(bool newState) public onlyOwner {
        saleIsActive = newState;
    }

  function setIsAllowListActive(bool _isAllowListActive) external onlyOwner {
        isAllowListActive = _isAllowListActive;
    }

    function setAllowList(address[] calldata addresses, uint8 numAllowedToMint) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            _allowList[addresses[i]] = numAllowedToMint;
        }
    }

    function numAvailableToMint(address addr) external view returns (uint8) {
        return _allowList[addr];
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

    if (revealed == false) {
      return hiddenMetadataUri;
    }

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, _tokenId.toString(), uriSuffix))
        : "";
  }

  function setRevealed(bool _state) public onlyOwner {
    revealed = _state;
  }

  function setCost(uint256 _cost) public onlyOwner {
    PRICE_PER_TOKEN = _cost;
  }

  function setMaxMintAmountPerTx(uint256 _maxMintAmountPerTx) public onlyOwner {
    MAX_PUBLIC_MINT = _maxMintAmountPerTx;
  }

  function setHiddenMetadataUri(string memory _hiddenMetadataUri) public onlyOwner {
    hiddenMetadataUri = _hiddenMetadataUri;
  }

  function setUriPrefix(string memory _uriPrefix) public onlyOwner {
    uriPrefix = _uriPrefix;
  }

  function setUriSuffix(string memory _uriSuffix) public onlyOwner {
    uriSuffix = _uriSuffix;
  }

  function setPaused(bool _state) public onlyOwner {
    paused = _state;
  }


  //function _mintLoop(address _receiver, uint256 _mintAmount) internal {
    //for (uint256 i = 0; i < _mintAmount; i++) {
     // supply.increment();
      //_safeMint(_receiver, supply.current());
    //}
  //}

  

    function withdraw() external payable onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

}
