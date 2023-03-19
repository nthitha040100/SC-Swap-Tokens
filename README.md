# SC-Swap-Tokens

Place where one can
<li> Open a swap request with the tokens to be swapped and the address and amount of the token to be swapped with. </li>
<li> Closed a swap by entering the swap id and the token required by the initiator of that swap. </li>
<li> Revoke the swap by entering the swap id ( Only by the initiator of that swap). </li>
<li> Get the status of that swap. </li>

### Functions
openSwap(uint256 _swapID, address _erc20DT, address _erc20WDT, uint256 _amountDT, uint256 _amountWDT)\
closeSwap(uint256 _swapID)\
revokeSwap(uint256 _swapID)\
checkSwap(uint256 _swapID)

### Events
OpenSwap (uint256 swapID, address erc20DT, address erc20WDT, uint256 amountDT, uint256 amountWDT, address initiator)\
CloseSwap (uint256 swapID, address closedBy)\
RevokeSwap (uint256 swapID)

### Modifiers
onlyOpenSwaps(uint256 _swapID)\
onlyInitiator(uint256 _swapID)\
notInitiator(uint256 _swapID)
