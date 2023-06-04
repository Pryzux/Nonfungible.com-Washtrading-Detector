# Nonfungible.com-NBA-Top-Shot-Price-Evaluation
Experimental research using graph theory to detect illegal washtrading of NFT's assets.

**Table of Contents**

-  [Purpose](#purpose)
-  [Description](#description)
-  [Debug Help](#debug-help)
-  [Input Data](#input-data)
-  [Tech Stack](#tech-stack)

## Purpose

This program was created for Nonfungible.com to provide insight using graph theory to identify wastrading of NFT assets. 

## Description

The program finds all the instances where an asset would be traded from one wallet to another/multiple wallet(s) and then transferred back to the original wallet. The final result is a .csv containing a 
list of all transactions that have been linked together in the cycling of an asset. AKA a history of sales that the asset went through until it eventually was resold/transferred back to the original wallet. This is done through treating wallets as nodes and a transfer or sale as directed edges, indicating a sale or transfer has been made from wallet one -> wallet 2 when two nodes are connected by a directed edge.

There are three primary parameters one can choose from within the program to help with analysis:

  _ **restrictCycles** _= input('Do You Want To Restrict The Total Number Of Cycles Found? (0 = Do Not Restrict || 1-999.. ): ');
   
   Restrict Cycles can be helpful due to two primary reasons: 1) the nature of NFT Project you are working with 2) the size of the data sets being worked on. The function Allcycle from Matlab is used to    \
   compute all the cycles within the data, however some complications can arise depending on the data you are inputting. Some Complications && Debug Help (#5 "Too Many Cycles in Data") for more information if    you think you are experiencing issues with this function.

   _**restrictCycleLength**_ = input('Do You Want To Restrict The Length of Each Cycle Found? (0 = Do Not Restrict || 1-999..): ');
   
   Sometimes you may want to restrict how many wallets an asset has been transferred through until coming back to the original wallet. For example, typing "2" would only show all wallets that have been   
   transferred like so "wallet 1 -> wallet 2 -> wallet 1". where as typing "3" would show all cycles "wallet 1 -> wallet 2 -> wallet 3 -> wallet 1".
      
   _**xHours**_ = input('Enter X Hours A Cycle Must Occur Within (0 = Do not Restrict || Int 1-999..) : ');
   
   Used for identifying cycles within a specifec time range. For example, if you want to see all assets that were transferred out and back to an original wallet within 24 hours, type "24".
   
## Debug Help**
   
   1) **Cycle Graph Too Large **
      Sometimes when the data is very large or there are a a lot of unique cycles in the data, the number of "nodes" and "edges" will be very large (>1 Million Nodes & Edges).
      if this is the case then the runtime of the program may exponentially increase, and in some cases where the cyclegraph is too big, it may not run at all. To get an indication 
      of if this may be the problem, there will be a print statement in the program that says how many nodes and edges are within the subgraph, check this number to ensure it is not the issue.
   
   2) **Too many cycle index columns in return data**
      if you find the data returned contains an overwhelming amount of cycle index columns, then that means there are a lot of overapping cycles for some transactions. This could indicate
      many things, but probably has to do with the nature of the NFT you are observing as it may contain many repettitive cycles that aren't neccesarily a "sale transaction" but rather a system. 
      gods unchained has this type of issue if you want to run an example and see.
      
   3) **0x0000000000000000000000000000000000000000 Wallets**
      (ie. wrapping, a bug, etc) Wallets like this in the 'to' or 'from' of a transaction/sale may create innacurate or unwanted cycles. They may also increase the wait time for some portions
      of the program. Please ensure these transactions containing these wallets are removed from the data beforehand.
      
   4) **Too many cycle index columns in return data**
      if you find the data returned contains an overwhelming amount of cycle index columns, then that means there are a lot of overapping cycles for some transactions. This could indicate
      many things, but probably has to do with the nature of the NFT you are observing as it may contain many repettitive cycles that aren't neccesarily a "sale transaction" but rather a system. 
      gods unchained has this type of issue if you want to run an example and see.
   
   5) **Too Many Cycles in Data**
      some NFT projects are structured in a way such that many cycles may occur between some assets and wallets due to the nature of the project. 
      For example, I found a project where there were only 5 unique asset IDs and they were constantly being shared between around 50 wallets. This created a 10^17 (10000000 0000000000) cycles in the project. 
      If the number of cycles found in your data is too large, no amount of RAM or time will be enough
      and the program may crash or never finish. When you think you might be dealing with a project like this or you are not sure, use the 
      Restrict Cycles input options given to set the max amount of cycles (in both length and amount) it will return. This can be used to help debug and find where the 
      source of the large amount of cycles is coming from in the data. 

## Input Data

The program will prompt user to input a Table A, and Table B if user requests subset functionality, which is of the format:

Tables must be nx8 ".csv" extension containing columns where order of columns matters : ["blockTimestamp", "project", "nftTicker", "assetId", "from", "to", "row_Id" "transaction_hash"] where,
	
  to               : wallet address
  from             : wallet address
  project          : Project Name
  nftTicker        : NFT Ticker
  assetId          : Asset Identifier
  row_id           : transaction identifier
  blockTimestamp   : "yyyy-MM-dd'T'HH:mm:ss.000'Z'"
  transaction_hash : address in wallet form

## Tech Stack

This program uses MATLAB (https://www.mathworks.com/products/matlab.html), which is a proprietary multi-paradigm programming language and numeric computing environment developed by MathWorks. MATLAB allows matrix manipulations, plotting of functions and data, implementation of algorithms, creation of user interfaces, and interfacing with programs written in other languages.
