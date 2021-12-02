# ERC 20

[What is ERC20?](https://www.investopedia.com/tech/why-crypto-users-need-know-about-erc20-token-standard/)


[ERC20 Spec](https://ethereum.org/en/developers/docs/standards/tokens/erc-20/)
## Summary:

ERC20 contains several functions that a compliant token must be able to implement.

**TotalSupply**: provides information about the total token supply
**BalanceOf**: provides account balance of the owner's account
**Transfer**: executes transfers of a specified number of tokens to a specified address
**TransferFrom**: executes transfers of a specified number of tokens from a specified address
**Approve**: allow a spender to withdraw a set number of tokens from a specified account
**Allowance**: returns a set number of tokens from a spender to the owner



## ERC 20 Interface

**Methods:**
```ts
function name() public view returns (string)
function symbol() public view returns (string)
function decimals() public view returns (uint8)
function totalSupply() public view returns (uint256)
function balanceOf(address _owner) public view returns (uint256 balance)
function transfer(address _to, uint256 _value) public returns (bool success)
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success)
function approve(address _spender, uint256 _value) public returns (bool success)
function allowance(address _owner, address _spender) public view returns (uint256 remaining)

```

**Events:**

```ts
event Transfer(address indexed _from, address indexed _to, uint256 _value)
event Approval(address indexed _owner, address indexed _spender, uint256 _value)
```