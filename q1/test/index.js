const { expect, assert } = require("chai");
const { ethers } = require("hardhat");
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

async function generateProof(inputs) {
  const { proof, publicSignals } = await snarkjs.groth16.fullProve(
    inputs,
    "circuits/Move_js/Move.wasm",
    "circuits/Move_0001.zkey"
  );

  const solidityProof = await buildContractCallArgs(proof, publicSignals);
  // console.log("Proof: ");
  // console.log(JSON.stringify(solidityProof, null, 1));
  return solidityProof;
}

describe("Move", function () {
  let verifier;

  before(async () => {
    verifier = await deploy("Verifier");
  });

  it("Success", async function () {
    const inputs = {
      xA: 19,
      yA: 10,
      xB: 25,
      yB: 16,
      xC: 30,
      yC: 20,
      energy: 10,
      r: 5000,
    };

    const solidityProof = await generateProof(inputs);

    const isValified = await verifier.verifyProof(...solidityProof);

    expect(isValified).to.equal(true);
  });

  it("Error when ABC lie on a straight line", async function () {
    const inputs = {
      xA: 0,
      yA: 0,
      xB: 1,
      yB: 1,
      xC: 3,
      yC: 3,
      energy: 10,
      r: 5000,
    };

    await generateProof(inputs)
      .then(() => {
        assert.fail();
      })
      .catch((err) => {
        expect(err.message).to.eql("Error: Assert Failed. ");
      });
  });

  it("Error when no enough energy", async function () {
    const inputs = {
      xA: 5,
      yA: 5,
      xB: 10,
      yB: 10,
      xC: 4,
      yC: 3,
      energy: 1,
      r: 5000,
    };

    await generateProof(inputs)
      .then(() => {
        assert.fail();
      })
      .catch((err) => {
        expect(err.message).to.eql("Error: Assert Failed. ");
      });
  });
});
