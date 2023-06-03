function main()

    %% UI FLOW

    %--Import--
    disp('-------------------------------------------------------------------------------------');
    disp('DETECT CYCLES OF ASSETS BETWEEN WALLETS -- VERSION 1.0');
    disp('Please Read The ReadMe.txt File Before Proceeding If You Have Any Questions Or Concerns');
    disp('NOTE: First 8 Columns of Input Data Must Be In Order | All Other Columns Are Ommitted From Export | Only Order of Columns Matter Names Are Renamed Upon Import.');
    disp('["blockTimestamp", "project", "nftTicker", "assetId", "from", "to","row_Id", "transaction_hash"]');
    disp('-------------------------------------------------------------------------------------');
    
    disp('Please Select The Transaction Table A: ');
    
    [file,path] = uigetfile('*.csv');
    fullPathA = fullfile(path,file);
    
    if isequal(file,0)
        disp('User selected Cancel. Please Exit and Restart The Program.');
        return;
    else
        disp(['User selected ', fullPathA]);
    end
    
    determineSubset = input('Do You Want To Determine If Any Row In Table A Is Within A Table B?: (true | false): ');
    
    if determineSubset == true
        
        disp('Please Select The Transaction Table B: ');

        [file,path] = uigetfile('*.csv');
        fullPathB = fullfile(path,file);

        if isequal(file,0)
            disp('User selected Cancel. Please Exit and Restart The Program.');
            return;
        else
            disp(['User selected ', fullPathB]);
        end
    
    end
    
    disp('-------------------------------------------------------------------------------------');
    %--Parameters--
    
    restrictCycles = input('Do You Want To Restrict The Total Number Of Cycles Found? (0 = Do Not Restrict | 1-999.. ): ');
    
    restrictCycleLength = input('Do You Want To Restrict The Length of Each Cycle Found? (0 = Do Not Restrict | 1-999..): ');
      
    xHours = input('Enter X Hours A Cycle Must Occur Within (Int 1-999..) : ');
       
    %% Import and Remove Data Missing Variables
    
    tic;
    ImportTableA;
    toc;
    tic;
    disp('Table A: Removing Data Missing Variables "Project" or "NFT Ticker" and Sorting');
    transactionTable = rmmissing(transactionTable,'DataVariables',{'project','nftTicker'});
    transactionTable = sortrows(transactionTable,'blockTimestamp');
    toc;
    
    if determineSubset == true
        tic;
        ImportTableB;
        toc;
        tic;
        disp('Table B: Removing Data Missing Variables "Project" or "NFT Ticker" ');
        transactionTableB = rmmissing(transactionTableB,'DataVariables',{'project','nftTicker'}); 
        transactionTableB = sortrows(transactionTableB,'blockTimestamp');
        toc;
    end
    
     %% Add Asset Column = project + nftTicker + assetID)
     
    tic;
    disp('Creating "asset" Column For Calculations (project + nftTicker + assetID)');
    transactionTable.asset = strcat(transactionTable.project,',',transactionTable.nftTicker,',',transactionTable.assetId); %create universal 'unique asset
    
    if determineSubset == true
        disp('Creating "uniqueRow" Column For Calculations (asset + transaction_hash)');
        transactionTable.uniqueRow = strcat(transactionTable.asset,',',transactionTable.transaction_hash); %create universal 'unique row'
        transactionTableB.uniqueRow = strcat(transactionTableB.project,',',transactionTableB.nftTicker,',',transactionTableB.assetId,',',transactionTableB.transaction_hash);
    end
    toc;
   
    
    %% Determine Subset
    if determineSubset == true
       tic;
       disp('Determining Elements of Table A that also belong to Table B ');
       disp('Paste link into browser to see sample calculation: https://gyazo.com/47f5406b105428daf1c32cbf41bc419d ');
       disp('Adding Column "isSubset" Column to Data ');
       transactionTable.isSubset = transpose(1:size(transactionTable,1));
       disp('Calculating Subset.. ');
       %Determine which elements of A are also in B.
       transactionTable.isSubset = ismember(transactionTable.uniqueRow,transactionTableB.uniqueRow);
       disp('Subset Calculation Completed ');
       disp('Clearing Table B From Memory ');
       clear transactionTableB;
       disp('Table B Removed');
       toc;
    end
    
    
    %% Add Row Number, buyer/seller Column = buyer/seller + asset
    tic;
    disp('Creating "rowNumber" and "to/from + asset" Columns For Calculations');
    transactionTable.toAndAsset = strcat(string(transactionTable.to),",",string(transactionTable.asset)); 
    transactionTable.fromAndAsset = strcat(string(transactionTable.from),",",string(transactionTable.asset));
    transactionTable.rowNumber = transpose(1:size(transactionTable,1));
    toc;
    
    %% Filter Unique Transactions
    tic;
    %  A unique transaction is defined as an asset that has only 1 transaction row
    disp('Filtering Unique Transactions (Assets That Have Only Sold Once):');
    % Find index of assets with one transaction ('unique assets')
    [~,idxu,idxc] = unique(transactionTable.asset);
    % Count unique assets by creating a histogram count using index's as bins
    [count, ~, idxcount] = histcounts(idxc,numel(idxu));
    % Keep logical index where is greater than one occurence
    idxkeep = count(idxcount)>1;
    % Extract non unique transactionTable from original transactionTable
    nonUniqueTransactionTable = transactionTable(idxkeep,:);
    toc;

    %% Create Directed Graph For All nonUniquetransactionTable: Seller -> Buyer | Edges = Row Number In Transaction Table (transactionTable)
    tic;
    disp('Creating Directed Graph For Calculations: Seller -> Buyer | Edges = rowNumber: ');
    buyer = transpose(nonUniqueTransactionTable.toAndAsset);
    seller = transpose(nonUniqueTransactionTable.fromAndAsset);   
    G = digraph(seller,buyer,transpose(nonUniqueTransactionTable.rowNumber));
    clear nonUniqueTransactionTable;
    toc;

    %% Find Cycles That Exist In Data
    tic;
    disp('Finding Cycles That Exist In Data:');
    bins = conncomp(G, "OutputForm", "cell");
    %result bins is a cell array where each element contains a set of nodes that have one or more cycles between them. 
    %not the same as allcycles in that one of these sets of nodes could contain several intersecting cycles.
    bins(cellfun(@isscalar, bins)) = [];
    nodeCycles = transpose(bins);
    toc;

    %% Create list of all nodes belonging to Cycles
    tic;
    disp('Creating List Of All Nodes Belonging To Cycles:'); 
    nodeIDs = transpose(cat(2, nodeCycles{:}));
    toc;

    %% Create Subgraph of ONLY nodes belonging to Cycles
    tic;
    disp('Creating Subgraph Of Nodes Only Belonging To Cycles:');
    cycleGraph = subgraph(G,nodeIDs);
    toc;
    tic;
    disp('Clearing Original Graph From RAM:');
    clear G;
    toc;

    %% Find Cycles & Return which Occur Within X Hours--
    disp(['Finding Cycles for Subgraph with: ', num2str(size(nodeIDs,1)), ' Nodes and ', num2str(size(cycleGraph.Edges,1)), ' Edges:']);
    disp('NOTE: If Nodes and Edges are too high here than allCycles may not run even if maxNumCycles is set. As an estimation: 1.5M nodes can take about 800 seconds');
    [newtransactionTable] = cycleTransactionTableXHours(xHours, cycleGraph, restrictCycles, transactionTable, restrictCycleLength);
    %figure out how to check if a cycleindex is an empty cell array
    %condition
    csxh = newtransactionTable(cellfun('isempty', newtransactionTable.cycleIndex) == 0,:);
    disp('Clearing Variables from RAM');
    tic;
    clear transactionTable;
    clear newtransactionTable;
    toc;
    
    %% Export Values Found
    disp('Printing Transactions With Cycles:  ');
    disp('NOTE: If Running Multiple Times, Make Sure To Rename/Move cycleTransactions As Overwritting Can Sometimes Export Corrupted/Innacurate Data');
    %remove variables used in program
    TNew= removevars(csxh,{'asset'});
    TNew= removevars(TNew,{'toAndAsset'});
    TNew= removevars(TNew,{'fromAndAsset'});
    TNew= removevars(TNew,{'rowNumber'});
    if determineSubset == true
        TNew= removevars(TNew,{'uniqueRow'});
    end
    writetable(TNew,'cycleTransactions.csv','Delimiter',',','QuoteStrings',true)
    disp('Printed. Name of File : cycleTransactions.csv');  
    disp('Closing Data & Exiting.');
    return;

end

