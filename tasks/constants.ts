export type AddressMap = { [blockchain: string]: string };
export type TokenAmounts = { token: string, amount: string }

export enum PayFeesIn {
    Native,
    LINK
}

export const supportedNetworks = [
    `ethereumSepolia`,
    `optimismSepolia`,
    `arbitrumSepolia`,
    `avalancheFuji`,
    `polygonMumbai`,
];

export const LINK_ADDRESSES: AddressMap = {
    [`ethereumSepolia`]: `0x779877A7B0D9E8603169DdbD7836e478b4624789`,
    [`polygonMumbai`]: `0x326C977E6efc84E512bB9C30f76E30c160eD06FB`,
    [`optimismSepolia`]: `0xE4aB69C077896252FAFBD49EFD26B5D171A32410`,
    [`arbitrumSepolia`]: `0xb1D4538B4571d411F07960EF2838Ce337FE1E80E`,
    [`avalancheFuji`]: `0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846`
};

export const routerConfig = {
    ethereumSepolia: {
        address: `0x0bf3de8c5d3e8a2b34d2beeb17abfcebaf363a59`,
        chainSelector: `16015286601757825753`,
        feeTokens: [LINK_ADDRESSES[`ethereumSepolia`], `0x097D90c9d3E0B50Ca60e1ae45F6A81010f9FB534`]
    },
    optimismSepolia: {
        address: `0x114a20a10b43d4115e5aeef7345a1a71d2a60c57`,
        chainSelector: `5224473277236331295`,
        feeTokens: [LINK_ADDRESSES[`optimismSepolia`], `0x4200000000000000000000000000000000000006`]
    },
    avalancheFuji: {
        address: `0xf694e193200268f9a4868e4aa017a0118c9a8177`,
        chainSelector: `14767482510784806043`,
        feeTokens: [LINK_ADDRESSES[`avalancheFuji`], `0xd00ae08403B9bbb9124bB305C09058E32C39A48c`]
    },
    arbitrumSepolia: {
        address: `0x2a9C5afB0d0e4BAb2BCdaE109EC4b0c4Be15a165`,
        chainSelector: `3478487238524512106`,
        feeTokens: [LINK_ADDRESSES[`arbitrumSepolia`], `0xE591bf0A0CF924A0674d7792db046B23CEbF5f34`]
    },
    polygonMumbai: {
        address: `0x1035cabc275068e0f4b745a29cedf38e13af41b1`,
        chainSelector: `12532609583862916517`,
        feeTokens: [LINK_ADDRESSES[`polygonMumbai`], `0x9c3C9283D3e44854697Cd22D3Faa240Cfb032889`]
    }
}