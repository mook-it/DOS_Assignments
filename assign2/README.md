# COP5615 – Fall 2018

# Project 2

### Group Members

##### Prafful Mehrotra UFID: 1099-5311

##### Siddhant Mohan Mittal UFID: 6061-8545

## Project Directory Structure

- We are submitting two folders: gvp, gvp-bonus, where gvp stands for gossip vs pushsum. gvp-bonus contains code for the bonus part including node termination handling.
- Following is the directory structure for gvp. gvp-bonus follows similar directory structure.

```
gvp
├── _build/
├── config/
├── lib
│   ├── gvp
│   │   ├── application.ex
│   │   ├── Gossip
│   │   │   ├── driver.ex
│   │   │   ├── node.ex
│   │   │   └── node_supervisor.ex
│   │   ├── PushSum
│   │   │   ├── driver.ex
│   │   │   ├── node.ex
│   │   │   └── node_supervisor.ex
│   │   └── Topologies
│   │       ├── topo.ex
│   │       └── topologies.ex
│   └── gvp.ex
├── main.exs
├── mix.exs
├── README.md
└── test/
```

## Defining Application architecture

![Alt text](https://github.com/prafful13/DOS_Projects/blob/master/assign2/images/arch.png "Application architecture")

- There is a main supervisor which supervises 2 modules: Driver and Topologies and a subsupervisor: Node_Supervisor. The strategy used is one_for_all because we want the application (all modules) to restart if any of the modules fail to function.
- Node_Supervisor supervises numNodes number of Node modules. Strategy used here is one_for_one because we want only the node terminated unintentionally to respawn.
- This is same for both the algorithms, just the name of driver and Node*Supervisor modules shall be Gvp.Gossip.* and Gvp.PushSum.\_ respectively

## Instructions for running the code

After unziping the file

```sh
$ cd gvp
$ mix run --no-halt main.exs 1000 imp2D pushsum
```

For bonus part, after unziping the file

```sh
$ cd gvp-bonus
$ mix run --no-halt main.exs 1000 imp2D pushsum 20
```

### Input Format:

```
/gvp$ mix run --no-halt main.exs arg1 arg2 arg3
```

```
/gvp-bonus$ mix run --no-halt main.exs arg1 arg2 arg3 arg4
```

| Argument | Value                      | Possible Values                                   |
| -------- | -------------------------- | ------------------------------------------------- |
| arg1     | numNodes                   | any positive integer                              |
| arg2     | topology                   | line, impline, 2D, imp2D, rand2D, 3D, torus, full |
| arg3     | algorithm                  | gossip, pushsum                                   |
| arg4     | percentage of faulty nodes | any value between 0 and 100                       |

### Output Format:

Example output for gvp:

```
Time taken:
3843
```

We are printing the time taken for convergence.

Example output for gvp-bonus:

```
How many nodes got the message in this failure prone topology:
799

Time taken:
6253
```

We are printing the number of node getting the message and time taken for convergence.

## Questions asked in Problem Statement

#### What is working?

We have implemented all the desired topologies and implemented both the algorithms.
Furthermore we have implemented a failure model for the bonus task.

#### What is the largest network you managed to deal with for each type of topology and algorithm?

| Topology | Gossip | Push Sum |
| -------- | ------ | -------- |
| line     | 10_000 | 500      |
| impline  | 4_000  | 1_000    |
| 2D       | 10_000 | 600      |
| imp2D    | 3_500  | 2_000    |
| rand2D   | 3_000  | 1_000    |
| 3D       | 5_000  | 125      |
| torus    | 10_000 | 600      |
| full     | 3_500  | 500      |
