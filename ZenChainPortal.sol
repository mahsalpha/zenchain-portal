// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

// ---------------- ERC20 TokenA ----------------
contract TokenA is ERC20, ERC20Burnable, Ownable {
    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {}
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}

// ---------------- ERC20 TokenB ----------------
contract TokenB is ERC20, ERC20Burnable, Ownable {
    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {}
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}

// ---------------- ZenChainPortal ----------------
contract ZenChainPortal is Ownable {

    TokenA public tokenA;
    TokenB public tokenB;
    mapping(address => bool) public faucetClaimed;

    // NFT related
    struct NFTData {
        string ipfsHash;
        string title;
    }
    mapping(address => NFTData) public pendingNFT;
    ERC721URIStorage public nftCollection;
    uint256 public nextTokenId;

    // Diary related
    struct Memory {
        address user;
        string country;
        string text;
        uint256 timestamp;
    }
    Memory[] private memories;

    // Events
    event MemoryAdded(address indexed user, string country, string text, uint256 timestamp);
    event FaucetClaimed(address indexed user, uint256 amount);
    event NFTApplied(address indexed user, string ipfsHash, string title);
    event NFTMinted(address indexed to, uint256 tokenId, string ipfsHash, string title);

    constructor(
        string memory _tokenAName,
        string memory _tokenASymbol,
        string memory _tokenBName,
        string memory _tokenBSymbol,
        string memory _nftName,
        string memory _nftSymbol
    ) {
        tokenA = new TokenA(_tokenAName, _tokenASymbol);
        tokenB = new TokenB(_tokenBName, _tokenBSymbol);
        nftCollection = new ERC721URIStorage(_nftName, _nftSymbol);
    }

    // Faucet
    function fundFaucet(uint256 amount) external onlyOwner {
        require(tokenA.transferFrom(msg.sender, address(this), amount), "Transfer failed");
    }
    function claimFaucet(uint256 amount) external {
        require(!faucetClaimed[msg.sender], "Already claimed");
        require(tokenA.balanceOf(address(this)) >= amount, "Not enough faucet balance");
        faucetClaimed[msg.sender] = true;
        tokenA.transfer(msg.sender, amount);
        emit FaucetClaimed(msg.sender, amount);
    }

    // Diary
    function addMemory(string calldata _country, string calldata _text) external {
        memories.push(Memory(msg.sender, _country, _text, block.timestamp));
        emit MemoryAdded(msg.sender, _country, _text, block.timestamp);
    }
    function getMemoriesCount() external view returns (uint256) {
        return memories.length;
    }
    function getMemory(uint256 index) external view returns (
        address user,
        string memory country,
        string memory text,
        uint256 timestamp
    ) {
        require(index < memories.length, "Index out of bounds");
        Memory storage m = memories[index];
        return (m.user, m.country, m.text, m.timestamp);
    }

    // NFT Mint
    function applyNFT(string calldata _ipfsHash, string calldata _title) external {
        pendingNFT[msg.sender] = NFTData(_ipfsHash, _title);
        emit NFTApplied(msg.sender, _ipfsHash, _title);
    }
    function mintNFT() external {
        NFTData storage data = pendingNFT[msg.sender];
        require(bytes(data.ipfsHash).length > 0, "No data applied");
        uint256 tokenId = nextTokenId;
        nextTokenId++;
        nftCollection._mint(msg.sender, tokenId);
        nftCollection._setTokenURI(tokenId, data.ipfsHash);
        emit NFTMinted(msg.sender, tokenId, data.ipfsHash, data.title);
        delete pendingNFT[msg.sender];
    }
}
