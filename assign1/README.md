# COP5612 – Fall 2013
# Project 1 

# Group Members 
- Siddhant Mohan Mittal UFID: 6061-8545
- Prafful Mehrotra UFID: 1099-5311

# Porject Directory Structure

- Main directory contains Project Problem statement pdf and directory named code which contains the elixir mix project
- In lib we have two files [proj1.exs] and [multi_machine.exs] 
- [proj1.exs] contains the main code 
- [multi_machine.exs] contains the code for running the system on two machines

# Instructions for running the code

After unziping the file 
```sh
$ cd code
$ mix run lib/proj1.exs 3 2
```
Where 3 is the number N which is range in which the first number of solution set should lie. And 2 is the value of K that is maximum size of the solution set

#  Questions to be answered
- Size of the work unit that you determined results in best performance for your implementation and an explanation on how you determined it. Size of the work unit refers to the number of sub-problems that a worker gets in a single request from the boss.


- The result of running your program for mix run proj1.exs 1000000 4
Sol: No solution was found for this case


- The running time for the above as reported by time for the above. The ratio of CPU time to REAL TIME tells you how many cores were effec- tively used in the computation.

 Depending upon on the workunit 

![Alt text](https://github.com/prafful13/DOS_Projects/blob/master/assign1/code/images/graph.png "Graph")


| Workunit | Time |
| ------ | ------ |
| 100 | 4.067768 |
 | 200 |    4.049122 |
|   300  |   4.354220|
 |  400  |   4.147173 |
 |  500  |    4.084950|
  | 600     | 4.056077 |
  | 700     |4.069899|
 |  800   |  4.042797|
|   900    | 4.157107 |
 | 1000  |   4.170493|

For Workunit 100 we calculate the ratio of CPU/real time = 3 (approx)

real: 0m4.598s
user: 0m8.983s
sys:0m4.221s

- The largest problem you managed to solve

# Instructions for bonus part

- We tried to connect two machines using the Node functionality of erlang VM and extened our previous code to run on two different machines. 

- For this we have to use two files in our lib folder that is mutli-machine.exs and worker.exs.

- We have to set up a Node connection between two remote devices. The Importent thing here to noticed that cookie value should be same so that system can communicate with each other, there it is "elixir"

- Now on our remote system compile the worker module by runnig the iteractive elixir (iex) use the following commands. NOTE to be in the directory of the worker.ex

```sh
$ iex --sname prafful --cookie elixir
$ c('worker.ex')
```

Now run the following command on your host machine

```sh
$ elixir --sname siddhant1 --cookie elixir  lib/multi_machine.exs 1000000 4
```

We will be running 100 workUnits(50 on one and 50 on other) 






