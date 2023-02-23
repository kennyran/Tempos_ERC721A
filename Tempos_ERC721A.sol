// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "https://github.com/chiru-labs/ERC721A/blob/main/contracts/ERC721A.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Tempos is ERC721A, Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenSupply;

    // ======// Variables //======

    // Maximum amount in existance
    uint256 public constant MAX_SUPPLY = 1000;

    // Price of each NFT Mint
    uint256 public constant PRICE = 0.20 ether;

    // Toggle sale on and off
    bool public saleIsActive = false;
    string private _baseTokenURI;

    // Tempos watch art reveal
    bool public revealed = false;

    // Allowlist for presale
    mapping(address => uint256) public allowlist;

    // ======// Constructor //======
    constructor() ERC721A("Tempos", "TEMPOS") {}

    // ======// Functions //=======

    // Max amount wallet can mint per transaction
    function getMaxAmount() public view returns (uint256) {
        require(
            _tokenSupply.current() < MAX_SUPPLY,
            "Sale has ended, no more items left to mint."
        );

        return 10; // 10 mint max per wallet & transaction
    }

    // Price of mint
    function currentPrice() public view returns (uint256) {
        uint256 totalMinted = _tokenSupply.current();

        if (totalMinted <= 1000) {
            return PRICE;
        }
    }

    function mint(uint256 _numberOfTokens) public payable {
        require(saleIsActive, "TEMPOS is not for sale yet!");

        uint256 mintIndex = _tokenSupply.current(); // Start IDs at 1
        require(mintIndex <= MAX_SUPPLY, "Tempos supply is sold out!");

        uint256 mintPrice = currentPrice();
        require(msg.value >= mintPrice, "Not enough ETH to buy a TEMPOS!");
        require(
            _numberOfTokens > 0,
            "You cannot mint 0 TEMPOS, please increase to 1 or more"
        );
        require(
            _numberOfTokens <= getMaxAmount(),
            "You are not allowed to mint this many TEMPOS at once."
        );

        // Mint
        for (uint256 i = 0; i < _numberOfTokens; i++) {
            _tokenSupply.increment();
            _safeMint(msg.sender, _tokenSupply.current());
        }
    }

    function setBaseURI(string memory _baseURI) external onlyOwner {
        _baseTokenURI = _baseURI;
    }

    // Set sale to active to begin minting
    function toggleSale() public onlyOwner {
        saleIsActive = !saleIsActive;
    }

    // Withdraw ETH balance from Contract to Owner (account that deployed the contract)
    function withdrawBalance() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
}
