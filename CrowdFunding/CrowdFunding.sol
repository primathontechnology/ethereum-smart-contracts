// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.5;

contract CrowdFunding {
    mapping(address => uint256) public contributors;
    address public admin;
    uint256 public noOfContributors;
    uint256 public minimumContribution;
    uint256 public deadline; //timestamp
    uint256 public goal;
    uint256 public raisedAmount;

    // Spending Request
    struct Request {
        string description;
        address payable recipient;
        uint256 value;
        bool completed;
        uint256 noOfVoters;
        mapping(address => bool) voters;
    }

    // mapping of spending requests
    // the key is the spending request number (index) - starts from zero
    // the value is a Request struct
    mapping(uint256 => Request) public requests;
    uint256 public numRequests;

    // events to emit
    event ContributeEvent(address _sender, uint256 _value);
    event CreateRequestEvent(
        string _description,
        address _recipient,
        uint256 _value
    );
    event MakePaymentEvent(address _recipient, uint256 _value);

    constructor(uint256 _goal, uint256 _deadline) {
        goal = _goal;
        deadline = block.timestamp + _deadline;
        admin = msg.sender;
        minimumContribution = 100 wei;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can execute this");
        _;
    }

    function contribute() public payable {
        require(block.timestamp < deadline, "The Deadline has passed!");
        require(
            msg.value >= minimumContribution,
            "The Minimum Contribution not met!"
        );

        // incrementing the no. of contributors the first time when
        // someone sends eth to the contract
        if (contributors[msg.sender] == 0) {
            noOfContributors++;
        }

        contributors[msg.sender] += msg.value;
        raisedAmount += msg.value;

        emit ContributeEvent(msg.sender, msg.value);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // a contributor can get a refund if goal was not reached within the deadline
    function getRefund() public {
        require(block.timestamp > deadline, "Deadline has not passed");
        require(raisedAmount < goal, "The goal was met");
        require(contributors[msg.sender] > 0);

        address payable recipient = payable(msg.sender);
        uint256 value = contributors[msg.sender];
        recipient.transfer(value);
        // equivalent to:
        // payable(msg.sender).transfer(contributors[msg.sender]);

        contributors[msg.sender] = 0;
    }

    function createRequest(
        string calldata _description,
        address payable _recipient,
        uint256 _value
    ) public onlyAdmin {
        //numRequests starts from zero
        Request storage newRequest = requests[numRequests];
        numRequests++;

        newRequest.description = _description;
        newRequest.recipient = _recipient;
        newRequest.value = _value;
        newRequest.completed = false;
        newRequest.noOfVoters = 0;

        emit CreateRequestEvent(_description, _recipient, _value);
    }

    function voteRequest(uint256 _requestNo) public {
        require(
            contributors[msg.sender] > 0,
            "You must be a contributor to vote!"
        );

        Request storage thisRequest = requests[_requestNo];
        require(
            thisRequest.voters[msg.sender] == false,
            "You have already voted!"
        );

        thisRequest.voters[msg.sender] = true;
        thisRequest.noOfVoters++;
    }

    function makePayment(uint256 _requestNo) public onlyAdmin {
        Request storage thisRequest = requests[_requestNo];
        require(
            thisRequest.completed == false,
            "The request has been already completed!"
        );

        require(
            thisRequest.noOfVoters > noOfContributors / 2,
            "The request needs more than 50% of the contributors."
        );
        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.completed = true;

        emit MakePaymentEvent(thisRequest.recipient, thisRequest.value);
    }
}
