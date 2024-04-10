//SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.19;
import "../AccessControlGrantDeployer.sol";

contract GoldStorages is AccessControlGrantDeployer {

    struct Info {
        uint maxCapacity;
        uint stored;
    }

    struct SetMaxCapacitiesInput {
        uint islandId;
        uint maxCapacity;
    }

    struct AddToStoredInput {
        uint islandId;
        uint amount;
    }

    struct RemoveFromStoredInput {
        uint islandId;
        uint amount;
    }

    mapping(uint => Info) private _infos;

    function getInfos(uint[] calldata islandIds) external view returns(Info[] memory infos) {
        infos = new Info[](islandIds.length);
        for(uint i = 0; i < islandIds.length; i++) {
            infos[i] = _infos[islandIds[i]];
        }
    }

    function setMaxCapacities(SetMaxCapacitiesInput[] calldata inputs) external onlyRole(DEFAULT_ADMIN_ROLE) {
        for(uint i = 0; i < inputs.length; i++) {
            Input memory input = inputs[i];
            Info storage _info = _infos[input.islandId];
            _info.maxCapacity = input.maxCapacity;
        }
    }

    function addToStored(AddToStoredInput[] calldata inputs) external onlyRole(DEFAULT_ADMIN_ROLE) returns(uint[] memory excesses) {
        excesses = new uint[](inputs.length);
        for(uint i = 0; i < inputs.length; i++) {
            Input memory input = inputs[i];
            Info storage _info = _infos[input.islandId];
            uint canBeStored = _info.maxCapacity - _info.stored;
            uint toBeStored = input.amount > canBeStored ? canBeStored : input.amount;
            _info.stored += toBeStored;
            excesses[i] = input.amount - toBeStored;
        }
    }

    function removeFromStored(RemoveFromStoredInput[] calldata inputs) external onlyRole(DEFAULT_ADMIN_ROLE) {
        for(uint i = 0; i < inputs.length; i++) {
            Input memory input = inputs[i];
            Info storage _info = _infos[input.islandId];
            _info.stored -= input.amount;
        }
    }

}