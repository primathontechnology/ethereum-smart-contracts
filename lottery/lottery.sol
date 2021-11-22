//SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0 <0.9.0;

contract Lottery {
    // declaring the state variables
    address payable[] public players; //dynamic array of type address payable
    address public manager; // store the manager address for lottery (will be taken from initiator address)

    // declaring the constructor
    constructor() {
        // initializing the owner to the address that deploys the contract
        manager = msg.sender;

    // declaring the receive() function that is necessary to receive ETH
    receive() external payable {
        // each player sends exactly 0.1 ETH
        require(msg.value == 0.1 ether);
        // appending the player to the players array
        players.push(payable(msg.sender));
    }

    // returning the contract's balance in wei
    function getBalance() public view returns (uint256) {
        // only the manager is allowed to call it
        require(msg.sender == manager);
        return address(this).balance;
    }

    // helper function that returns a big random integer
    function random() internal view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.difficulty,
                        block.timestamp,
                        players.length
                    )
                )
            );
    }

    // selecting the winner
    function pickWinner() public {
        // only the manager can pick a winner if there are at least 3 players in the lottery
        require(msg.sender == manager);
        require(players.length >= 3);

        uint256 r = random();
        address payable winner;

        // computing a random index of the array
        uint256 index = r % players.length;

        winner = players[index]; // this is the winner

        uint256 managerFee = (getBalance() * 10) / 100; // manager fee is 10%
        uint256 winnerPrize = (getBalance() * 90) / 100; // winner prize is 90%

        // transferring 90% of contract's balance to the winner
        winner.transfer(winnerPrize);

        // transferring 10% of contract's balance to the manager
        payable(manager).transfer(managerFee);

        // resetting the lottery for the next round
        // setting players array as empty
        players = new address payable[](0);
    }
}
