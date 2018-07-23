/*
 * Sample application for testing.
 *
 * Copyright (C) 2018, Visible Energy Inc. and the Blockduino contributors.
 *
 */
pragma solidity ^0.4.24;

// to use with remixd with mount point at the same level of Blockduino repos
import "https://github.com/Blockduino/Contracts/BlockduinoSDK.sol";

/*
 * Example of using a Blockduino board used to obtain a true random number generated
 * by a hardware device connected to its serial port.
 *
 * Send RNG_FEE ether to the generate() function to have the hardware random number
 * generator controlled by the Blockduino board returning a true random number.
 *
 * All the details and communication with the Blockduino board is handled by the
 * usingBlockduinoSDK base contract.
 */
contract Randomizer is usingBlockduinoSDK {
	address public owner;   // contract owner
    address public device;  // the device address of the Blockduino with the RNG
    
	// event to watch in any dApp using this contract 
	event RandomNumber(string log, address _device, uint64 error, string response);
	
    string public randomNumber;         // last random number generated
    bytes32 public randomNumberBytes;   // last random bytes sequence received
    int public lastError;               // Blockduino error status returned
    uint public RNG_FEE = 0.02 ether;   // payment for operating the hardware RNG
    uint256 public req_value;           // actual amount paid to the device account

    /* 
     * Deploy this contract passing the address of the Blockduino core contract and the
     * address of Blockduino device controlling the hardware RNG.
     */
	constructor (address BDcontract, address BDboard) usingBlockduinoSDK(BDcontract, msg.sender) public payable {
        // the constructor is payable so that funds can be sent to it at Deploy time
        // funds are needed in the contract to pay for gas of transfer functions 
        owner = msg.sender;
        device = BDboard;
    }

    // fallback function
    function() public payable {} // fallback must be payable for the contract to take a payment


    function bytes32ToString(bytes32 x) pure private returns (string) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }

    /*
     * The function called by the Blockduino board in the response transaction with
     * the result of the RPC request received from generate().
     */
   	function readRandomCallback(uint64 error, bytes32 respData) public {
    	// safety check: sender must be the Blockduino contract (address inherited from SDK)
    	if (msg.sender != address(CONTRACT)) {
    		return;
    	}
    	// assign the random number to the public variables
        randomNumberBytes = respData;
        randomNumber = bytes32ToString(respData);
        lastError = error;
        
    	// for any dApp monitoring the device to get the randomNumber
    	emit RandomNumber("received from Randomizer", device, error, randomNumber);
    }
    // readRandomCallback function signature used as function ID
    bytes4 constant RNG_CB_FID = bytes4(keccak256("readRandomCallback(uint64,bytes32)"));
    
    /*
     * Generate a true random number by reading the serial port of the Blockduino board
     * where the hardware RNG device is connected.
     */
    function generate() public payable {
        int req_reply;

	    // check payment sent to the contract
    	require(msg.value >= RNG_FEE, "fee paid below minimum");
    	
    	// keep some gas for the RPC request to use in the response
    	req_value =  msg.value - BD_MINFEE ; 
    	
    	// send the payment for operating the hardware RNF to the Blockduino wallet
    	device.transfer(req_value);

    	// read 64 bytes from the random number generator hardware connected to serial
	    req_reply = serialRead(device, 64, RNG_CB_FID); // function inherited from the SDK
    }
}