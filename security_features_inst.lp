% Define basic security features
security_feature(zero_trust).  % very secure, high cost
security_feature(mac).         % low security, low cost
security_feature(dynamic_mac). % medium security, medium cost

logging_feature(zero_trust_logger ; some_logging ; no_logging).

% Define security feature properties
power_cost(zero_trust_base, 785).  % Power utilization pulled from Vivado design, <0.001W for policy enforcement point wrapper, <0.001W for policy enforcement point, 0.017W for MicroBlaze-based policy engine, and 0.766W for autoencoder
power_cost(zero_trust_byAsset, 7).         % Power utilization pulled from Vivado design, 0.007W for each IPFW
power_cost(dynamic_mac_base, 19).  % Power utilization pulled from Vivado design, <0.001W for policy enforcement point wrapper, <0.001W for policy enforcement point, 0.017W for MicroBlaze-based policy engine
power_cost(dynamic_mac_byAsset, 1).		   % Power utilization pulled from Vivado design, <0.001W for IPFW
power_cost(mac_byAsset, 1).				   % Power utilization pulled from Vivado design, <0.001W for IPFW, no base utilization because mac has no updates



% Define logging feature properties
power_cost(no_logging, 0).			     % No logging, 0 mW
power_cost(some_logging_base, 255).		 % Estimated 255 mW we have no implementation for a partial logger. Estimate one third of zero-trust power for now
power_cost(some_logging_byAsset,8).		 % Estimate based on Sujan Saha's thesis. There was no analysis of power used by policy server vs. ipfw
power_cost(zero_trust_logger_base, 768). % Estimated 768 mW from associated paper. Did not include PL logic power
power_cost(zero_trust_logger_byAsset,8). % Estimate based on Sujan Saha's thesis

vulnerability(zero_trust, 1).
vulnerability(mac, 3).
vulnerability(dynamic_mac, 2).

% Logging is between 5 (0.5) and 20 (2), scaled by 10 %POTASSCO ONLY SUPPORTS INTEGER REPRESENTATION
logging(zero_trust_logger, 5).
logging(some_logging, 10).
logging(no_logging, 20).

% Define LUT costs
luts(mac, 51).                          % Each asset with mac costs 51 LUTs
luts(dynamic_mac_base, 1568).           % Base 40 LUTs for dynamic_mac policy server and MicroBlaze
luts(dynamic_mac, 51).                  % Each asset with dynamic_mac costs 51 LUTs
luts(zero_trust_base, 32922).           % Base 31354 LUTs for zero-trust autoencoder(31354) and policy server+MicroBlaze(1568)
luts(zero_trust, 51).                   % Each asset with zero-trust costs 51 LUTs

ffs(mac, 64).                           % Each asset with mac costs 64 FFs
ffs(dynamic_mac_base, 1378).            % Base 1378 FFs for dynamic_mac policy server and MicroBlaze
ffs(dynamic_mac, 64).                   % Each asset with dynamic_mac costs 64 FFs
ffs(zero_trust_base, 26398).            % Base 25020 FFs for zero-trust autoencoder(25020) and policy server+MicroBlaze(1378)
ffs(zero_trust, 64).                    % Each asset with zero-trust costs 64 FFs



% Extra features for later

%resource_cost(zero_trust, 3).
%resource_cost(mac, 1).
%resource_cost(dynamic_mac, 2).

%security_level(zero_trust, 3).
%security_level(mac, 1).
%security_level(dynamic_mac, 2).
