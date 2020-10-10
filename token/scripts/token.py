from brownie import Auction, accounts


def main():
    account = accounts.load('metamask')
    return Auction.deploy(1000, account.address, {'from': account})
