# ApeLock

![](https://i.imgur.com/tiUA0pi.jpg)



### Motivation
Users participating in apelympics must be reawarded for their hard work. Day trading uncertain markets for a week using unprecedented leverage and turning a profit is more than hard, its close to impossible. Those who get liquidated because of unproper risk management strategies will hopefully find it to be a very educational experience as long as proper self-reflection is done.

Those who turn on a profit will find glory, gain reputation, social status and of course a positive P&L increase.

Because it is important to incentivize hard (and smart) work, the winner shall be rewarded. All participants must bow and acknowledge the winners superior trading intellect, so what better way to show such respect than a financial reward.

<br>

### Network: Polygon
Is cheap, is good. [USDC contract address](https://polygonscan.com/token/0x2791bca1f2de4661ed88a30c99a7a9449aa84174).


<br>

### The Pot
All participants willing to partake in Apelympics must deposit `20 USDC` in a pot. The winner takes it all.

5 trusted members of the community will hold the keys to release the funds. 3 out of 5 must agree on the winner for him to claim such funds.

![](https://i.imgur.com/yQQQcFS.png)



### The Contract
- [See here](https://github.com/misirov/ApeLock/blob/main/src/ApeLock.sol)

#### Specification

```solidity
function registerApe(string memory _name, uint256 _deposit) external {}
```
- Deposit function to transfer ERC-20 USDC tokens to the contract.
- Registers user data: `discord username`, `user address` & `amount deposited`.
- Maps user `address` to `struct`, tracking user registrations.
- `reverts` if transfer fails.
- Emits `apeRegistered` event.

<br>

```solidity
function castVote(address _addr) external {}
```
- 3 trusted addressess must vote for the winner to withdraw the pot.
- Participant who received the vote has his `votes` increased by 1.
- An address that voted is removed from the trusted list to prevent voting again.
- Emits `voteCasted` event.


<br>

```solidity
function winnerWithdraw() external {}
```
- Transfers all USDC from the contract if votes are equal or greater than 3. 
- Updates `apeWinner` public variable to display the winner.
- Emits `winnerWithdrawed()` event.

<br>

```solidity
function viewApe() external view returns(string memory, address, uint256, uint256){}
```
- Returns user registration information.


<br>

```solidity
function numberOfApes() external view returns(uint256){}
```
- Returns the number of registered users.

<br>

```solidity
function apeLockBalance() public view returns(uint256){}
```
- Returns this contract USDC balance.

<br>

```solidity
function userBlance(address _apeAddress) public view returns(uint256){}
```
- Returns user USDC balance.
