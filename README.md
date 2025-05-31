# Introduction

This is the codebase for running and reproducing simulation results appearing in the "Empirical Results" section of "Coded Secure Delivery for Anonymous Information Retrieval" by Omer Lauer and Yuval Cassuto.

The code is written primarily in MATLAB, and was executed using MATLAB R2021b or later versions. It also requires the add-ons:
1. Statistics and Machine Learning Toolbox - mainly for sampling random data (with randsample(...)).
2. Parallel Computing Toolbox - for speeding up for loops by using parfor loops.


The implemenet algorithms (specifically the greedy coded algorithm) makes use of [MatlabBGL](https://github.com/dgleich/matlab-bgl) by David F. Gleich, primarily for efficient matchting finding algorithm in graphs. Go check it out!

The following sections give details and notes about some of the different directories in the codebase.

# server_broadcast

Contains various functions implementing the server broadcast action in the CSD model, delivering one or more coded objects. The broadcast does not contain any information about the coding coefficients used - it only contains the list of objects coded in it (i.e. each broadcast is a result of the greedy algoritm 1 as described in our CSD work, before deciding on coefficients with algorithm 2).

Each broadcast is made of 5 parts:

1. objects - a list of objects coded in the broadcast.
2. key - the key used to encrypt the broadcast.
3. utility - this is another feature of the broadcast not discussed in the work. In general, it means how many objects/"useful" linear coding combinations are delivered by the broadcast to all users. More details about how utility is calculated in greedy coded/uncoded solution sections.
4. notes - whether the broadcast is coded or uncoded, if using essential keys or private keys.

# greedy_solution

Contains two directories, implementing greedy uncoded/coded solutions for solving a CSD intance.

Note that for effiecieny, the greedy algorithms should not be supplied with KHS containing private keys, but rather with shared keys only. In their, implementation, the greedy algorithms first try to utilize shared keys as much as possible, and after fully exhausting them, private keys are used for final object deliveries, completing the CSD solution.

## uncoded_solution

Implements a standatd set cover greedy algorithm. It uses a side information (SI) matrix for keeping track which user hold which object. The CSD instance is solved when the SI matrix equals the ACS.

In the uncoded scenario, the utility of a broadcast is how many users gain new information (the uncoded object) from the broadcast. After each uncoded broadcast, the SI matrix is updated accordingly.

## coded_solution

Implements greedy coded algorithm 1 detailed in our work, with modifications to make it more efficient.
The most notable one is that after finding a key to broadcast, it is not added as a new right node to all users' graphs, but rather only to those in which that new node increases the graph's maximum matching size. This does not alter the algorithm's final output, as these nodes cannot contribute to any new matchings in their respective graph in any later iteration of the algorithm as well.
