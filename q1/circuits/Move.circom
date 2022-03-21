pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/mimcsponge.circom";
include "../node_modules/circomlib/circuits/comparators.circom";

template Main() {
    signal input xA;
    signal input yA;
    signal input xB;
    signal input yB;
    signal input xC;
    signal input yC;
    signal input energy;
    signal input r;
    
    signal output pub1;
    signal output pub2;
    signal output pub3;


    /* check abs(xA), abs(yA), abs(xB), abs(yB), abs(xC), abs(yC) <= 2^31 */
    component n2bxA = Num2Bits(32);
    n2bxA.in <== xA + (1 << 31);
    component n2byA = Num2Bits(32);
    n2byA.in <== yA + (1 << 31);
    component n2bxB = Num2Bits(32);
    n2bxB.in <== xB + (1 << 31);
    component n2byB = Num2Bits(32);
    n2byB.in <== yB + (1 << 31);
    component n2bxC = Num2Bits(32);
    n2bxC.in <== xC + (1 << 31);
    component n2byC = Num2Bits(32);
    n2byC.in <== yC + (1 << 31);

    /* check xB^2 + yB^2 < r^2 */

    component comp2 = LessThan(64);
    signal xBSq;
    signal yBSq;
    signal rSq;
    xBSq <== xB * xB;
    yBSq <== yB * yB;
    rSq <== r * r;
    comp2.in[0] <== xBSq + yBSq;
    comp2.in[1] <== rSq;
    comp2.out === 1;

    /* check xC^2 + yC^2 < r^2 */

    component comp3 = LessThan(64);
    signal xCSq;
    signal yCSq;
    xCSq <== xC * xC;
    yCSq <== yC * yC;
    comp3.in[0] <== xCSq + yCSq;
    comp3.in[1] <== rSq;
    comp3.out === 1;

    /* check (xA-xB)^2 + (yA-yB)^2 <= energy^2 */

    signal diffX;
    diffX <== xA - xB;
    signal diffY;
    diffY <== yA - yB;

    component ltDist = LessThan(64);
    signal firstDistSquare;
    signal secondDistSquare;
    firstDistSquare <== diffX * diffX;
    secondDistSquare <== diffY * diffY;
    ltDist.in[0] <== firstDistSquare + secondDistSquare;
    ltDist.in[1] <== energy * energy + 1;
    ltDist.out === 1;


    /* check (xB-xC)^2 + (yB-yC)^2 <= energy^2 */
    
    signal diffX2;
    diffX2 <== xB - xC;
    signal diffY2;
    diffY2 <== yB - yC;

    component ltDist2 = LessThan(64);
    signal firstDistSquare2;
    signal secondDistSquare2;
    firstDistSquare2 <== diffX2 * diffX2;
    secondDistSquare2 <== diffY2 * diffY2;
    ltDist2.in[0] <== firstDistSquare2 + secondDistSquare2;
    ltDist2.in[1] <== energy * energy + 1;
    ltDist2.out === 1;


    /* check the move lies on a triangle */
    // https://qiita.com/tydesign/items/ab8a5ae52eb9c50ad26a
    signal diffX3;
    diffX3 <== xA - xC;
    signal diffY3;
    diffY3 <== yA - yC;

    component equal = IsEqual();
    equal.in[0] <== diffX3 * diffY;
    equal.in[1] <== diffX * diffY3;
    equal.out === 0;


    /* check MiMCSponge(xA,yA) = pub1, MiMCSponge(xB,yB) = pub2, MiMCSponge(xC,yC) = pub3 */
    component mimc1 = MiMCSponge(2, 220, 1);
    component mimc2 = MiMCSponge(2, 220, 1);
    component mimc3 = MiMCSponge(2, 220, 1);

    mimc1.ins[0] <== xA;
    mimc1.ins[1] <== yA;
    mimc1.k <== 0;
    mimc2.ins[0] <== xB;
    mimc2.ins[1] <== yB;
    mimc2.k <== 0;
    mimc3.ins[0] <== xC;
    mimc3.ins[1] <== yC;
    mimc3.k <== 0;

    pub1 <== mimc1.outs[0];
    pub2 <== mimc2.outs[0];
    pub3 <== mimc3.outs[0];

}

component main{public [r, energy]} = Main();
