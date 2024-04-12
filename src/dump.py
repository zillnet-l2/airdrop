import sys
import click
import orjson
import rtoml
import pathlib
import web3
from decimal import Decimal
from merkle_zeppelin import MerkleTree

def get_provider(rpc):
    rpc=rpc.lower()
    if rpc.startswith('http://') or rpc.startswith('https://'):
        return web3.HTTPProvider(rpc)
    else:
        return web3.IPCProvider(rpc)

def dump(output_file):
    config=rtoml.load(pathlib.Path('config.toml'))
    w3=web3.Web3(get_provider(config['rpc']))
    participants={}
    with click.progressbar(range(config['from_block'],config['to_block']+1)) as bar:
        for number in bar:
            block=w3.eth.get_block(number)
            # print(number)
            for tx in block.transactions:
                receipt=w3.eth.get_transaction_receipt(tx)
                if not receipt.status or not receipt.effectiveGasPrice:
                    continue
                fee=receipt.gasUsed*receipt.effectiveGasPrice
                if receipt['from'] in participants:
                    participants[receipt['from']]+=fee
                else:
                    participants[receipt['from']]=fee
    total_fee=sum(participants.values())
    amount=Decimal(config['amount'])
    total_token=Decimal(config['total_token'])
    total_refund=total_fee-amount if total_fee>amount else 0
    airdrop=[]
    final_token=0
    final_refund=0
    for index,address in enumerate(participants.keys()):
        fee=participants[address]
        percent=Decimal(fee)/Decimal(total_fee)
        token=int(total_token*percent)
        refund=0
        if total_refund:
            refund=int(Decimal(total_refund)*percent)
        airdrop.append({
            'index':index,
            'address':address,
            'fee':str(fee),
            'token':str(token),
            'refund':str(refund),
            'refund_int':refund,
            # 'percent':percent,
        })
        final_token+=token
        final_refund+=refund
    output={
        'total_fee':str(total_fee),
        'total_token':str(total_token),
        'total_refund':str(total_refund),
        'final_token':str(final_token),
        'final_refund':str(final_refund),
    }
    if total_refund:
        tree=MerkleTree(
            tuple((row['index'],row['address'],row['refund_int']) for row in airdrop),
            ('uint256','address','uint256'),
        )
        for row in airdrop:
            row['refund_proofs']=tuple(
                f'0x{proof.hex()}' for proof in tree.get_proofs((row['index'],row['address'],row['refund_int']))
            )
        output['refund_proof_root']=f'0x{tree.root.hex()}'
    for row in airdrop:
        row.pop('refund_int')
    output['airdrop']=airdrop
    with open(output_file,'w+') as f:
        f.write(orjson.dumps(output).decode())

def main():
    if len(sys.argv)<2:
        print(f'Usage: python {sys.argv[0]} [output_file]')
        return
    dump(sys.argv[1])

if __name__=='__main__':
    main()