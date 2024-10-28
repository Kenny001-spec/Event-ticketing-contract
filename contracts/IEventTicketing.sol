// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;


interface  IEventTicketing {

    function safeMint(address to, string memory uri) external;
    
}