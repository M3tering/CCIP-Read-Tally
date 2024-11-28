// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {GatewayFetcher, GatewayRequest} from "https://github.com/unruggable-labs/unruggable-gateways/blob/v1.0.0-audit-2024-11-22-rc.1/contracts/GatewayFetcher.sol";
import {GatewayFetchTarget} from "https://github.com/unruggable-labs/unruggable-gateways/blob/v1.0.0-audit-2024-11-22-rc.1/contracts/GatewayFetchTarget.sol";
import {IGatewayVerifier} from "https://github.com/unruggable-labs/unruggable-gateways/blob/v1.0.0-audit-2024-11-22-rc.1/contracts/IGatewayVerifier.sol";

contract CCIPReadTally is GatewayFetchTarget {
    using GatewayFetcher for GatewayRequest;
    address public immutable SOURCE = 0x594C568BB6F559e23F579a5B4F5Eb647B4d39804; // Todo: set actual contract address
    /*___________________________________________[ SOURCE CONTRACT STORAGE LAYOUT ]____________________________________________
    | Name            | Type                                              | Slot | Offset | Bytes | Contract                  |
    |-----------------|---------------------------------------------------|------|--------|-------|---------------------------|
    | _paused         | bool                                              | 0    | 0      | 1     | src/Contract.sol:Contract |
    | _roles          | mapping(bytes32 => struct AccessControl.RoleData) | 1    | 0      | 32    | src/Contract.sol:Contract |
    | modules         | mapping(address => bool)                          | 2    | 0      | 32    | src/Contract.sol:Contract |
    | tariffs         | mapping(uint256 => struct Tariff)                 | 3    | 0      | 32    | src/Contract.sol:Contract |
    | contractByM3ter | mapping(uint256 => string)                        | 4    | 0      | 32    | src/Contract.sol:Contract |
    | m3terByContract | mapping(string => uint256)                        | 5    | 0      | 32    | src/Contract.sol:Contract |
    | revenues        | mapping(address => uint256)                       | 6    | 0      | 32    | src/Contract.sol:Contract |
    | tally           | mapping(uint256 => uint256)                       | 7    | 0      | 32    | src/Contract.sol:Contract |<<<
    | feeAddress      | address                                           | 8    | 0      | 20    | src/Contract.sol:Contract |
    */
    uint256 public constant TALLY_SLOT = 7; // ...see above table 👆

    function read(address source, uint256 tokenId, IGatewayVerifier verifier) external view returns (uint256) {
        if (source == address(0)) source = SOURCE;
        GatewayRequest memory request = GatewayFetcher
        .newRequest(1)       // Specify the number of outputs
        .setTarget(source)   // Specify the contract address
        .setSlot(TALLY_SLOT) // Specify the base slot number
        .push(tokenId)       // Specify the mapping key you want to read
        .follow()            // Update the VM internal slot pointer to point to that key
        .read()              // Read the value 
        .setOutput(0);       // Set it at output index 0

        // The chain specific verifier contract defines the appropriate gateway URL for the request, and then verifies the response.
        fetch(verifier, request, this.callback.selector);
    }

    function callback(bytes[] calldata values, uint8, bytes calldata) external pure returns (uint256) {
        return abi.decode(values[0], (uint256));
    }
}
