# Randomizer
#### A random number beacon on the Ethereum blockchain based on Blockduino. 

This contract is an example of how to use a Blockduino board and the Blockduino SDK to execute a function and receive a payment for performing. It shows how to make available to an Ethereum contract the _paid_ services of a [TrueRNG Pro](http://ubld.it/products/truerngpro) device connected to the Blockduino USB serial connection.

### Deployment
The contract is deployed providing the adress of the core Blockduino contract and the address of the Blockduino board Ethereum account. That is the board used to generate random numbers from the TrueRNG device.
> A value of at least 0.04 Ether must be provided to the contract at deployment time to provide for gas used in future transactions initiated by the contract.

### Usage
To obtain a true random number generated from Blockduino, a transaction is sent to the `generate()` function of this contract with a value of 0.02 Ether. The fee paid minus the gas needed for the transaction to the board, is transfered to the Blockduino Ethereum account used by the contract, and the random number generated is copied in the `randomNumber` global public variable of the contract.
> For the `randomNumber` global public variable  to receive a new value, two transactions must be mined by the blockchain, one with the request and one with the response.
### Under the hood
After the request is sent to the Blockduino board and the transaction is mined, the Blockduino will reply sending a second transaction to the Blockduino core contract with the response. Once the response transaction is mined the Blockduino core contract will then invoke the callback function in the the Randomizer contract with the random number as a `bytes32` variable.

> The fee received for obtaining a random number can be changed modifying the `RNF_FEE` constant.

The TrueRNG device generates a stream of full-entropy bit-strings that is readable through the USB serial port. 

### Current Status
As of Q3 2018 the Blockduino board is not yet available. Software to emulate functions of the Blockduino board and to use the Blockduino SDK is available in the Raspberry PI repo.

### Remote Attestation
In its final version, the Blockduino board will provide remote attestation with every response to a request. With remote attestation, a Blockduino device authenticates its hardware and software configuration to a remote host. The goal of remote attestation is to enable contract sending the request to determine the level of trust in the integrity of the platform running on the Blockduino device.

> This feature is not available with the Raspberry PI hardware or in any hardware that does not have a Trusted Execution Environment.

