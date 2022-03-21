pragma circom 2.0.0;
include "../node_modules/circomlib/circuits/mimcsponge.circom";
include "../node_modules/circomlib/circuits/comparators.circom";

template Card() {
    signal input initialSuit;
    signal input initialNumber;
    signal input secondSuit;
    signal input secondNumber;
    signal input HASH_KEY;
    signal output initialCardHash;
    signal output secondCardHash;

    // same suit
    initialSuit === secondSuit;

    // not same card
    component equel = IsEqual();
    equel.in[0] <== initialNumber;
    equel.in[1] <== secondNumber;
    equel.out === 0;

    // suit range [0~3]
    component comp = LessThan(4);
    comp.in[0] <== initialSuit;
    comp.in[1] <== 4;
    comp.out === 1;

    component comp2 = LessThan(4);
    comp2.in[0] <== secondSuit;
    comp2.in[1] <== 4;
    comp2.out === 1;

    // number range [0~12]
    component comp3 = LessThan(4);
    comp3.in[0] <== initialNumber;
    comp3.in[1] <== 13;
    comp3.out === 1;

    component comp4 = LessThan(4);
    comp4.in[0] <== secondNumber;
    comp4.in[1] <== 13;
    comp4.out === 1;

    // hash
    component mimc = MiMCSponge(2, 220, 1);
    mimc.ins[0] <== initialSuit;
    mimc.ins[1] <== initialNumber;
    mimc.k <== HASH_KEY;
    initialCardHash <== mimc.outs[0];

    component mimc2 = MiMCSponge(2, 220, 1);
    mimc2.ins[0] <== secondSuit;
    mimc2.ins[1] <== secondNumber;
    mimc2.k <== HASH_KEY;
    secondCardHash <== mimc2.outs[0];

}

component main = Card();
