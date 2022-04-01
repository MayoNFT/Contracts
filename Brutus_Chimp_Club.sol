// SPDX-License-Identifier: MIT

/**
           .-""""-.       .-""""-.
          /        \     /        \
         /_        _\   /_        _\
        // \      / \\ // \      / \\
        |\__\    /__/| |\__\    /__/|
         \    ||    /   \    ||    /
          \        /     \        /
           \  __  /       \  __  /
   .-""""-. '.__.'.-""""-. '.__.'.-""""-.
  /        \ |  |/        \ |  |/        \
 /_        _\|  /_        _\|  /_        _\
// \      / \\ // \      / \\ // \      / \\
|\__\    /__/| |\__\    /__/| |\__\    /__/|
 \    ||    /   \    ||    /   \    ||    /
  \        /     \        /     \        /
   \  __  /       \  __  /       \  __  /
    '.__.'         '.__.'         '.__.'
ayyy |  |           |  |           |  |
     |  |           |  |           |  |

         Amended by AyyyliensNFT

$$$$$___ ______ _______ _$$__ _______ ______ ____$$$$_ $$_____ _$$__ _________ _______ ____$$$$_ $$__ _______ $$_____
$$__$$__ ______ _______ _$$__ _______ _$$$$_ ___$$____ $$_____ _$$__ _________ _$$$$__ ___$$____ $$__ _______ $$_____
$$$$$___ $$_$$_ $$__$$_ $$$$_ $$__$$_ $$____ __$$_____ $$_____ _____ $$$$_$$__ $$__$$_ __$$_____ $$__ $$__$$_ $$$$$__
$$___$$_ $$$_$_ $$__$$_ _$$__ $$__$$_ _$$$__ __$$_____ $$$$$__ _$$__ $$_$$_$$_ $$__$$_ __$$_____ $$__ $$__$$_ $$__$$_
$$___$$_ $$____ $$__$$_ _$$__ $$__$$_ ___$$_ ___$$____ $$__$$_ _$$__ $$_$$_$$_ $$$$$__ ___$$____ $$__ $$__$$_ $$__$$_
$$$$$$__ $$____ _$$$_$_ __$$_ _$$$_$_ $$$$__ ____$$$$_ $$__$$_ $$$$_ $$_$$_$$_ $$_____ ____$$$$_ _$$_ _$$$_$_ _$$$$__

*/

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BrutusChimpClub is ERC721, Ownable {
  using Strings for uint256;
  using Counters for Counters.Counter;

  Counters.Counter private supply;
  Counters.Counter private REDEEMED_MINTS_COUNTER;

  bool public saleIsActive = true;
  string private _baseURIextended;

  bool public isAllowListActive = true;
  uint256 public constant MAX_SUPPLY = 6000;
  uint256 public MAX_PUBLIC_MINT = 5;
  uint256 public PRICE_PER_TOKEN = 0.04 ether;
  uint256 public FREE_MINT_SUPPLY = 2000;
  uint256 public REDEEMED_MINTS;

  mapping(address => uint8) private _allowList;

  string public uriPrefix = "";
  string public uriSuffix = ".json";
  string public hiddenMetadataUri;

  bool public paused = true;
  bool public revealed = false;

  constructor() ERC721("Brutus Chimp Club", "BCC") {
    setHiddenMetadataUri("ipfs://__CID__/hidden.json");
  }

  function mintAllowList(uint8 NUMBER_OF_TOKENS) external payable {
        uint256 ts = totalSupply();
        require(isAllowListActive, "Allow list is not active");
        require(NUMBER_OF_TOKENS <= _allowList[msg.sender], "Exceeded max available free mints");
        require(NUMBER_OF_TOKENS + REDEEMED_MINTS <= FREE_MINT_SUPPLY, "Max supply of free mints claimed");
        require(ts + NUMBER_OF_TOKENS <= MAX_SUPPLY, "Purchase would exceed max tokens");
        
        REDEEMED_MINTS + NUMBER_OF_TOKENS;
        for (uint i = 0; i < NUMBER_OF_TOKENS; i++){
        REDEEMED_MINTS_COUNTER.increment();
        REDEEMED_MINTS = REDEEMED_MINTS_COUNTER.current();
        }
         _allowList[msg.sender] -= NUMBER_OF_TOKENS;
        for (uint256 i = 0; i < NUMBER_OF_TOKENS; i++) 
        {supply.increment();
            _safeMint(msg.sender, supply.current());}       
    }

    function mint(uint NUMBER_OF_TOKENS) public payable {
        uint256 ts = totalSupply();
        require(saleIsActive, "Sale must be active to mint tokens");
        require(NUMBER_OF_TOKENS <= MAX_PUBLIC_MINT, "Exceeded max token purchase");
        require(ts + NUMBER_OF_TOKENS <= MAX_SUPPLY, "Purchase would exceed max supply");
        require(PRICE_PER_TOKEN * NUMBER_OF_TOKENS <= msg.value, "Ether value sent is not correct");

        for (uint256 i = 0; i < NUMBER_OF_TOKENS; i++) {
            supply.increment();
            _safeMint(msg.sender, supply.current());
        }
    }

    function setAllowList(address[] calldata addresses, uint8 numAllowedToMint) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            _allowList[addresses[i]] = numAllowedToMint;
        }
    }

    function setIsAllowListActive(bool _isAllowListActive) external onlyOwner {
        isAllowListActive = _isAllowListActive;
    }

    function setCost(uint256 _cost) public onlyOwner {
    PRICE_PER_TOKEN = _cost;
    }

    function setSaleState(bool newState) public onlyOwner {
        saleIsActive = newState;
    }

    function setRevealed(bool _state) public onlyOwner {
    revealed = _state;
    }

    function setMaxMintAmountPerTx(uint256 _maxMintAmountPerTx) public onlyOwner {
    MAX_PUBLIC_MINT = _maxMintAmountPerTx;
    }

    function setPaused(bool _state) public onlyOwner {
        paused = _state;
    }

    function numAvailableToMint(address addr) external view returns (uint8) {
        return _allowList[addr];
    }

    function claimedFreeMints() internal view returns (uint256) {
        return REDEEMED_MINTS;
    }

    function totalSupply() public view returns (uint256) {
        return supply.current();
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

  function _baseURI() internal view virtual override returns (string memory) {
    return uriPrefix;
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

  function withdraw() public onlyOwner {
        uint balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

  function _mintLoop(address _receiver, uint256 _mintAmount) internal {
    for (uint256 i = 0; i < _mintAmount; i++) {
      supply.increment();
      _safeMint(_receiver, supply.current());
    }
  }
}
