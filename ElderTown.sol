// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract ElderTown is ERC721Enumerable, Ownable {
  using Strings for uint256;

  string private _baseTokenURI = "ipfs://QmPBYKxSU589fyURqyMxWupAszVmXoSnDt625wwYZEcaaY/";
  string private extension = ".json";
  address public admin1 = 0xFE1fB7b4bFd60c4720DA9b2f592d2bc031158ab9;
  address public admin2 = 0x54971d0BEBf8a2dDbEad21A64ba9b3F84B5783eF;
  address public admin3 = 0x1e6f1aa7d06c8a3483efed7Cf6B345c5b8D976b5;
  address public admin4 = 0x9dB36dd20A86C32779CE86821f7bb18A55AbA79e;
  address public admin5 = 0x22667dA0463755aa23947c3c754dBb8dA795b8F1;
  uint256 public constant MAX_ENTRIES = 7777;
  uint256 public constant PRESALE_ENTRIES = 2777;
  uint256 public constant PRESALE_PERIOD = 414;
  uint256 public constant PRICE = 0.0045 ether;
  uint256 public constant PRESALE_LIMIT = 2;
  uint256 public constant LIMIT_PER_TRANSACTION = 20;
  uint256 public totalMinted;
  uint public startTime;
  bool public saleStarted;
  bytes32 private root=0x1ce2e6009842f6535f7fd932f8a2a596843af312357d0c45ad607acff4c86434;

  constructor() ERC721("eldertown.wtf", "ETWTF") {
      saleStarted = false;
  }

  function mint(bytes32[] memory _proof, uint256 amount) external payable {
    uint256 value = msg.value;
    uint256 balance = balanceOf(msg.sender);
    uint256 _amount = amount;
    require(saleStarted == true, "Sale Has Not Started");
    if (block.timestamp - startTime < PRESALE_PERIOD) {
      require(MerkleProof.verify(_proof, root, keccak256(abi.encodePacked(msg.sender))) == true, "Not on whitelist");
      require(balance + _amount <= PRESALE_LIMIT, "Exceeds Max Presale Amount Per Wallet");
      require(totalMinted + _amount <= PRESALE_ENTRIES, "Exceeds Presale Amount");
    } else {
      require(_amount + totalMinted <= MAX_ENTRIES, "Exceeds Total Amounts");
      require(_amount <= LIMIT_PER_TRANSACTION, "Exceeds Max Amount Per Transaction");
      uint256 free;
      if (totalMinted < PRESALE_ENTRIES) {
        free = 1;
        if (MerkleProof.verify(_proof, root, keccak256(abi.encodePacked(msg.sender))) == true) {
          free += 2;
        }
        if (free >= balance) {
          free -= balance;
        } else {
          free = 0;
        }
        if (free > PRESALE_ENTRIES - totalMinted) {
          free = PRESALE_ENTRIES - totalMinted;
        }
      }
      if (_amount >= free) {
        _amount -= free;
      } else {
        _amount = 0;
      }
      require(value >= PRICE * _amount, "Insufficient Fund");
    }
    for (uint256 i = 0 ; i < amount ; ++i) {
      _safeMint(msg.sender, ++totalMinted);
    }
    payable(admin1).transfer(value * 3 / 10);
    payable(admin2).transfer(value * 3 / 10);
    payable(admin3).transfer(value * 225 / 1000);
    payable(admin4).transfer(value * 125 / 1000);
    payable(admin5).transfer(value * 5 / 100);
  }

  function _baseURI() internal view override returns (string memory) {
    return _baseTokenURI;
  }

  function setBaseURI(string memory baseURI) public onlyOwner {
    _baseTokenURI = baseURI;
  }

  function startSale() external onlyOwner {
    saleStarted = true;
    startTime = block.timestamp;
  }

  function getTime() external view returns(uint256) {
    return block.timestamp - startTime;
  }

  function getExtension() external view returns (string memory) {
    return extension;
  }

  function setExtension(string memory newExtension) external {
    extension = newExtension;
  }

  function setRoot(bytes32 _newRoot) external onlyOwner {
    root = _newRoot;
  }

  function tokenURI(uint256 tokenId) override public view returns (string memory) {
    require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
    return string(abi.encodePacked(_baseTokenURI, tokenId.toString(), extension));
  }
}