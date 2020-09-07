pragma solidity 0.5.16;


// From Aragon https://github.com/aragonone/voting-connectors
interface IERC20WithCheckpointing {
    // Gets *voting* weights (aka effectiveStake)
    function balanceOf(address _owner) public view returns (uint256);
    function balanceOfAt(address _owner, uint256 _blockNumber) public view returns (uint256);

    // Gets total *voting* weights (aka effectiveStake)
    function totalSupply() public view returns (uint256);
    function totalSupplyAt(uint256 _blockNumber) public view returns (uint256);
}

contract IVotingLockup is IERC20WithCheckpointing {

    /* Storage */
    // Data interfaces/structs && storage layouts

    /* Lockup */
    // Deposits stake & lockups up to nearest period following now+length?
    function createLock(uint256 _amount, uint256 _length) external;
    // Withdraws all the senders stake, if lockup is over. Also withdraws rwd?
    function withdraw() external;
    // Increases amount of stake thats locked up & resets decay
    function increaseLockAmount(uint256 _amount) external;
    // Increases length of lockup & resets decay
    function increaseLockLength(uint256 _newUnlockTime) external;

    /* Rewards */
    // Updates globals && withdraws all the senders rewards
    function withdrawRewards() external returns (uint256);
    // Calculates theoretical reward using *current* timestamp/balances/totalSupply
    function computeReward(address _user) external view returns (uint256);
    // Internal func to update rewards. If user == address(0) then just do globals
    function _updateReward(address _user) internal;

    // TODO - consider blocking wrappers
}