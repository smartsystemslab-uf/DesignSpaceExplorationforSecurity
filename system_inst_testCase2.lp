% Target System Defined Constraints (PYNQ-Z2)
system_capability(max_power, 15000).          % ASP/Potassco cannot handle decimal points. 15Watts (5V*3A) * 100. All power outputs should be d
system_capability(max_luts, 20000).           % Maximum number of LUTs allowed
system_capability(max_ffs, 16000).

% User Defined Objectives
system_capability(max_asset_risk, 20).







