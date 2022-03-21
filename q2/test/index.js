const { expect } = require("chai");
const { ethers } = require("hardhat");
const { buildMimcSponge } = require("circomlibjs");
const snarkjs = require("snarkjs");

function buildContractCallArgs(snarkProof, publicSignals) {
  // the object returned by genZKSnarkProof needs to be massaged into a set of parameters the verifying contract
  // will accept
  return [
    snarkProof.pi_a.slice(0, 2),
    // genZKSnarkProof reverses values in the inner arrays of pi_b
    [
      snarkProof.pi_b[0].slice(0).reverse(),
      snarkProof.pi_b[1].slice(0).reverse(),
    ],
    snarkProof.pi_c.slice(0, 2),
    publicSignals, // input
  ];
}

async function deploy(contractName, ...args) {
  const Factory = await ethers.getContractFactory(contractName);
  const instance = await Factory.deploy(...args);
  return instance.deployed();
}

describe("SimpleCardGame", function () {
  let mimcSponge;

  before(async () => {
    mimcSponge = await buildMimcSponge();
  });

  it("Success", async function () {
    const simpleCardGame = await deploy("SimpleCardGame");
    const HASH_KEY = 0;
    const initialCard = { suit: 1, number: 1 };
    const hashedInitialCard = mimcSponge.F.toString(
      mimcSponge.multiHash([initialCard.suit, initialCard.number], HASH_KEY)
    );

    console.log(hashedInitialCard);

    await simpleCardGame.commitInitialCard(hashedInitialCard);

    const secondCard = { suit: 1, number: 2 };

    const { proof, publicSignals } = await snarkjs.groth16.fullProve(
      {
        initialSuit: initialCard.suit,
        initialNumber: initialCard.number,
        secondSuit: secondCard.suit,
        secondNumber: secondCard.number,
        HASH_KEY: HASH_KEY,
      },
      "circuits/Card_js/Card.wasm",
      "circuits/Card_0001.zkey"
    );

    const solidityProof = await buildContractCallArgs(
      proof,
      publicSignals
    ).flat(2);
    console.log("Proof: ");
    console.log(JSON.stringify(solidityProof, null, 1));

    await simpleCardGame.commitSecondCard(solidityProof);

    expect((await simpleCardGame.initialCardHash()).toString()).to.be.equal(
      hashedInitialCard
    );

    // TODO:
    // await simpleCardGame.revealCards(
    //   initialCard.suit,
    //   initialCard.number,
    //   secondCard.suit,
    //   secondCard.number,
    //   HASH_KEY
    // );
  });

  // TODO:
  // it("Error", async function () {});
});
