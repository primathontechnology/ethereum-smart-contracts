//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract Auction {
    address payable public owner; // owner / initiator of auction
    uint256 public startBlock; // its analogous to start time of auction
    uint256 public endBlock;
    string public ipfsHash; // hash of product or service (stored off chain)

    enum State {
        Started,
        Running,
        Ended,
        Canceled
    }
    State public auctionState;

    uint256 public highestBindingBid; // the bid amount highest bidder has to pay for service

    address payable public highestBidder;
    mapping(address => uint256) public bids; // map to store address and bid of bidders
    uint256 bidIncrement;

    //the owner can finalize the auction and get the highestBindingBid only once
    bool public ownerFinalized = false;

    constructor() {
        owner = payable(msg.sender);
        auctionState = State.Running;

        startBlock = block.number;
        endBlock = startBlock + 3;

        ipfsHash = "";
        bidIncrement = 1000000000000000000; // bidding in multiple of ETH (wei)
    }

    // declaring function modifiers
    modifier notOwner() {
        require(msg.sender != owner);
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier afterStart() {
        require(block.number >= startBlock);
        _;
    }

    modifier beforeEnd() {
        require(block.number <= endBlock);
        _;
    }

    //a helper pure function (it neither reads, nor it writes to the blockchain)
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a <= b) {
            return a;
        } else {
            return b;
        }
    }

    // only the owner can cancel the Auction before the Auction has ended
    function cancelAuction() public beforeEnd onlyOwner {
        auctionState = State.Canceled;
    }

    // the main function called to place a bid
    function placeBid()
        public
        payable
        notOwner
        afterStart
        beforeEnd
        returns (bool)
    {
        // to place a bid auction should be running
        require(auctionState == State.Running);
        // minimum value allowed to be sent
        // require(msg.value > 0.0001 ether);

        uint256 currentBid = bids[msg.sender] + msg.value;

        // the currentBid should be greater than the highestBindingBid.
        // Otherwise there's nothing to do.
        require(currentBid > highestBindingBid);

        // updating the mapping variable
        bids[msg.sender] = currentBid;

        if (currentBid <= bids[highestBidder]) {
            // highestBidder remains unchanged
            highestBindingBid = min(
                currentBid + bidIncrement,
                bids[highestBidder]
            );
        } else {
            // highestBidder is another bidder
            highestBindingBid = min(
                currentBid,
                bids[highestBidder] + bidIncrement
            );
            highestBidder = payable(msg.sender);
        }
        return true;
    }

    function finalizeAuction() public {
        // the auction has been Canceled or Ended
        require(auctionState == State.Canceled || block.number > endBlock);

        // only the owner or a bidder can finalize the auction
        require(msg.sender == owner || bids[msg.sender] > 0);

        // the recipient will get the value
        address payable recipient;
        uint256 value;

        if (auctionState == State.Canceled) {
            // auction canceled, not ended
            recipient = payable(msg.sender);
            value = bids[msg.sender];
        } else {
            // auction ended, not canceled
            if (msg.sender == owner && ownerFinalized == false) {
                //the owner finalizes the auction
                recipient = owner;
                value = highestBindingBid;

                //the owner can finalize the auction and get the highestBindingBid only once
                ownerFinalized = true;
            } else {
                // another user (not the owner) finalizes the auction
                if (msg.sender == highestBidder) {
                    recipient = highestBidder;
                    value = bids[highestBidder] - highestBindingBid;
                } else {
                    //this is neither the owner nor the highest bidder (it's a regular bidder)
                    recipient = payable(msg.sender);
                    value = bids[msg.sender];
                }
            }
        }

        // resetting the bids of the recipient to avoid multiple transfers to the same recipient
        bids[recipient] = 0;

        //sends value to the recipient
        recipient.transfer(value);
    }
}
