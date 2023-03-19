//SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract AtomicSwapERC20 {

    struct Swap{
        uint256 swapID;
        address erc20DT;
        address erc20WDT;
        uint256 amountDT;
        uint256 amountWDT;
        address initiator;
    }

    enum States {
        OPEN,
        CLOSED,
        REVOKED
    }
    event OpenSwap (uint256 swapID, address erc20DT, address erc20WDT, uint256 amountDT, uint256 amountWDT, address initiator);
    event CloseSwap (uint256 swapID, address closedBy);
    event RevokeSwap (uint256 swapID);

    mapping(uint256 => Swap) public swaps;
    mapping(uint256 => States) public swapStates;

    function openSwap(uint256 _swapID, address _erc20DT, address _erc20WDT, uint256 _amountDT, uint256 _amountWDT) public {

        IERC20 erc20DT = IERC20(_erc20DT);
        require(erc20DT.allowance(msg.sender, address(this)) >= _amountDT);
        require(erc20DT.transferFrom(msg.sender, address(this), _amountDT));

        Swap memory swap = Swap({
            swapID: _swapID,
            erc20DT: _erc20DT,
            erc20WDT: _erc20WDT,
            amountDT: _amountDT,
            amountWDT: _amountWDT,
            initiator: msg.sender
        });

        swaps[_swapID] = swap;
        swapStates[_swapID] = States.OPEN;

        emit OpenSwap(_swapID,_erc20DT,_erc20WDT,_amountDT,_amountWDT,msg.sender);
    }



    function closeSwap(uint256 _swapID) public onlyOpenSwaps(_swapID) notInitiator(_swapID) {
        Swap memory swap = swaps[_swapID];

        IERC20 erc20DT = IERC20(swap.erc20DT);
        IERC20 erc20WDT = IERC20(swap.erc20WDT);

        swapStates[_swapID] = States.CLOSED;
        require(swap.amountWDT <= erc20WDT.allowance(msg.sender, address(this)));

        require(erc20WDT.transferFrom(msg.sender, swap.initiator, swap.amountWDT));

        require(erc20DT.transfer(msg.sender, swap.amountDT));


        emit CloseSwap(_swapID, msg.sender);

    }

    function revokeSwap(uint256 _swapID) public onlyOpenSwaps(_swapID) onlyInitiator(_swapID) {
        Swap memory swap = swaps[_swapID];
        swapStates[_swapID] = States.REVOKED;

        IERC20 erc20ContractDT = IERC20(swap.erc20DT);
        require(erc20ContractDT.transfer(swap.initiator, swap.amountDT));

        emit RevokeSwap(_swapID);
    }

    
    function checkSwap(uint256 _swapID) public view returns (States){
        return swapStates[_swapID];
    }

    function getContractAddress() public view returns(address){
        return address(this);
    }


    modifier onlyOpenSwaps(uint256 _swapID) {
        require(swapStates[_swapID] == States.OPEN);
        _;
    }

    modifier onlyInitiator(uint256 _swapID) {
        require(msg.sender == swaps[_swapID].initiator, "You can not close the trade!");
        _;
    }

    modifier notInitiator(uint256 _swapID) {
        require(msg.sender != swaps[_swapID].initiator, "You can not close the trade!");
        _;
    }


}