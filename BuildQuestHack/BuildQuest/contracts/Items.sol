// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";
import "./Stores.sol";

contract Items is ERC1155, Ownable, Stores {
    
    string baseURI;
    string public baseExtension = ".json";
    uint nextId = 0;

    constructor(string _baseURI) ERC1155(_baseUri) {

    }

    struct Item {
        address owner;
        uint256 supply;
        string name;
        uint256 cost;
        bool forSale;

    }

    mapping(uint => Item) private _itemDetails;
    mapping(Item => uint256) private _itemToStore;

    modifier forSale(uint256 _tokenId) {
        require(_itemDetails[_tokenId], "item is not for sale");
        _;
    }

    modifier isItemOwner(uint256 _tokenId) {
        require (msg.sender == _itemDetails[_tokenId].owner);
        _;
    }

    function getItemDetails(uint _tokenId) public view returns(Item memory) {
        return _itemDetails[_tokenId];
    }

    function mint(uint256 _supply, string memory _name, uint256 cost, uint256 _store) {

        Item memory thisItem = Item(msg.sender, _supply, _name, _cost, true);
        _itemDetails[nextId] = thisItem;
        _itemToStore[thisItem] = _store;

        _mint(msg.sender(), nextId, _supply);

        nextId++;

    }

    function buyItem(uint256 _tokenId, uint256 _amount) public payable forSale(_tokenId) {
        // amount less then supply
        // safe transfer from

        require(msg.value >= _itemDetails[_tokenId].cost, "Didn't input enough ethere to purchase this item");

        require(msg.sender != address(0), "Cannot be 0x00 address");

        require(amount <= _itemDetails[_tokenId].supply, "This item is out of stock");

        _safeTransferFrom(_itemDetails[_tokenId].owner, msg.sender, _tokenId, _amount);

    }

    function sellItem(address _to, uint256 _tokenId, uint256 _amount) public {
        
        require(to != address(0));

        _safeTransferFrom(msg.sender, _to, _tokenId, _amount);

    }

    function setSale(uint256 tokenId) public isItemOwner(_tokenId) {

        _itemDetails[_tokenId].forSale = true;

    }

    function closeSale(uint256 _tokenId) public isItemOwner(_tokenId) {

        _itemDetails[_tokenId].forSale = false;
    }

    function setPrice(uint256 _tokenId, uint256 _price) public isItemOwner(_tokenId) {

        _itemDetails[_tokenId].cost = _price;

    }

    function changeName(uint256 _tokenId, uint256 _newName) public isItemOwner(_tokenId) {

        _itemDetails[_tokenId].name = _newName;

    }

}

//pick up shoes, the whole website changes to just shoes everywhere.
