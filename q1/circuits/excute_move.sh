# Compiling our circuit
circom Move.circom --r1cs --wasm --sym

# Computing the witness with WebAssembly
node ./Move_js/generate_witness.js ./Move_js/Move.wasm input_move.json ./Move_js/witness.wtns

# # Powers of Tau
snarkjs powersoftau new bn128 13 pot12_0000.ptau -v
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -e="random"


# # Phase 2
snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v
snarkjs groth16 setup Move.r1cs pot12_final.ptau Move_0000.zkey
snarkjs zkey contribute Move_0000.zkey Move_0001.zkey --name="1st Contributor Name" -e="random"

# Export the verification key:
snarkjs zkey export verificationkey Move_0001.zkey verification_key.json


# Generating a Proof
snarkjs groth16 prove Move_0001.zkey ./Move_js/witness.wtns move_proof.json public.json


# Verifying a Proof
snarkjs groth16 verify verification_key.json public.json move_proof.json

# Verifying from a Smart Contract
snarkjs zkey export solidityverifier Move_0001.zkey ../contracts/Verifier.sol
# snarkjs generatecall | tee parameters.txt