//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "./Verifier.sol";

contract SimpleCardGame is Verifier {
    uint256 public initialCardHash;
    uint256 public secondCardHash;

    constructor() {
        console.log("Deploying a Card");
    }

    function commitInitialCard(uint256 _initialCardHash) public {
        initialCardHash = _initialCardHash;
    }

    function commitSecondCard(uint256[10] calldata proof) public {
        require(proof[8] == initialCardHash, "initialCardHash is invalid!");
        require(
            verifyProof(
                [proof[0], proof[1]],
                [[proof[2], proof[3]], [proof[4], proof[5]]],
                [proof[6], proof[7]],
                [proof[8], proof[9]]
            ),
            "should be the same suit and not be spoofed!"
        );
        secondCardHash = proof[9];
    }

    /* 
    function mimcSponge(
        uint256 a1,
        uint256 a2,
        uint256 hashKey
    ) private pure returns (uint256 hash) {
        // TODO: I'm not sure how to use MiMCSponge in Solidity code...
        return hash;
    }

    function revealCards(
        uint256 initialSuit,
        uint256 initialNumber,
        uint256 secondSuit,
        uint256 scondeNumber,
        uint256 hashKey
    ) public view returns (bool r) {
        
        require(
            mimcSponge(initialSuit, initialNumber, hashKey) == initialCardHash,
            "Initial Card is not valid!"
        );

        require(
            mimcSponge(secondSuit, scondeNumber, hashKey) == secondCardHash,
            "Second Card is not valid!"
        );

        return true;
    }
    */
}
