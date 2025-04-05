// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {ERC721Burnable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {IAny2EVMMessageReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IAny2EVMMessageReceiver.sol";
import {OwnerIsCreator} from "@chainlink/contracts-ccip/src/v0.8/shared/access/OwnerIsCreator.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";


contract CrossChainPOAP is ERC721, ERC721URIStorage, ERC721Burnable, IAny2EVMMessageReceiver, ReentrancyGuard, OwnerIsCreator {
    using SafeERC20 for IERC20;

    enum PayFeesIn {
        Native,
        LINK
    }

    error InvalidRouter(address router);
    error OnlyOnArbitrumSepolia();
    error NotEnoughBalanceForFees(uint256 currentBalance, uint256 calculatedFees);
    error NothingToWithdraw();
    error FailedToWithdrawEth(address owner, address target, uint256 value);
    error ChainNotEnabled(uint64 chainSelector);
    error SenderNotEnabled(address sender);
    error OperationNotAllowedOnCurrentChain(uint64 chainSelector);

    struct POAPDetails {
        address poapAddress;
        bytes ccipExtraArgsBytes;
    }

    uint256 constant ARBITRUM_SEPOLIA_CHAIN_ID = 421614;

    IRouterClient internal immutable i_ccipRouter;
    LinkTokenInterface internal immutable i_linkToken;
    uint64 private immutable i_currentChainSelector;

    uint256 private _nextTokenId;

    mapping(uint64 => POAPDetails) public s_chains;

    event ChainEnabled(uint64 chainSelector, address poapAddress, bytes ccipExtraArgs);
    event ChainDisabled(uint64 chainSelector);
    // tokenId in CrossChainSent is 0 because it will be generated on the destination chain.
    event CrossChainSent(
        address from, address to, uint256 tokenId, uint64 sourceChainSelector, uint64 destinationChainSelector
    );
    event CrossChainReceived(
        address from, address to, uint256 tokenId, uint64 sourceChainSelector, uint64 destinationChainSelector
    );

    modifier onlyRouter() {
        if (msg.sender != address(i_ccipRouter)) {
            revert InvalidRouter(msg.sender);
        }
        _;
    }


    modifier onlyEnabledChain(uint64 _chainSelector) {
        if (s_chains[_chainSelector].poapAddress == address(0)) {
            revert ChainNotEnabled(_chainSelector);
        }
        _;
    }

    modifier onlyEnabledSender(uint64 _chainSelector, address _sender) {
        if (s_chains[_chainSelector].poapAddress != _sender) {
            revert SenderNotEnabled(_sender);
        }
        _;
    }

    modifier onlyOtherChains(uint64 _chainSelector) {
        if (_chainSelector == i_currentChainSelector) {
            revert OperationNotAllowedOnCurrentChain(_chainSelector);
        }
        _;
    }

    constructor(address ccipRouterAddress, address linkTokenAddress, uint64 currentChainSelector)
        ERC721("CrossChain POAP", "POAP")
    {
        if (ccipRouterAddress == address(0)) revert InvalidRouter(address(0));
        i_ccipRouter = IRouterClient(ccipRouterAddress);
        i_linkToken = LinkTokenInterface(linkTokenAddress);
        i_currentChainSelector = currentChainSelector;
    }

    // Updated mint function: takes a token URI as input.
    function mint(string memory tokenUri) external {
        uint256 tokenId = _nextTokenId++;
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, tokenUri);
    }

    function enableChain(uint64 chainSelector, address poapAddress, bytes memory ccipExtraArgs)
        external
        onlyOwner
        onlyOtherChains(chainSelector)
    {
        s_chains[chainSelector] = POAPDetails({poapAddress: poapAddress, ccipExtraArgsBytes: ccipExtraArgs});
        emit ChainEnabled(chainSelector, poapAddress, ccipExtraArgs);
    }

    function disableChain(uint64 chainSelector) external onlyOwner onlyOtherChains(chainSelector) {
        delete s_chains[chainSelector];
        emit ChainDisabled(chainSelector);
    }

    /**
     * @notice Initiates a cross-chain mint request. A new POAP NFT will be minted on the destination chain.
     * @param to The recipient address on the destination chain.
     * @param tokenUri The URI for the POAP metadata.
     * @param destinationChainSelector The target chain selector.
     * @param payFeesIn The token in which fees are paid (Native or LINK).
     * @return messageId The ID of the CCIP message sent.
     */
    function crossChainMint(
        address to,
        string memory tokenUri,
        uint64 destinationChainSelector,
        PayFeesIn payFeesIn
    ) external nonReentrant onlyEnabledChain(destinationChainSelector) returns (bytes32 messageId) {
        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(s_chains[destinationChainSelector].poapAddress),
            data: abi.encode(msg.sender, to, tokenUri),
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: s_chains[destinationChainSelector].ccipExtraArgsBytes,
            feeToken: payFeesIn == PayFeesIn.LINK ? address(i_linkToken) : address(0)
        });

        uint256 fees = i_ccipRouter.getFee(destinationChainSelector, message);

        if (payFeesIn == PayFeesIn.LINK) {
            if (fees > i_linkToken.balanceOf(address(this))) {
                revert NotEnoughBalanceForFees(i_linkToken.balanceOf(address(this)), fees);
            }
            i_linkToken.approve(address(i_ccipRouter), fees);
            messageId = i_ccipRouter.ccipSend(destinationChainSelector, message);
        } else {
            if (fees > address(this).balance) {
                revert NotEnoughBalanceForFees(address(this).balance, fees);
            }
            messageId = i_ccipRouter.ccipSend{value: fees}(destinationChainSelector, message);
        }

        emit CrossChainSent(msg.sender, to, 0, i_currentChainSelector, destinationChainSelector);
        return messageId;
    }

    /**
     * @notice Called by the CCIP router to deliver messages.
     * Decodes the message and mints a new POAP on the destination chain.
     * @param message The CCIP message containing minting details.
     */
    function ccipReceive(Client.Any2EVMMessage calldata message)
        external
        override
        onlyRouter
        nonReentrant
        onlyEnabledChain(message.sourceChainSelector)
        onlyEnabledSender(message.sourceChainSelector, abi.decode(message.sender, (address)))
    {
        uint64 sourceChainSelector = message.sourceChainSelector;
        // Decode the message data: sender, recipient, and token URI.
        (address from, address to, string memory tokenUri) = abi.decode(message.data, (address, address, string));

        // Generate a new tokenId for the minted POAP NFT.
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, tokenUri);

        emit CrossChainReceived(from, to, tokenId, sourceChainSelector, i_currentChainSelector);
    }

    function withdraw(address _beneficiary) public onlyOwner {
        uint256 amount = address(this).balance;
        if (amount == 0) revert NothingToWithdraw();
        (bool sent,) = _beneficiary.call{value: amount}("");
        if (!sent) revert FailedToWithdrawEth(msg.sender, _beneficiary, amount);
    }

    function withdrawToken(address _beneficiary, address _token) public onlyOwner {
        uint256 amount = IERC20(_token).balanceOf(address(this));
        if (amount == 0) revert NothingToWithdraw();
        IERC20(_token).safeTransfer(_beneficiary, amount);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function getCCIPRouter() public view returns (address) {
        return address(i_ccipRouter);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return interfaceId == type(IAny2EVMMessageReceiver).interfaceId || super.supportsInterface(interfaceId);
    }
}
