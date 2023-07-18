

import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import { getPrivateKey, getProviderRpcUrl, getRouterConfig } from "./utils";
import { Wallet, providers } from "ethers";
import { DestinationMinter, DestinationMinter__factory, MyNFT, MyNFT__factory } from "../typechain-types";
import { Spinner } from "../utils/spinner";

task(`deploy-destination-minter`, `Deploys MyNFT.sol and DestinationMinter.sol smart contracts`)
    .addOptionalParam(`router`, `The address of the Router contract on the destination blockchain`)
    .setAction(async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
        const routerAddress = taskArguments.router ? taskArguments.router : getRouterConfig(hre.network.name).address;

        const privateKey = getPrivateKey();
        const rpcProviderUrl = getProviderRpcUrl(hre.network.name);

        const provider = new providers.JsonRpcProvider(rpcProviderUrl);
        const wallet = new Wallet(privateKey);
        const deployer = wallet.connect(provider);

        const spinner: Spinner = new Spinner();

        console.log(`ℹ️  Attempting to deploy MyNFT smart contract on the ${hre.network.name} blockchain using ${deployer.address} address`);
        spinner.start();

        const myNftFactory: MyNFT__factory = await hre.ethers.getContractFactory('MyNFT') as MyNFT__factory;
        const myNft: MyNFT = await myNftFactory.deploy();
        await myNft.deployed();

        spinner.stop();
        console.log(`✅ MyNFT contract deployed at address ${myNft.address} on the ${hre.network.name} blockchain`)

        console.log(`ℹ️  Attempting to deploy DestinationMinter smart contract on the ${hre.network.name} blockchain using ${deployer.address} address, with the Router address ${routerAddress} provided as constructor argument`);
        spinner.start();

        const destinationMinterFactory: DestinationMinter__factory = await hre.ethers.getContractFactory('DestinationMinter') as DestinationMinter__factory;
        const destinationMinter: DestinationMinter = await destinationMinterFactory.deploy(routerAddress, myNft.address);
        await destinationMinter.deployed();

        spinner.stop();
        console.log(`✅ DestinationMinter contract deployed at address ${destinationMinter.address} on the ${hre.network.name} blockchain`);

        console.log(`ℹ️  Attempting to grant the minter role to the DestinationMinter smart contract`);
        spinner.start();

        const tx = await myNft.transferOwnership(destinationMinter.address);
        await tx.wait();

        spinner.stop();
        console.log(`✅ DestinationMinter can now mint MyNFTs. Transaction hash: ${tx.hash}`);
    })