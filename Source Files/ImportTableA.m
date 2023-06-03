disp('Importing Table A..');
%% Detect File Settings
opts = detectImportOptions(fullPathA);
% Collect first 7 Columns
varNames = string(opts.VariableNames(1:8));
% Specify range and delimiter
opts.DataLines = [2, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.SelectedVariableNames = varNames;

opts.VariableTypes = ["datetime" repmat("string", 1, size(opts.VariableTypes,2)-1) ];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, varNames(1), "InputFormat", "yyyy-MM-dd'T'HH:mm:ss.000'Z'");

%Import Data
transactionTable = readtable(fullPathA, opts);

transactionTable = renamevars(transactionTable,varNames,["blockTimestamp", "project", "nftTicker", "assetId", "from", "to","row_id","transaction_hash"]);

disp('Table A: Imported');

clear opts;