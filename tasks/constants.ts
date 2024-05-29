export type AddressMap = { [blockchain: string]: string };
export type TokenAmounts = { token: string, amount: string }

export enum PayFeesIn {
    Native,
    LINK
}

export const supportedNetworks = [
    `ethereumSepolia`,
    `polygonAmoy`,
    `optimismSepolia`,
    `arbitrumSepolia`,
    `avalancheFuji`,
    `bnbChainTestnet`,
    `baseSepolia`,
    `kromaSepolia`,
    `wemixTestnet`,
    `gnosisChiado`,
    `celoAlfajores`
];

export const LINK_ADDRESSES: AddressMap = {
    [`ethereumSepolia`]: `0x779877A7B0D9E8603169DdbD7836e478b4624789`,
    [`polygonAmoy`]: `0x0Fd9e8d3aF1aaee056EB9e802c3A762a667b1904`,
    [`optimismSepolia`]: `0xE4aB69C077896252FAFBD49EFD26B5D171A32410`,
    [`arbitrumSepolia`]: `0xb1D4538B4571d411F07960EF2838Ce337FE1E80E`,
    [`avalancheFuji`]: `0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846`,
    [`bnbChainTestnet`]: `0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06`,
    [`baseSepolia`]: `0xE4aB69C077896252FAFBD49EFD26B5D171A32410`,
    [`kromaSepolia`]: `0xa75cCA5b404ec6F4BB6EC4853D177FE7057085c8`,
    [`wemixTestnet`]: `0x3580c7A817cCD41f7e02143BFa411D4EeAE78093`,
    [`gnosisChiado`]: `0xDCA67FD8324990792C0bfaE95903B8A64097754F`,
    [`celoAlfajores`]: `0x32E08557B14FaD8908025619797221281D439071`
};

export const routerConfig = {
    ethereumSepolia: {
        address: `0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59`,
        chainSelector: `16015286601757825753`,
        feeTokens: [LINK_ADDRESSES[`ethereumSepolia`], `0x097D90c9d3E0B50Ca60e1ae45F6A81010f9FB534`]
    },
    polygonAmoy: {
        address: `0x9C32fCB86BF0f4a1A8921a9Fe46de3198bb884B2`,
        chainSelector: `16281711391670634445`,
        feeTokens: [LINK_ADDRESSES[`polygonAmoy`], `0x360ad4f9a9A8EFe9A8DCB5f461c4Cc1047E1Dcf9`]
    },
    optimismSepolia: {
        address: `0x114A20A10b43D4115e5aeef7345a1A71d2a60C57`,
        chainSelector: `5224473277236331295`,
        feeTokens: [LINK_ADDRESSES[`optimismSepolia`], `0x4200000000000000000000000000000000000006`]
    },
    avalancheFuji: {
        address: `0xF694E193200268f9a4868e4Aa017A0118C9a8177`,
        chainSelector: `14767482510784806043`,
        feeTokens: [LINK_ADDRESSES[`avalancheFuji`], `0xd00ae08403B9bbb9124bB305C09058E32C39A48c`]
    },
    arbitrumSepolia: {
        address: `0x2a9C5afB0d0e4BAb2BCdaE109EC4b0c4Be15a165`,
        chainSelector: `3478487238524512106`,
        feeTokens: [LINK_ADDRESSES[`arbitrumSepolia`], `0xE591bf0A0CF924A0674d7792db046B23CEbF5f34`]
    },
    bnbChainTestnet: {
        address: `0xE1053aE1857476f36A3C62580FF9b016E8EE8F6f`,
        chainSelector: `13264668187771770619`,
        feeTokens: [LINK_ADDRESSES[`bnbChainTestnet`], `0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd`]
    },
    baseSepolia: {
        address: `0xD3b06cEbF099CE7DA4AcCf578aaebFDBd6e88a93`,
        chainSelector: `10344971235874465080`,
        feeTokens: [LINK_ADDRESSES[`baseSepolia`], `0x4200000000000000000000000000000000000006`]
    },
    kromaSepolia: {
        address: `0xA8C0c11bf64AF62CDCA6f93D3769B88BdD7cb93D`,
        chainSelector: `5990477251245693094`,
        feeTokens: [LINK_ADDRESSES[`kromaSepolia`], `0x4200000000000000000000000000000000000001`]
    },
    wemixTestnet: {
        address: `0xA8C0c11bf64AF62CDCA6f93D3769B88BdD7cb93D`,
        chainSelector: `9284632837123596123`,
        feeTokens: [LINK_ADDRESSES[`wemixTestnet`], `0xbE3686643c05f00eC46e73da594c78098F7a9Ae7`]
    },
    gnosisChiado: {
        address: `0x19b1bac554111517831ACadc0FD119D23Bb14391`,
        chainSelector: `8871595565390010547`,
        feeTokens: [LINK_ADDRESSES[`gnosisChiado`], `0x18c8a7ec7897177E4529065a7E7B0878358B3BfF`]
    },
    celoAlfajores: {
        address: `0xb00E95b773528E2Ea724DB06B75113F239D15Dca`,
        chainSelector: `3552045678561919002`,
        feeTokens: [LINK_ADDRESSES[`celoAlfajores`], `0x99604d0e2EfE7ABFb58BdE565b5330Bb46Ab3Dca`]
    }
}