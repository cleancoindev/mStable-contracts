pragma solidity 0.5.16;


// Internal
import { IVotingLockup } from "./IVotingLockup.sol";
import { RewardsDistributionRecipient } from "../rewards/RewardsDistributionRecipient.sol";

// Libs
import { SafeERC20, IERC20 } from "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { StableMath } from "../shared/StableMath.sol";

/**
 *
 * Supports:
 *    1) Tracking MTA Locked up
 *    2) Pull Based Quasi-variable Weight Reward allocations
 *    3) Decaying voting weight lookup through CheckpointedERC20
 *    4) Kicking fully decayed participants from reward allocation
 *
 * Bonus:
 *    - decay directly tied to voting participation
 *    - non-pull based reward allocations
 *    - capital used for recollateralisation
 */
contract VotingLockup is IVotingLockup, RewardsDistributionRecipient {

    using StableMath for uint256;
    using SafeERC20 for IERC20;

    // Globals
    IERC20 private mta;
    uint256 private constant DURATION = 7 days;
    uint256 public constant MIN_LOCKUP = 7 days;

    // Lockup
    mapping(address => uint256) public stakes;
    mapping(address => uint256) public lockupLengths;

    // Rewards - Global
    uint256 public rewardRate;
    uint256 public rewardPerToken;
    uint256 public rewardFinish;
    uint256 public lastActionTime;
    uint256 public totalRewardWeight;

    // Rewards - Personal
    mapping(address => uint256) public rewardTally;
    mapping(address => uint256) public lastUserActionTime;

    constructor(
        address _nexus,
        address _rewardsDistributor,
        IERC20 _mta
    )
        public
        RewardsDistributionRecipient(_nexus,_rewardsDistributor)
    {
        mta = _mta;
    }


    /***************************************
                    LOCKUP
    ****************************************/

    // Deposits stake & lockups up to nearest period following now+length?
    function createLock(uint256 _amount, uint256 _length) external;
    // Withdraws all the senders stake, if lockup is over. Also withdraws rwd?
    function withdraw() external;
    // Increases amount of stake thats locked up & resets decay
    function increaseLockAmount(uint256 _amount) external;
    // Increases length of lockup & resets decay
    function increaseLockLength(uint256 _newUnlockTime) external;


    /***************************************
                    GETTERS
    ****************************************/

    // Gets user *voting* weights (aka effectiveStake)
    function balanceOf(address _owner) external view returns (uint256);
    function balanceOfAt(address _owner, uint256 _blockNumber) external view returns (uint256);

    // Gets total *voting* weights (aka effectiveStake)
    function totalSupply() external view returns (uint256);
    function totalSupplyAt(uint256 _blockNumber) external view returns (uint256);



    /***************************************
                    REWARDS
    ****************************************/

    // Updates globals && withdraws all the senders rewards
    function getRewardToken() external view returns (IERC20) {
        return mta;
    }

    // Updates globals && withdraws all the senders rewards
    function withdrawRewards() external returns (uint256);

    // Calculates theoretical reward using *current* timestamp/balances/totalSupply
    function computeReward(address _user) external view returns (uint256);

    // Internal func to update rewards. If user == address(0) then just do globals
    function _updateReward(address _user) internal {
        // // Setting of global vars
        // uint256 newRewardPerToken = rewardPerToken();
        // // If statement protects against loss in initialisation case
        // if(newRewardPerToken > 0) {
        //     rewardPerTokenStored = newRewardPerToken;
        //     lastUpdateTime = lastTimeRewardApplicable();
        //     // Setting of personal vars based on new globals
        //     if (_account != address(0)) {
        //         rewards[_account] = earned(_account);
        //         userRewardPerTokenPaid[_account] = newRewardPerToken;
        //     }
        // }
    }

    /*************   ADMIN    *************/
    function notifyRewardAmount(uint256 reward) external;

}