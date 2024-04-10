//SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.19;
import "../AccessControlGrantDeployer.sol";

contract ExportHuts is AccessControlGrantDeployer {

    struct Info {
        uint exportRate;
        uint lastExportTime;
        uint amountExporting;
    }

    struct SetExportRatesInput {
        uint islandId;
        uint exportRate;
    }

    struct SetAmountExportingsInput {
        uint islandId;
        uint amountExporting;
    }

    struct GetInfosOutput {
        uint exportRate;
        uint pendingExport;
        uint leftToExport;
    }

    mapping(uint => Info) private _infos;

    function setExportRates(SetExportRatesInput[] calldata inputs) external onlyRole(DEFAULT_ADMIN_ROLE) returns(uint[] memory toExports) {
        toExports = new uint[](inputs.length);
        for(uint i = 0; i < inputs.length; i++) {
            SetExportRatesInput memory input = inputs[i];
            Info storage _info = _infos[input.islandId];
            toExports[i] = _update(_info);
            _info.exportRate = input.exportRate;
        }
    }

    function setAmountExportings(SetAmountExportingsInput[] calldata inputs) external onlyRole(DEFAULT_ADMIN_ROLE) returns(uint[] memory toExports) {
        toExports = new uint[](inputs.length);
        for(uint i = 0; i < inputs.length; i++) {
            SetAmountExportingsInput memory input = inputs[i];
            Info storage _info = _infos[input.islandId];
            toExports[i] = _update(_info);
            _info.amountExporting = input.amountExporting;
        }
    }

    function update(uint[] calldata islandIds) external onlyRole(DEFAULT_ADMIN_ROLE) returns(uint[] memory toExports) {
        toExports = new uint[](islandIds.length);
        for(uint i = 0; i < islandIds.length; i++) {
            Info storage _info = _infos[islandIds[i]];
            toExports[i] = _update(_info);
        }
    }

    function getInfos(uint[] calldata islandIds) external view returns(GetInfosOutput[] memory outputs) {
        outputs = new GetInfosOutput[](islandIds.length);
        for(uint i = 0; i < islandIds.length; i++) {
            uint islandId = islandIds[i];
            Info storage _info = _infos[islandId];
            (uint toExport, uint newAmountExporting) = _updateCalculation(_info);
            outputs[i] = GetInfosOutput({
                exportRate: _info.exportRate,
                pendingExport: toExport,
                leftToExport: newAmountExporting
            });
        }
    }

    function _updateCalculation(Info storage _info) private view returns(uint toExport, uint newAmountExporting) {
        uint timePassed = block.timestamp - _info.lastExportTime;
        uint potentiallyToExport = _info.exportRate * timePassed;
        toExport = potentiallyToExport > _info.amountExporting ? _info.amountExporting : potentiallyToExport;
        newAmountExporting = _info.amountExporting - toExport;
    }

    function _update(Info storage _info) private returns(uint toExport) {
        uint newAmountExporting;
        (toExport, newAmountExporting) = _updateCalculation(_info);
        _info.lastExportTime = block.timestamp;
        _info.amountExporting = newAmountExporting;
    }
    
}