# Compiling our circuit
circom Card.circom --r1cs --wasm --sym

# Computing the witness with WebAssembly
node ./Card_js/generate_witness.js ./Card_js/Card.wasm input.json ./Card_js/witness.wtns

# # Powers of Tau
snarkjs powersoftau new bn128 12 pot12_0000.ptau -v
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -e="random"


# # Phase 2
snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v
snarkjs groth16 setup Card.r1cs pot12_final.ptau Card_0000.zkey
snarkjs zkey contribute Card_0000.zkey Card_0001.zkey --name="1st Contributor Name" -e="random"

# Export the verification key:
snarkjs zkey export verificationkey Card_0001.zkey verification_key.json


# Generating a Proof
snarkjs groth16 prove Card_0001.zkey ./Card_js/witness.wtns proof.json public.json


# Verifying a Proof
snarkjs groth16 verify verification_key.json public.json proof.json

# Verifying from a Smart Contract
snarkjs zkey export solidityverifier Card_0001.zkey ../contracts/Verifier.sol
# snarkjs generatecall | tee parameters.txt