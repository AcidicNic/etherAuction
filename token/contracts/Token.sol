pragma solidity ^0.7.0;

/* import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/master/contracts/math/SafeMath.sol"; */

contract Auction {

    /* using SafeMath for uint256; */

    uint256 public endTime;
    address payable public owner;
    bool public auctionFinished;
    address public highestBidder;
    uint256 public highestBid;

    mapping(address => uint256) public bidderToTotalBids;

    event AnnounceWinner(address winner, uint256 winningBid);
    event NewBid(address bidder, uint amount);
    event Withdraw(address bidder, uint256 amount);

    constructor(uint256 _lengthSeconds, address payable _owner) public {
        owner = _owner;
        endTime = block.timestamp + _lengthSeconds;
    }

    modifier isEnded {
        /* require(block.timestamp >= endTime, "This auction will end in " +
            (block.timestamp - endTime) / 1 hours + " hours."); */
        require(block.timestamp >= endTime, "This auction hasn't ended");
        _;
    }

    modifier isNotEnded {
        /* require(block.timestamp < endTime, "This auction ended " +
            (endTime - block.timestamp) / 1 hours + " hours ago."); */
        require(block.timestamp < endTime, "This auction has ended.");
        _;
    }

    modifier isNotOwner {
        require(msg.sender != owner, "This is your auction!");
        _;
    }

    function auctionEnd() isEnded public {
        require(!auctionFinished, "This action has already ended.");

        auctionFinished = true;
        emit AnnounceWinner(highestBidder, highestBid);

        owner.transfer(highestBid);
    }

    function placeBid() payable isNotOwner isNotEnded public {
        require(msg.value > 0, "Your bid is too low");
        require(msg.value > highestBid, "Your bid is too low.");
        if (bidderToTotalBids[msg.sender] == 0) {
            bidderToTotalBids[msg.sender] = msg.value;
        } else {
            bidderToTotalBids[msg.sender] += msg.value;
        }
        highestBidder = msg.sender;
        highestBid = msg.value;
        emit NewBid(msg.sender, msg.value);
    }

    function withdraw() isNotOwner public {
        uint256 withdrawAmount = bidderToTotalBids[msg.sender];
        require(withdrawAmount > 0, "Nothing to withdraw.");

        if (msg.sender == highestBidder) {
            withdrawAmount -= highestBid;
            bidderToTotalBids[msg.sender] = highestBid;
        } else {
            bidderToTotalBids[msg.sender] = 0;
        }

        msg.sender.transfer(withdrawAmount);
        emit Withdraw(msg.sender, withdrawAmount);
    }
}
