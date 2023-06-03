function [newtransactionTable] = cycleTransactionTableXHours(xHours, cycleGraph, restrictCycles, transactionTable,restrictCycleLength)

%% Find Cycles & EdgeCycles of cycleGraph
%restrictCycles = do you want to restrict the maximum number of cycles returned
%restrictCycleLength =  do you want to restrict the maximum cycle length returned

tic;
if restrictCycles > 0 & restrictCycleLength == 0
    disp(['Restrictions: Restrict Total Number of Cycles = ', convertStringsToChars(string(restrictCycles))]);
    [cycles,edgecycles] = allcycles(cycleGraph,'MaxNumCycles',restrictCycles); 
    
elseif restrictCycles > 0 & restrictCycleLength > 0
    disp(['Restrictions: Restrict Total Number of Cycles = ', convertStringsToChars(string(restrictCycles)),', Restrict Length of Each Cycle = ', convertStringsToChars(string(restrictCycleLength))]);
    [cycles,edgecycles] = allcycles(cycleGraph,'MaxNumCycles',restrictCycles,'MaxCycleLength',restrictCycleLength); 
    
elseif restrictCycles == 0 & restrictCycleLength > 0
    disp(['Restrictions: Restrict Length of Each Cycle = ', convertStringsToChars(string(restrictCycles))]);
    [cycles,edgecycles] = allcycles(cycleGraph,'MaxCycleLength',restrictCycleLength); 
    
else
    disp('Restrictions: No Restrictions');
    [cycles,edgecycles] = allcycles(cycleGraph);
end
toc;

%% Determine Which Cycles Occur Within X Hours
% Output: new column cycleDetected == number of cycles the transaction belongs to

%creates new column of empty cell arrays 
transactionTable.cycleIndex = transpose(cell(1,size(transactionTable,1)));

disp(['Finding All Cycles That Occur Within: ', num2str(xHours), ' Hours']);
tic;
for x = 1:size(cycles,1)

    edges = edgecycles{x};
    
    %if cycle did not happen in time orderly fashion we ignore it
    if issorted(cycleGraph.Edges.Weight(edgecycles{x})) == 0
        continue;    
    end
    %timestamp of first transaction related to cycle
    t1 = transactionTable.blockTimestamp(cycleGraph.Edges.Weight(edges(1)));
    %timestamp of last transaction related to cycle
    t2 = transactionTable.blockTimestamp(cycleGraph.Edges.Weight(edges(size(edges,2))));
    
    %find hours between the asset leaving and returning to the same wallet
    hoursBetween = hour(between(t1,t2,'time'));
    
    if hoursBetween > 0 & hoursBetween <= xHours  
        
        %cycle x
        new = [x];
        %index of rows apart of cycle x
        idx = transpose(cycleGraph.Edges.Weight(edges));
        %for each row apart of cycle, add cycle index to column
        transactionTable.cycleIndex(idx) = cellfun(@(v)[v new],transactionTable.cycleIndex(idx),'UniformOutput',false);
        
    end
    
end

newtransactionTable = transactionTable;

toc;

end