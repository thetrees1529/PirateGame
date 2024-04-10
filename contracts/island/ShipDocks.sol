//SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.19;
import "../AccessControlGrantDeployer.sol";

contract ShipDocks is AccessControlGrantDeployer {

    struct SetShipDockCapacitiesInput {
        uint shipDockId;
        uint capacity;
    }

    mapping(uint => uint) private _shipDockCapacities;

    function setShipDockCapacities(SetShipDockCapacitiesInput[] calldata inputs) external onlyRole(DEFAULT_ADMIN_ROLE) {
        for(uint i = 0; i < inputs.length; i++) {
            SetShipDockCapacitiesInput calldata input = inputs[i];
            _shipDockCapacities[input.shipDockId] = input.capacity;
        }
    }

    function getShipDockCapacities(uint[] calldata shipDockIds) external view returns(uint[] memory capacities) {
        capacities = new uint[](shipDockIds.length);
        for(uint i = 0; i < shipDockIds.length; i++) {
            capacities[i] = _shipDockCapacities[shipDockIds[i]];
        }
    }
    
}
