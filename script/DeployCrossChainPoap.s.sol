// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/CrossChainPOAP.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployMultiChainCrossChainPOAP is Script {
    function run() public {
        address basePoapAddress;
        address polygonPoapAddress;

        // Deploy on Base Sepolia
        vm.createSelectFork("baseSepolia");
        vm.startBroadcast();
        // Read Base Sepolia configuration from the environment
        address baseCcRouter = vm.envAddress("BASE_CCIP_ROUTER");
        address baseLinkToken = vm.envAddress("BASE_LINK_TOKEN");
        uint64 baseChainSelector = uint64(vm.envUint("BASE_CHAIN_SELECTOR"));
        CrossChainPOAP basePoap = new CrossChainPOAP(
            baseCcRouter,
            baseLinkToken,
            baseChainSelector
        );
        basePoapAddress = address(basePoap);
        console.log("Deployed CrossChainPOAP on Base Sepolia at:", basePoapAddress);

        IERC20(baseLinkToken).transfer(basePoapAddress, 2 ether);
        console.log("Transferred 2 LINK to Base POAP contract");
        vm.stopBroadcast();

        // Deploy on Polygon Amoy
        vm.createSelectFork("polygonAmoy");
        vm.startBroadcast();
        // Read Polygon Amoy configuration from the environment
        address polygonCcRouter = vm.envAddress("POLYGON_CCIP_ROUTER");
        address polygonLinkToken = vm.envAddress("POLYGON_LINK_TOKEN");
        uint64 polygonChainSelector = uint64(vm.envUint("POLYGON_CHAIN_SELECTOR"));
        CrossChainPOAP polygonPoap = new CrossChainPOAP(
            polygonCcRouter,
            polygonLinkToken,
            polygonChainSelector
        );
        polygonPoapAddress = address(polygonPoap);
        console.log("Deployed CrossChainPOAP on Polygon Amoy at:", polygonPoapAddress);

        // Transfer 5 LINK to the deployed Polygon contract
        IERC20(polygonLinkToken).transfer(polygonPoapAddress, 2 ether);
        console.log("Transferred 2 LINK to Polygon POAP contract");
        vm.stopBroadcast();

        // Prepare extra arguments for cross-chain calls (example: gas limit)
        // uint256 gasLimit = 200_000;
        // bytes memory extraArgs = abi.encode(gasLimit);

        // On Base, enable Polygon Amoy as a target chain
        // vm.createSelectFork("baseSepolia");
        // vm.startBroadcast();
        // CrossChainPOAP(basePoapAddress).enableChain(polygonChainSelector, polygonPoapAddress, extraArgs);
        // console.log("Base POAP enabled Polygon chain with chain selector:", polygonChainSelector);
        // vm.stopBroadcast();

        // // On Polygon, enable Base as a target chain.
        // // Inlined the call to avoid additional local variables and reduce stack usage.
        // vm.createSelectFork("polygonAmoy");
        // vm.startBroadcast();
        // CrossChainPOAP(polygonPoapAddress).enableChain(baseChainSelector, basePoapAddress, extraArgs);
        // console.log("Polygon POAP enabled Base chain with chain selector:", baseChainSelector);
        // vm.stopBroadcast();
    }
}
