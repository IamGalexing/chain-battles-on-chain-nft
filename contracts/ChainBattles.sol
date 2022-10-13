// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract ChainBattles is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private tokenId;
    struct Levels {
        uint256 rank;
        uint256 power;
        uint256 wisdom;
    }

    mapping(uint256 => Levels) public tokenIdsToLevels;

    constructor() ERC721("Chain Battles", "CBTLS") {}

    function generateCharacter(uint256 _tokenId)
        public
        view
        returns (string memory)
    {
        Levels memory levels = (getLevels(_tokenId));
        // (uint256 level, uint256 power, uint256 wisdom) = getLevels(_tokenId);
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            "<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>",
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="35%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "WARRIOR",
            "</text>",
            '<text x="50%" y="48%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Levels:",
            "</text>",
            '<text x="50%" y="55%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "rank: ",
            levels.rank.toString(),
            "</text>",
            '<text x="50%" y="60%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "power: ",
            levels.power.toString(),
            "</text>",
            '<text x="50%" y="65%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "wisdom: ",
            levels.wisdom.toString(),
            "</text>",
            "</svg>"
        );
        return
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(svg)
                )
            );
    }

    function getLevels(uint256 _tokenId) public view returns (Levels memory) {
        return tokenIdsToLevels[_tokenId];
    }

    function getTokenURI(uint256 _tokenId) public view returns (string memory) {
        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "Chain Battles #',
            _tokenId.toString(),
            '",',
            '"description": "Battles on chain",',
            '"image": "',
            generateCharacter(_tokenId),
            '"',
            "}"
        );
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(dataURI)
                )
            );
    }

    function mint() public {
        tokenId.increment();
        uint256 newItemId = tokenId.current();
        _safeMint(msg.sender, newItemId);
        tokenIdsToLevels[newItemId] = Levels({rank: 0, power: 0, wisdom: 0});
        _setTokenURI(newItemId, getTokenURI(newItemId));
    }

    function train(uint256 _tokenId) public {
        require(_exists(_tokenId), "Please use an existing token");
        require(
            ownerOf(_tokenId) == msg.sender,
            "You must own this token to train it"
        );
        Levels storage levels = tokenIdsToLevels[_tokenId];
        levels.rank += 1;
        levels.power += randomness(1);
        levels.wisdom += randomness(2);

        _setTokenURI(_tokenId, getTokenURI(_tokenId));
    }

    function randomness(uint256 _index) private view returns (uint256) {
        return
            (uint256(
                keccak256(
                    abi.encodePacked(
                        block.difficulty,
                        block.timestamp,
                        msg.sender,
                        _index
                    )
                )
            ) % 10) + 1;
    }
}
