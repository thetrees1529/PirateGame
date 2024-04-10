//SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.19;

import "../AccessControlGrantDeployer.sol";

contract RepairHuts is AccessControlGrantDeployer {

    struct Info {
        uint repairTime;
        uint freeAt;
    }

    struct SetRepairTimesInput {
        uint islandId;
        uint repairTime;
    }

    struct RepairShipsInput {
        uint islandId;
        uint shipId;
    }

    mapping(uint => uint) private _shipRepairedAts;
    mapping(uint => Info) private _infos;

    function getShipRepairedAts(uint[] memory shipIds) external view returns(uint[] memory shipRepairedAts) {
        shipRepairedAts = new uint[](shipIds.length);
        for(uint i = 0; i < shipIds.length; i++) {
            shipRepairedAts[i] = _shipRepairedAts[shipIds[i]];
        }
    }

    function getInfos(uint[] memory islandIds) external view returns(Info[] memory infos) {
        infos = new Info[](islandIds.length);
        for(uint i = 0; i < islandIds.length; i++) {
            infos[i] = _infos[islandIds[i]];
        }
    }

    function setRepairTimes(SetRepairTimesInput[] calldata inputs) external onlyRole(DEFAULT_ADMIN_ROLE) {
        for(uint i = 0; i < inputs.length; i++) {
            SetRepairTimesInput calldata input = inputs[i];
            Info storage _info = _infos[input.islandId];
            _info.repairTime = input.repairTime;
        }
    }

    function repairShips(RepairShipsInput[] calldata inputs) external onlyRole(DEFAULT_ADMIN_ROLE) {
        for(uint i = 0; i < inputs.length; i++) {
            RepairShipsInput calldata input = inputs[i];
            Info storage _info = _infos[input.islandId];
            uint repairingFrom = block.timestamp > _info.freeAt ? block.timestamp : _info.freeAt;
            _info.freeAt = _shipRepairedAts[input.shipId] = repairingFrom + _info.repairTime;
        }
    }


}