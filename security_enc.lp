% Allow only one selected logging feature per asset
1 { selected_logging(A, L) : logging_feature(L) } 1 :- asset(_, A).

% Allow only one selected security feature per asset
1 { selected_security(A, F) : security_feature(F) } 1 :- asset(_, A).



% ====================================================================================================
% Calculate the total security feature power

% Calculate security power usage for each asset
security_power_used(A, Power) :- selected_security(A, mac), power_cost(mac_byAsset, Power).
security_power_used(A, Power) :- selected_security(A, dynamic_mac), power_cost(dynamic_mac_byAsset, Power).
security_power_used(A, Power) :- selected_security(A, zero_trust), power_cost(zero_trust_byAsset, Power).

% Sum up security power used by all assets (without base)
total_security_power(TotalSecurityPower) :- TotalSecurityPower = #sum { Power, A : security_power_used(A, Power) }.

% Calculate if base power is needed for dynamic_mac
base_security_dynamic_mac(Count) :- Count = #count { A : selected_security(A, dynamic_mac) }, Count > 0.

% Calculate if base power is needed for zero_trust
base_security_zero_trust(Count) :- Count = #count { A : selected_security(A, zero_trust) }, Count > 0.

% Base power for dynamic_mac if any asset uses dynamic_mac
base_security_total_dynamic_mac(Power) :- base_security_dynamic_mac(Count), Count > 0, power_cost(dynamic_mac_base, Power).

% Base power for zero_trust if any asset uses zero_trust
base_security_total_zero_trust(Power) :- base_security_zero_trust(Count), Count > 0, power_cost(zero_trust_base, Power).

% Calculate total base power for security
total_security_base_power(BaseSecurityPower) :- 
    BaseSecurityPower = #sum { Power : base_security_total_dynamic_mac(Power); Power : base_security_total_zero_trust(Power) }.

% Calculate total security power used (features + base)
total_security_power_used(TotalSecurityPowerUsed) :- 
    total_security_power(TotalSecurityPower), 
    total_security_base_power(BaseSecurityPower), 
    TotalSecurityPowerUsed = TotalSecurityPower + BaseSecurityPower.

% ====================================================================================================
% Calculate logging power usage for each asset
logging_power_used(A, Power) :- selected_logging(A, no_logging), power_cost(no_logging, Power).
logging_power_used(A, Power) :- selected_logging(A, some_logging), power_cost(some_logging_byAsset, Power).
logging_power_used(A, Power) :- selected_logging(A, zero_trust_logger), power_cost(zero_trust_logger_byAsset, Power).

% Sum up logging power used by all assets (without base)
total_logging_power(TotalLoggingPower) :- TotalLoggingPower = #sum { Power, A : logging_power_used(A, Power) }.

% Calculate if base power is needed for some_logging
base_logging_some_logging(Count) :- Count = #count { A : selected_logging(A, some_logging) }, Count > 0.

% Calculate if base power is needed for zero_trust_logger
base_logging_zero_trust_logger(Count) :- Count = #count { A : selected_logging(A, zero_trust_logger) }, Count > 0.

% Base power for some_logging if any asset uses some_logging
base_logging_total_some_logging(Power) :- base_logging_some_logging(Count), Count > 0, power_cost(some_logging_base, Power).

% Base power for zero_trust_logger if any asset uses zero_trust_logger
base_logging_total_zero_trust_logger(Power) :- base_logging_zero_trust_logger(Count), Count > 0, power_cost(zero_trust_logger_base, Power).

% Calculate total base power for logging
total_logging_base_power(BaseLoggingPower) :- 
    BaseLoggingPower = #sum { Power : base_logging_total_some_logging(Power); Power : base_logging_total_zero_trust_logger(Power) }.

% Calculate total logging power used (features + base)
total_logging_power_used(TotalLoggingPowerUsed) :- 
    total_logging_power(TotalLoggingPower), 
    total_logging_base_power(BaseLoggingPower), 
    TotalLoggingPowerUsed = TotalLoggingPower + BaseLoggingPower.

% ====================================================================================================
% Calculate the combined power utilization

% Combine both total powers from security and logging into total power used
total_power_used(TotalPowerUsed) :-
    total_security_power_used(TotalSecurityPowerUsed),
    total_logging_power_used(TotalLoggingPowerUsed),
    TotalPowerUsed = TotalSecurityPowerUsed + TotalLoggingPowerUsed.

% Ensure that the total power used does not exceed the system's maximum allowable power
:- total_power_used(TotalPowerUsed), system_capability(max_power, MaxPower), TotalPowerUsed > MaxPower.

% ====================================================================================================
% Calculate the risk for each asset


% Calculate risk for each asset and make it a fact
register_risk(Register, Risk) :-
    asset(_, Register),
    impact(Register, Impact),
    selected_security(Register, Security),
    selected_logging(Register, LogFeature),
    vulnerability(Security, Vulnerability),
    logging(LogFeature, LogFactor),
    Risk = Impact * Vulnerability * LogFactor.

register_risk_fact(Register, Risk) :- register_risk(Register, Risk).



% Ensure that the risk for each asset does not exceed the maximum allowable risk
:- register_risk_fact(A, Risk), system_capability(max_asset_risk, MaxRisk), Risk > MaxRisk.

% Calculate LUT utilization for each asset
luts_used(A, Lut) :- selected_security(A, mac), luts(mac, Lut).
luts_used(A, Lut) :- selected_security(A, dynamic_mac), luts(dynamic_mac, Lut).
luts_used(A, Lut) :- selected_security(A, zero_trust), luts(zero_trust, Lut).

% Sum up LUTs used by all assets
total_luts(TotalLUTs) :- TotalLUTs = #sum { Lut, A : luts_used(A, Lut) }.

% Calculate if base LUTs are needed for dynamic_mac
base_lut_dynamic_mac(Count) :- Count = #count { A : selected_security(A, dynamic_mac) }, Count > 0.

% Calculate if base LUTs are needed for zero_trust
base_lut_zero_trust(Count) :- Count = #count { A : selected_security(A, zero_trust) }, Count > 0.

% Base LUTs for dynamic_mac
base_lut_total_dynamic_mac(Lut) :- base_lut_dynamic_mac(Count), Count > 0, luts(dynamic_mac_base, Lut).

% Base LUTs for zero_trust
base_lut_total_zero_trust(Lut) :- base_lut_zero_trust(Count), Count > 0, luts(zero_trust_base, Lut).

% Calculate total base LUTs
total_base_luts(BaseLUTs) :- 
    BaseLUTs = #sum { Lut : base_lut_total_dynamic_mac(Lut); Lut : base_lut_total_zero_trust(Lut) }.

% Combine total LUTs from features and base LUTs
total_luts_used(TotalUsedLUTs) :- 
    total_luts(TotalLUTs), 
    total_base_luts(BaseLUTs), 
    TotalUsedLUTs = TotalLUTs + BaseLUTs.


% Ensure that the total number of LUTs used does not exceed the system's maximum allowable LUTs
:- total_luts_used(TotalLUTs), system_capability(max_luts, MaxLUTs), TotalLUTs > MaxLUTs.

% Calculate FFs utilization for each asset
ffs_used(A, FF) :- selected_security(A, mac), ffs(mac, FF).
ffs_used(A, FF) :- selected_security(A, dynamic_mac), ffs(dynamic_mac, FF).
ffs_used(A, FF) :- selected_security(A, zero_trust), ffs(zero_trust, FF).

% Calculate the base FFs needed for dynamic_mac and zero_trust only if they are selected
base_ff_dynamic_mac(Count) :- Count = #count { A : selected_security(A, dynamic_mac) }, Count > 0.
base_ff_zero_trust(Count) :- Count = #count { A : selected_security(A, zero_trust) }, Count > 0.

% Base FFs for dynamic_mac or zero_trust
base_ff_total_dynamic_mac(FF) :- base_ff_dynamic_mac(Count), Count > 0, ffs(dynamic_mac_base, FF).
base_ff_total_zero_trust(FF) :- base_ff_zero_trust(Count), Count > 0, ffs(zero_trust_base, FF).

% Aggregate FFs used in the entire system
total_ffs(TotalFFs) :- 
    TotalFFs = #sum { FF, A : ffs_used(A, FF) }.

total_base_ffs(BaseFFs) :-
    BaseFFs = #sum { FF : base_ff_total_dynamic_mac(FF); FF : base_ff_total_zero_trust(FF) }.

% Combine total FFs from features and base FFs
total_ffs_used(TotalUsedFFs) :- 
    total_ffs(TotalFFs), 
    total_base_ffs(BaseFFs), 
    TotalUsedFFs = TotalFFs + BaseFFs.


% Ensure that the total number of FFs used does not exceed the system's maximum allowable FFs
:- total_ffs_used(TotalUsedFFs), system_capability(max_ffs, MaxFFs), TotalUsedFFs > MaxFFs.


% Minimization: minimize the total risk over all assets
#minimize { Risk, A : register_risk_fact(A, Risk) }.

#show selected_logging/2.
#show selected_security/2.
#show total_security_power_used/1. % Debugging
#show total_logging_power_used/1. % Debugging
#show total_power_used/1.
#show register_risk_fact/2.
#show total_luts_used/1.
#show total_ffs_used/1.

% Show all component and asset definitions 
%#show component/1.
%#show asset/2.

% Show all impacts, vulnerabilities, and logging factors
%#show impact/2.
%#show vulnerability/2.
%#show logging/2.