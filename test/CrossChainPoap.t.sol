// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {CCIPLocalSimulatorFork, Register} from "@chainlink/local/src/ccip/CCIPLocalSimulatorFork.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {CrossChainPOAP} from "../src/CrossChainPOAP.sol";
import {EncodeExtraArgs} from "./utils/EncodeExtraArgs.sol";

contract CrossChainPOAPTest is Test {
    CCIPLocalSimulatorFork public ccipLocalSimulatorFork;
    uint256 baseFork;
    uint256 polygonFork;
    Register.NetworkDetails public baseNetworkDetails;
    Register.NetworkDetails public polygonNetworkDetails;

    address alice;
    address bob;

    // POAP contract instances on each chain
    CrossChainPOAP public basePOAP;
    CrossChainPOAP public polygonPOAP;

    EncodeExtraArgs public encodeExtraArgs;

    function setUp() public {
        alice = makeAddr("alice");
        bob = makeAddr("bob");

        // Get RPC URLs from the environment
        string memory BASE_RPC_URL = vm.envString("BASE_SEPOLIA_RPC_URL");
        string memory POLYGON_RPC_URL = vm.envString("POLYGON_AMOY_RPC_URL");

        // Create forks for Base and Polygon Amoy
        baseFork = vm.createFork(BASE_RPC_URL);
        polygonFork = vm.createFork(POLYGON_RPC_URL);

        // Deploy the CCIP simulator and persist it across forks
        ccipLocalSimulatorFork = new CCIPLocalSimulatorFork();
        vm.makePersistent(address(ccipLocalSimulatorFork));

        // Deploy the POAP contract on Base (source)
        vm.selectFork(baseFork);
        baseNetworkDetails = ccipLocalSimulatorFork.getNetworkDetails(block.chainid);
        console.log("Base network details:");
        console.log("  Router Address: %s", baseNetworkDetails.routerAddress);
        console.log("  LINK Token: %s", baseNetworkDetails.linkAddress);
        console.log("  Chain Selector: %s", baseNetworkDetails.chainSelector);
        basePOAP = new CrossChainPOAP(
            baseNetworkDetails.routerAddress,
            baseNetworkDetails.linkAddress,
            baseNetworkDetails.chainSelector
        );

        // Deploy the POAP contract on Polygon Amoy (destination)
        vm.selectFork(polygonFork);
        // Override the polygon network details using env variables.
        polygonNetworkDetails.routerAddress = vm.envAddress("POLYGON_CCIP_ROUTER");
        polygonNetworkDetails.linkAddress = vm.envAddress("POLYGON_LINK_TOKEN");
        polygonNetworkDetails.chainSelector = uint64(vm.envUint("POLYGON_CHAIN_SELECTOR"));
        polygonPOAP = new CrossChainPOAP(
            polygonNetworkDetails.routerAddress,
            polygonNetworkDetails.linkAddress,
            polygonNetworkDetails.chainSelector
        );
    }

    /// @notice Direct mint on Base (source chain)
    function testDirectMintOnBase() public {
        vm.selectFork(baseFork);
        vm.startPrank(alice);
        string memory directTokenURI = "ipfs://directMintPOAPBase";
        basePOAP.mint(directTokenURI);
        uint256 tokenId = 0; // First minted token.
        assertEq(basePOAP.balanceOf(alice), 1);
        assertEq(basePOAP.ownerOf(tokenId), alice);
        assertEq(basePOAP.tokenURI(tokenId), directTokenURI);
        vm.stopPrank();
    }

    /// @notice Cross-chain mint from Base to Polygon Amoy.
    function testCrossChainMintFromBaseToPolygon() public {
        // Base, enable Polygon Amoy for cross-chain minting.
        vm.selectFork(baseFork);
        encodeExtraArgs = new EncodeExtraArgs();
        uint256 gasLimit = 200_000;
        bytes memory extraArgs = encodeExtraArgs.encode(gasLimit);
        basePOAP.enableChain(polygonNetworkDetails.chainSelector, address(polygonPOAP), extraArgs);

        // Polygon Amoy, enable Base for cross-chain minting.
        vm.selectFork(polygonFork);
        polygonPOAP.enableChain(baseNetworkDetails.chainSelector, address(basePOAP), extraArgs);

        vm.selectFork(baseFork);
        //  Base contract with LINK (3 LINK).
        ccipLocalSimulatorFork.requestLinkFromFaucet(address(basePOAP), 3 ether);

        //  Alice initiate a cross-chain mint for Bob targeting Polygon Amoy.
        vm.selectFork(baseFork);
        vm.startPrank(alice);
        string memory testTokenURI = "ipfs://testPOAPPolygon";
        basePOAP.crossChainMint(
            bob,
            testTokenURI,
            polygonNetworkDetails.chainSelector,
            CrossChainPOAP.PayFeesIn.LINK
        );
        vm.stopPrank();

        // CCIP message delivery to Polygon Amoy.
        ccipLocalSimulatorFork.switchChainAndRouteMessage(polygonFork);
        assertEq(polygonPOAP.balanceOf(bob), 1);
        uint256 tokenId = 0; 
        assertEq(polygonPOAP.ownerOf(tokenId), bob);
        assertEq(polygonPOAP.tokenURI(tokenId), testTokenURI);
    }

function testManualCCIPReceiveOnPolygon() public {
    vm.selectFork(polygonFork);

     Client.Any2EVMMessage memory message = Client.Any2EVMMessage({
        messageId: bytes32(0xdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef),
        sourceChainSelector: baseNetworkDetails.chainSelector,
        sender: abi.encode(address(basePOAP)), 
        data: abi.encode(bob, string("ipfs://testManualPOAP")),
        destTokenAmounts: new Client.EVMTokenAmount[](0) 
    });


    vm.prank(polygonNetworkDetails.routerAddress);
    polygonPOAP.ccipReceive(message);

    // Validation
    assertEq(polygonPOAP.balanceOf(bob), 1);
    assertEq(polygonPOAP.ownerOf(0), bob);
    assertEq(polygonPOAP.tokenURI(0), "ipfs://testManualPOAP");
}


}
