# Contracts

ReadMe Instructions

Step 1) Deploy Contract leaving "uri string" paramater blank

Step 2) Verify Contract

Minting / Airdrop Instructions

Step 1) Upload drop image to IPFS

Step 2) Upload Metadata to IPFS in this format:

{
  "name": "NFT Name",
  "description": "NFT Description",
  "image": "ipfs://QmTRup7Ki2pjHu4NpfxmKAC14RcNpfWsCqtdewftwyvPGP/hidden.png"
}

Step 3) Use set new URI for next drop (set URI function) 
in this format (link to metadata on IPFS):
ipfs://Qme5osbFFBktLNPra9ZHHdfopRpEJRDBrHzyizoNoDX7wm/hidden.json

Step 4) Use "airdrop" function to mint/send NFT's instantly

_dropNumber = first drop is 1, second 2, etc 

_list = List of addresses for airdrop in this format:

["0x102f45ccc811f9d718f3a07277a9c9D1616A6Afe","0x464C0298a4B4f6c9B1978Cf8353e63f384bC5914"]

- function will mint / airdrop 1 NFT per address in list
