pragma solidity >=0.5.0;

import "../token/ERC721/ERC721.sol";
import "./ERC165.sol";
import "../utils/math/SafeMath.sol";
import "../utils/Address.sol";

contract DeedToken is ERC721, ERC165 {
    using SafeMath for uint256;
    using Address for address;

    mapping (bytes4=>bool) supportedInterfaces;

    mapping (uint256 => address) tokenOwners;
    mapping (address => uint256) balances;
    mapping (uint256 => address) allowance;
    mapping (address => mapping(address => bool)) operators;

    struct asset {
        uint8 x;
        uint8 y;
        uint8 z;
    }

    asset[] public allTokens;
    // enumeration
    uint256[] public allValidTokenIds;
    mapping(uint256 => uint256) private allValidTokenIndex;

    constructor() public {
        supportedInterfaces[0x80ac58cd] = true; // 
        supportedInterfaces[0x01ffc9a7] = true;
    }

    function supportsInterface(bytes4 interfaceID) external view returns(bool){
        return supportsInterface[interfaceID];
    }

    function balanceOf(address owner) external view returns (uint256) {
        return _balances[owner];
    }

    function ownerOf(uint256 _tokenId) public view returns (address) {

        address addr_owner = tokenOwners[_tokenId];

        require(addr_owner != address(0), "ERC721: owner query for nonexistent token");

        return addr_owner;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) public payable {

        address addr_owner = ownerOf(_tokenId);
        require(addr_owner == _from, "_from is NOT the owner of the token");

        require(_to != address(0), "transger _to address 0x0");

        address addr_allowed = allowance[_tokenId];
        bool isOp = operators[addr_allowed][msg.sender];

        require(addr_owner == msg.sender || addr_allowed == msg.sender || isOp, "msg.sender can not transger the token");

        tokenOwners[_tokenId] = _to;
        balances[_from] = balances[_from].sub(1);
        balances[_to] = balances[_to].add(1);

        if (allowance[_tokenId] != address(0)) {
            delete allowance[_tokenId];
        }

        emit Transfer(_from, _to, _tokenId);

    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory data
    ) public payable {
        transferFrom(_from, _to, _tokenId);
        if (_to.isContract()) {
            bytes4 result  = ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, data);

            require(result == bytes4(keccak256("onERC721Received")), "not Completed");
        }
    }


}

contract ERC721TokenReceiver {
    function onERC721Received(
        address _operator,
        address _from,
        address _to,
        address _tokenId,
        bytes memory _data) public returns(bytes4);
}
