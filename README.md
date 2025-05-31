# Introduction

This is the codebase for running and reproducing simulation results appearing in "Empirical Results" section of "Coded Secure Delivery for Anonymous Information Retrieval" by Omer Lauer and Yuval Cassuto.

The code is written primarily in MATLAB, and was executed using MATLAB R2021b or later versions. It also requires the add-ons:
1. Statistics and Machine Learning Toolbox - mainly for sampling random data (with randsample(...)).
2. Parallel Computing Toolbox - for speeding up for loops by using parfor loops.

Algorithms implementation (specifically the greedy coded algorithm implementation) makes use of [MatlabBGL](https://github.com/dgleich/matlab-bgl) by David F. Gleich, for efficient matching finding algorithm in graphs. Go check it out!

The following sections provide details and notes about some of the different directories in the codebase.

# server_broadcast

Contains various functions implementing the server broadcast functionality in the CSD model, for delivering one or more coded objects.

The broadcast does not contain any information about the coding coefficients used for coded messages - it only contains a list of objects to be coded (this is the output given by greedy coded algorithm 1, described in our CSD work).

Each broadcast is a MATLAB cell made of 5 parts:
1. objects - a list of objects coded in the broadcast.
2. key - the key used to encrypt the broadcast.
3. utility - this is another feature of the broadcast not discussed in the work. In general, it means how many objects/"useful" linear coding combinations are delivered by the broadcast to all users. More details on how utility is calculated in greedy coded/uncoded solution sections.
4. notes - whether the broadcast is coded or uncoded, if using essential keys or private keys.

The main output of each greedy algorithm is the broadcast table, of all broadcasts used to solve the CSD instance. 

# greedy_solution

Contains two implementations for finding greedy uncoded and coded solutions for a CSD instance.

Note that for efficiency, the greedy algorithms are not supplied with KHS containing private keys, but rather shared keys only. In their implementation, the greedy algorithms first try to utilize shared keys as much as possible, and after fully exhausting them, inferred private keys are used for final object deliveries, completing the CSD solution.

## uncoded_solution

Implements a standard set cover greedy algorithm. It uses a side information (SI) matrix to keep track which user holds which objects. The CSD instance is solved when the SI matrix equals the ACS.

In the uncoded scenario, the utility of a broadcast is simply how many users learn a new (uncoded) object from the broadcast. After each uncoded broadcast, the SI matrix is updated accordingly.

## coded_solution

Implements the greedy coded algorithm 1 detailed in our work, with modifications to make it more efficient. The most notable one is that after finding a key to use in a broadcast, it is not added as a new right node to all users' graphs, but rather only to those in which that new node increases the graph's maximum matching size. This does not alter the algorithm's final output, as these nodes cannot contribute to any new matchings in those graphs in any later iteration of the algorithm.

In the coded scenario, the utility of a broadcast is how many users gain a new independent linear combination of objects from it (each can gain a maximum of 1 new independent linear combination). In other terms - for how many users the total degree of freedom of their knowledge of objects is decreased (each can have it decreased by a maximum of 1 degree of freedom).

This definition of utility can be seen as a generalization of the utility in the uncoded case.

# key_dsitribution

Implements the key distribution algorithms shown in our work (the ACS-agnostic algorithm is not implemented):
1. Fixed Key-Degree ACS-Aware algorithm (under "memoryless" subdirectory).
2. Variable Key-Degree ACS-Aware algorithm (under "memoryless" subdirectory). Optimization of alpha vector with possible key degrees 2 and 3 is implemented in the same subdirectory.
3. Pair-Covering ($`d = 2`$) (under "stateful" subdirectory).

The directory also contains a script for testing various probability calculations shown in our work.

# content sharing

Contains one function for generating a content sharing scenario with its various parameters.

# empirical_results

The main directory for running simulations and generating plots used in our work.
It also contains a simple script generating Family 1 instances, shown in "Power of Coding" section in our work.

Each simulation consists of two scripts:
1. \*_simulation.m - runs a simulation with various parameters, and saves the results into an "\*.mat" to the appropriate "data" directory, with unique date timestamp.
2. \*_simulation_data_processing.m - plots one or more figures of given a "\*.mat" file, and saves them into the appropriate "plots" directory, with the same timestamp used for the "\*.mat" file.

The simulations are:
1. Random instance (under "random_instance" subdirectory).
2. Key distribution:
  - Memoryless algorithms - fixed and variable key-degree (under "key_distribution/memoryless" subdirectory).
  - Variable key-degree for different ACS densities (under "key_distribution/memoryless_variable" subdirectory).
  - Fixed key-degree ($`d = 2`$) and pair-covering  (under "key_distribution/memoryless_and_stateful" subdirectory).
3. Content sharing (under "content_sharing" subdirectory).
