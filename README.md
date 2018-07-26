# Randomizer
#### A random number beacon on the Ethereum blockchain based on Blockduino. 

This contract is an example of how to use a Blockduino board and the Blockduino SDK to execute a function and receive a payment for performing. It shows how to make available to an Ethereum contract the _paid_ services of a [TrueRNG Pro](http://ubld.it/products/truerngpro) device connected to the Blockduino USB serial connection.

### Deployment
The contract is deployed providing the adress of the core Blockduino contract and the address of the Blockduino board Ethereum account. That is the board used to generate random numbers from the TrueRNG device.
> A value of at least 0.04 Ether must be provided to the contract at deployment time to provide for gas used in future transactions initiated by the contract.

### Usage
To obtain a true random number generated from Blockduino, a transaction is sent to the `generate()` function of the contract with a value of 0.02 Ether, indicating a callback function. The fee paid minus the gas needed for the return transaction, is transfered to the Blockduino Ethereum account. 

After the request is sent to the Blockduino board and the transaction is mined, the Blockduino will reply sending a second transaction to the Blockduino core with the response. Once the response transaction is mined the Blockduino core contract will then invoke the callback function in the the Randomizer contract with the random number as a `bytes32` variable 

> The fee for obtaining a random number can be changed modifying the `RNF_FEE` constant.


