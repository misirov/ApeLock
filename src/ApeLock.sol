// SPDX-License-Identifier: UNLICENSED
//
//   /$$$$$$                      /$$                                   /$$                    
//  /$$__  $$                    | $$                                  |__/                    
// | $$  \ $$  /$$$$$$   /$$$$$$ | $$ /$$   /$$ /$$$$$$/$$$$   /$$$$$$  /$$  /$$$$$$$  /$$$$$$$
// | $$$$$$$$ /$$__  $$ /$$__  $$| $$| $$  | $$| $$_  $$_  $$ /$$__  $$| $$ /$$_____/ /$$_____/
// | $$__  $$| $$  \ $$| $$$$$$$$| $$| $$  | $$| $$ \ $$ \ $$| $$  \ $$| $$| $$      |  $$$$$$ 
// | $$  | $$| $$  | $$| $$_____/| $$| $$  | $$| $$ | $$ | $$| $$  | $$| $$| $$       \____  $$
// | $$  | $$| $$$$$$$/|  $$$$$$$| $$|  $$$$$$$| $$ | $$ | $$| $$$$$$$/| $$|  $$$$$$$ /$$$$$$$/
// |__/  |__/| $$____/  \_______/|__/ \____  $$|__/ |__/ |__/| $$____/ |__/ \_______/|_______/ 
//           | $$                     /$$  | $$              | $$                              
//           | $$                    |  $$$$$$/              | $$                              
//           |__/                     \______/               |__/                              
// 
//            ."`".
//        .-./ _=_ \.-.
//       {  (,($Y$),) }}
//       {{ |   "   |} }
//       { { \(---)/  }}
//       {{  }'-=-'{ } }
//       { { }._:_.{  }}
//       {{  } -:- { } }
//       {_{ }`===`{  _}
//      ((((\)     (/))))

pragma solidity 0.8.13;

import "./IERC20.sol";

contract ApeLock {

    ///////////////
    //  ERRORS  //
    //////////////
    error transferError();


    //////////////
    //  EVENTS  //
    //////////////

    event apeRegistered(string _name, address _apeAddress, uint256 _depoist);

    event voteCasted(address _voter, address _voteFor, uint256 _time);

    event winnerWithdrawed(address _winnerApe, uint256 _apeLockBalance);


    ///////////////
    // STORAGE  //
    //////////////

    //USDC Polygon network address https://polygonscan.com/token/0x2791bca1f2de4661ed88a30c99a7a9449aa84174
    IERC20 usdc = IERC20(0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174);
    
    // 20 USDC
    uint256 constant MIN_AMOUNT = 20*10**18; 

    // Minumum amount of votes
    uint256 constant MIN_VOTES = 3; 

    // Set at the end of the competition
    address public apeWinner;

    struct Ape {
        string name;
        address addr;
        uint256 deposit;
        uint256 votes;
    }

    Ape ape;
    Ape[] public apes;
    mapping(address => Ape) public addressToApe;
    mapping(address => bool) public trustedAddress;


    //////////////////
    // CONSTRUCTOR  //
    //////////////////

    /*
        @param   _addr: List of trusted addressess.
    */
    constructor(address[] memory _addr){
        uint i;
        uint len = _addr.length;
        for(; i < len; ){
            address add = _addr[i];
            trustedAddress[add] = true;
            unchecked {
                ++i;
            }
        }
    }


    /////////////////////
    // CONTRACT LOGIC  //
    ////////////////////

    /*
        @notice     Registers user and throws event.
        @dev        Must send minimum 20 USDC.
        @param      _name: Apes discord username
        @param      _deposit: Amount of USDC to deposit.
    */
    function registerApe(string memory _name, uint256 _deposit) external {
        require(_deposit >= MIN_AMOUNT, "ERR_MIN_20USDC");
        bool success = usdc.transferFrom(msg.sender, address(this), _deposit);
        if(!success) revert transferError();

        assert(usdc.balanceOf(address(this)) >= _deposit);

        ape.name = _name;
        ape.addr = msg.sender;
        ape.deposit = _deposit;
        addressToApe[msg.sender] = ape;
        apes.push(ape);
        
        emit apeRegistered(_name, msg.sender, _deposit);
    }

    /*
        @notice     Trusted addresses can vote for the winner.
        @dev        After voting removing from trust list to prevent double voting.
        @param      _addr: Address to vote for.
    */
    function castVote(address _addr) external {
        require(trustedAddress[msg.sender], "ERR_Not_Trusted");
        Ape storage a = addressToApe[_addr];
        a.votes += 1;
        trustedAddress[msg.sender] = false;

        emit voteCasted(msg.sender, _addr, block.timestamp);
    }

    /*
        @notice     The winner of the competition can withdraw the pot after 3 trusted addressess voted to verify the result.
    */
    function winnerWithdraw() external {
        Ape storage a = addressToApe[msg.sender];
        require(a.votes >= MIN_VOTES, "not enough votes");
        uint256 balance = apeLockBalance();
        usdc.transferFrom(address(this), msg.sender, balance);
        apeWinner = msg.sender;

        emit winnerWithdrawed(msg.sender, balance);
    }



    /////////////////////
    //  VIEW FUNCTIONS //
    /////////////////////

    function viewApe() external view returns(string memory, address, uint256, uint256){
        Ape memory a = addressToApe[msg.sender];
        string memory a_name = a.name;
        address a_addr = a.addr;
        uint256 a_deposit = a.deposit;
        uint256 a_votes = a.votes;
        return (a_name, a_addr, a_deposit, a_votes);
    }

    function numberOfApes() external view returns(uint256){
        return apes.length;
    }

    function apeLockBalance() public view returns(uint256){
        return usdc.balanceOf(address(this));
    }

    function userBlance(address _apeAddress) public view returns(uint256){
        return usdc.balanceOf(_apeAddress);
    }

}
