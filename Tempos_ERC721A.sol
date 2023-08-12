// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "https://github.com/chiru-labs/ERC721A/blob/main/contracts/ERC721A.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Tempos is ERC721A, Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenSupply;

    uint256 public constant MAX_SUPPLY = 1000;
    uint256 public constant PRICE = 0.20 ether;

    bool public saleIsActive = false;
    string private _baseTokenURI;

    bool public revealed = false;
    mapping(address => uint256) public allowlist;

    constructor() ERC721A("Tempos", "TEMPOS") {}

    function getMaxAmount() public view returns (uint256) {
        require(_tokenSupply.current() < MAX_SUPPLY, "Sale has ended, no more items left to mint.");
        return 10;
    }

    function currentPrice() public view returns (uint256) {
        return PRICE;
    }

    function mint(uint256 _numberOfTokens) public payable nonReentrant {
        require(saleIsActive, "TEMPOS is not for sale yet!");
        uint256 mintIndex = _tokenSupply.current();
        require(mintIndex < MAX_SUPPLY, "Tempos supply is sold out!");
        uint256 mintPrice = currentPrice() * _numberOfTokens;
        require(msg.value >= mintPrice, "Not enough ETH to buy a TEMPOS!");
        require(_numberOfTokens > 0 && _numberOfTokens <= getMaxAmount(), "You are not allowed to mint this many TEMPOS at once.");

        for (uint256 i = 0; i < _numberOfTokens; i++) {
            _tokenSupply.increment();
            _safeMint(msg.sender, _tokenSupply.current());
        }
    }

    function setBaseURI(string memory _baseURI) external onlyOwner {
        _baseTokenURI = _baseURI;
    }

    // Override or implement additional logic if ERC721A defines a method for token URIs

    function toggleSale() public onlyOwner {
        saleIsActive = !saleIsActive;
    }

    function withdrawBalance() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
}
