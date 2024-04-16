import sys
import orjson
import pathlib
from merkle_zeppelin import MerkleTree

def merge(input_files,output_file):
    airdrop={}
    for file in input_files:
        with open(file) as f:
            data=orjson.loads(f.read())
        for item in data['airdrop']:
            if item['address'] in airdrop:
                airdrop[item['address']]+=int(item['token'])
            else:
                airdrop[item['address']]=int(item['token'])
    tree=MerkleTree(
        tuple((index,address,token) for index,(address,token) in enumerate(airdrop.items())),
        ('uint256','address','uint256'),
    )
    output={
        'proof_root':f'0x{tree.root.hex()}',
        'airdrop':[]
    }
    for index,(address,token) in enumerate(airdrop.items()):
        output['airdrop'].append({
            'index':index,
            'address':address,
            'token':str(token),
            'proofs':tuple(f'0x{proof.hex()}' for proof in tree.get_proofs((index,address,token))),
        })
    with open(output_file,'w+') as f:
        f.write(orjson.dumps(output).decode())

def main():
    if len(sys.argv)<3:
        print(f'Usage: python {sys.argv[0]} [input_file]... [output_file]')
        return
    input_files=sys.argv[1:-1]
    output_file=sys.argv[-1]
    for file in input_files:
        if not pathlib.Path(file).exists():
            print('Input file not exists:',file)
            return
    merge(input_files,output_file)

if __name__=='__main__':
    main()