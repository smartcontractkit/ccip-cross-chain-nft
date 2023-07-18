import { task } from "hardhat/config";
import { TaskArguments } from "hardhat/types";
import { getProviderRpcUrl } from "./utils";
import { providers } from "ethers";
import { MyNFT, MyNFT__factory } from "../typechain-types";
import { Spinner } from "../utils/spinner";

task('balance-of', 'Gets the balance of MyNFTs for provided address')
    .addParam(`myNft`, `The address of the MyNFT smart contract`)
    .addParam(`blockchain`, `The blockchain where the MyNFT smart contract was deployed`)
    .addParam(`owner`, `The address to check the balance of MyNFTs`)
    .setAction(async (taskArguments: TaskArguments) => {
        const rpcProviderUrl = getProviderRpcUrl(taskArguments.blockchain);
        const provider = new providers.JsonRpcProvider(rpcProviderUrl);

        const spinner: Spinner = new Spinner();

        const myNft: MyNFT = MyNFT__factory.connect(taskArguments.myNft, provider);

        console.log(`ℹ️  Attempting to check the balance of MyNFTs (${taskArguments.myNft}) for the ${taskArguments.owner} account`);
        spinner.start();

        const balanceOf = await myNft.balanceOf(taskArguments.owner);

        spinner.stop();
        console.log(`ℹ️  The balance of MyNFTs of the ${taskArguments.owner} account is ${balanceOf.toNumber()}`);
    })