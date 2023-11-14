

import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import { getPrivateKey, getProviderRpcUrl, getRouterConfig } from "./utils";
import { Wallet, ethers } from "ethers";
import { DestinationMinter, MyNFT } from "../typechain-types";
import { Spinner } from "../utils/spinner";

task(`deploy-destination-minter`, `Deploys MyNFT.sol and DestinationMinter.sol smart contracts`)
    .addOptionalParam(`router`, `The address of the Router contract on the destination blockchain`)
    .setAction(async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
        const routerAddress = taskArguments.router ? taskArguments.router : getRouterConfig(hre.network.name).address;

        const privateKey = getPrivateKey();
        const rpcProviderUrl = getProviderRpcUrl(hre.network.name);

        const provider = new ethers.JsonRpcProvider(rpcProviderUrl);
        const wallet = new Wallet(privateKey);
        const deployer = wallet.connect(provider);

        const spinner: Spinner = new Spinner();

        console.log(`ℹ️  Attempting to deploy MyNFT smart contract on the ${hre.network.name} blockchain using ${deployer.address} address`);
        spinner.start();

        const myNft: MyNFT = await hre.ethers.deployContract("MyNFT");
        await myNft.waitForDeployment();

        spinner.stop();
        console.log(`✅ MyNFT contract deployed at address ${myNft.target} on the ${hre.network.name} blockchain`)

        console.log(`ℹ️  Attempting to deploy DestinationMinter smart contract on the ${hre.network.name} blockchain using ${deployer.address} address, with the Router address ${routerAddress} provided as constructor argument`);
        spinner.start();

        const destinationMinter: DestinationMinter = await hre.ethers.deployContract("DestinationMinter", [routerAddress, myNft.getAddress()]);
        await destinationMinter.waitForDeployment();


        spinner.stop();
        console.log(`✅ DestinationMinter contract deployed at address ${destinationMinter.target} on the ${hre.network.name} blockchain`);

        console.log(`ℹ️  Attempting to grant the minter role to the DestinationMinter smart contract`);
        spinner.start();

        const tx = await myNft.transferOwnership(destinationMinter.getAddress());
        await tx.wait();

        spinner.stop();
        console.log(`✅ DestinationMinter can now mint MyNFTs. Transaction hash: ${tx.hash}`);
    })