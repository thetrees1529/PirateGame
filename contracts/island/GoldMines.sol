//SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.19;
import "../AccessControlGrantDeployer.sol";

contract GoldMines is AccessControlGrantDeployer {

    uint public goldRate;
    uint private _lastGoldTime;
    uint private _goldPerWeighting;
    uint private _totalWeightings;
    

    struct MineInfo {
        uint weighting;
        uint debt;
        uint owed;
    }

    struct SetMineWeightingsInput {
        uint islandId;
        uint weighting;
    }

    struct GetMineInfosOutput {
        uint weighting;
        uint goldRate;
        uint toClaim;
    }


    mapping(uint => MineInfo) private _mineInfos;

    function getMineInfos(uint[] calldata islandIds) external view returns(GetMineInfosOutput[] memory outputs) {
        outputs = new GetMineInfosOutput[](islandIds.length);
        for(uint i = 0; i < islandIds.length; i++) {
            MineInfo storage _mineInfo = _mineInfos[islandIds[i]];
            outputs[i] = GetMineInfosOutput({
                weighting: _mineInfo.weighting,
                goldRate: goldRate * _mineInfo.weighting / _totalWeightings,
                toClaim: _mineCalculation(_mineInfo)
            });
        }
    }

    function update() public {
        uint timePassed = block.timestamp - _lastGoldTime;
        uint gold = timePassed * goldRate;
        _goldPerWeighting += gold / _totalWeightings;
        _lastGoldTime = block.timestamp;
    }

    function claim(uint[] calldata islandIds) external onlyRole(DEFAULT_ADMIN_ROLE) returns(uint[] memory toClaims) {
        update();
        for(uint i = 0; i < islandIds.length; i++) {
            MineInfo storage _mineInfo = _mineInfos[islandIds[i]];
            uint toClaim = toClaims[i] = _mineCalculation(_mineInfo);
            _mineInfo.debt += toClaim;
        }
    }

    function setGoldRate(uint newGoldRate) external onlyRole(DEFAULT_ADMIN_ROLE) {
        update();
        goldRate = newGoldRate;
    }

    function setMineWeightings(SetMineWeightingsInput[] calldata inputs) external onlyRole(DEFAULT_ADMIN_ROLE) {
        update();
        uint toAddToTotalWeightings;
        uint toSubtractFromTotalWeightings;
        for(uint i = 0; i < inputs.length; i++) {
            SetMineWeightingsInput memory input = inputs[i];
            MineInfo storage _mineInfo = _mineInfos[input.islandId];
            if(input.weighting > _mineInfo.weighting) {
                uint toAdd = input.weighting - _mineInfo.weighting;
                _mineInfo.debt += toAdd * _goldPerWeighting;
                toAddToTotalWeightings += toAdd;
            } else {
                uint toRemove = _mineInfo.weighting - input.weighting;
                _mineInfo.owed += toRemove * _goldPerWeighting;
                toSubtractFromTotalWeightings += toRemove;
            }
            _mineInfo.weighting = input.weighting;
        }
        _totalWeightings += toAddToTotalWeightings;
        _totalWeightings -= toSubtractFromTotalWeightings;
    }

    function _mineCalculation(MineInfo storage _mineInfo) private view returns(uint) {
        uint potentialClaim = _mineInfo.weighting * _goldPerWeighting;
        return potentialClaim + _mineInfo.owed - _mineInfo.debt;
    }

}