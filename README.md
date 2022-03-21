# Question 1: Dark Forest

## 1. Write a Circom circuit that verifies this move.

TODO: link

## [Bonus] Make a Solidity contract and a verifier that accepts a snark proof and updates the location state of players stored in the contract.

# Question 2: Fairness in card games

TODO: link

# Question 3: MACI and VDF

## 1. What problems in voting does MACI not solve? What are some potential solutions?

In MACI we have to trust the coordinator because the coordinator is able to decrypt participant's votes.
A one way to keep anonymity to use ElGamal re-randomisation for anonymity of voters.  
https://ethresear.ch/t/maci-anonymization-using-rerandomizable-encryption/7054

MACI doesn't have Sybil attack resistant system. Implementing a logic to gate-keep signups is resposible for developers.
clr.fund which adopts MACI for anti-collusion uses the BrightID identity system to prevent Sybil attacks and ensure the uniqueness of each account.
Sybil attack is a major problem in voting but I think it's not a problem that MACI should solve because its solution may be totally different from a current MACI system. It's better to use in combination with other systems like InterRep or BrightID.
https://inf.news/en/economy/ffe2dea6166bc5b2a2398c44586dcc72.html

## 2. How can a pseudorandom dice roll be simulated using just Solidity?

### 2-1. What are the issues with this approach?

The simplest implementation of this pattern would be just using the most recent block hash.
For simulating dice roll, do ((randomNumber mod 6) + 1).

```
// Randomness provided by this is predicatable. Use with care!
function randomNumber() internal view returns (uint) {
    return uint(blockhash(block.number - 1));
}
```

Implemented like this there are two problems, making this solution impractical:

1. a miner could withhold a found block, if the random number derived from the block hash would be to his disadvantage. By withholding the block, the miner would of course lose out on the block reward. This problem is therefore only relevant in cases the monetary value relying on the random number is at least comparatively high as the current block reward.
2. the more concerning problem is that since block.number is a variable available on the blockchain, it can be used as an input parameter by any user. In case of a gambling contract, a user could use uint(blockhash(block.number - 1) as the input for his bet and always win the game.

https://fravoll.github.io/solidity-patterns/randomness.html

### 2-2. How would you design a multi party system that performs a dice roll?

(Use Commit Reveal System for mitigating "Last Actor Problem" insted of naive multi party system)

The first phase: collecting valid Hash(secretSeed) from each party.

The second phase: collecting valid secretSeed
(Contract verifies secretSeed using stored hash values)

The third phase: calculating a random number using all valid secretSeeds.

After generating a random number, do ((random number mod 6) + 1) to sumilate a dice roll.

### 2-3. Compare both techniques and explain which one is fairer and why.

The first one(blockhash) is far less expensive and complicated so in most case it's better. But about fairness it's dificult to say which is better because both randomization process can be unfair to some extent.

### 2-4 Show how the multi party system is still vulnerable to manipulation by malicious parties and then elaborate on the use of VDF’s in solving this.

On blockchain, all states are visible so at the second phase last party can select commit valid or invalid secretSeed for its own advantage.
It happens because attackers can see how different inputs affect the output before commiting.
VDFs prevents attackers from affecting the output, because all inputs will be finalized before anyone can finish computing the VDFs.

## [Bonus] How would two players pick a random and mutually exclusive subsets of a set? For instance, in a poker game, how would two players decide on a hand through the exchange of messages on a blockchain?

# Question 4: InterRep

## 1. How does InterRep use Semaphore in their implementation? Explain why InterRep still needs a centralized server.

Interep uses Semaphore for proving their membership of groups without revealing their original identity. So Interep doesn't need to do cumbersome setup for generating keys and implement complicated zk things.
Interep retrieves data from third party APIs for evaluating their reputation. This process can not seem to be done on-chain but if doing that on client side it's very easy to be hacked so Interep has to do this process on secured its own server. And because Interep has its own server, users don't need to directly intract its contract so no need to pay for gas fee. It's more user friendly.

## 2. Explain what happens to the Merkle Tree in the MongoDB instance when you decide to leave a group.

It changes corresponding leaf hash values to zero.
It adds new root hash to TreeTootBatches item's roots key.

## 3. Take the screenshots of the responses and paste them to your assignment submission PDF.

TODO: link

# Question 5: Thinking in ZK

## 1. If you have a chance to meet with the people who built DarkForest and InterRep, what questions would you ask them about their protocols?

I still can not imagin such a complicated game can be managed in full onchain.
You can not write codes without bugs.
So it can become a game for exploiting bugs.

DarkForest seems to have ability to update contract anytime but it's like a centralized game.
What's the ideal form of web3 games?
What will DarkForest be in the future?
