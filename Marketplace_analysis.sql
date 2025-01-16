/* 
A manufacturing company has been experiencing a shift in the market place towards digital, 
possibly leading to decline in its store sales.

A. Shift in the market place towards digital – Is this true? Can we prove it with the data?

	A. Go to market channels – Reseller (aka Retailer, stores) & Online (Digital - Company’s online website). 

	B. We need to compare sales (revenue, profit, volume of transactions and items sold(order quantities) over time. 
	Use Month- Year (in excel formula = text(Datefield,”yyyy-mm” (2005-07)

*/
/*Creating a Temporary Views*/
WITH sales AS (
	  SELECT sod.[SalesOrderID]
		,sod.[SalesOrderDetailID]
		,sod.[OrderQty] * p.StandardCost as 'Total cost'
		,sod.[LineTotal] as Revenue
		,sod.[LineTotal] - (sod.OrderQty * p.StandardCost) as 'Profit'
		,soh.[RevisionNumber]
		,FORMAT(soh.[OrderDate], 'yyyy-MM') as OrderDate
		,format(soh.[DueDate], 'yyyy-MM') as DueDate
		,format(soh.[ShipDate], 'yyyy-MM') as ShipDa#
		,soh.[Status]
		,"OnlineOrderFlag" = case 
			when soh.[OnlineOrderFlag] = 0 then 'Reseller sales'
			when soh.OnlineOrderFlag = 1 then 'Online sales'
		end
		,p.StandardCost
	 FROM [AdventureWorks2022].[Sales].[SalesOrderDetail] as sod
	 inner join Sales.SalesOrderHeader as soh
	 on sod.SalesOrderID = soh.SalesOrderID 
	 inner join [Production].[Product] p
	 on sod.ProductID = p.ProductID
	 inner join [Production].[ProductSubcategory] ps
	 on p.ProductSubcategoryID = ps.ProductSubcategoryID
),
/* 
Let's compare the revenue of both the online and stores revenue.
Stores have more revenue than the online
*/
Revenue_By_Channels AS (
select cast(sum(Revenue) as decimal(18,2)) as Revenue, OnlineOrderFlag from sales 
group by OnlineOrderFlag
),
/* Let's calculate the profit by the channels */
Profit_By_Channels AS (
select cast(sum(Profit) as decimal(18,2)) as Profit, OnlineOrderFlag from sales 
group by OnlineOrderFlag
),
/* Let's count the volume of transactions of each channels. */
Volume_of_Transactions AS (
select COUNT(DISTINCT SalesOrderID) as Transactions, OnlineOrderFlag from sales
group by OnlineOrderFlag
)

select Revenue, Profit, Transactions, rc.OnlineOrderFlag from Revenue_By_Channels rc
inner join Profit_By_Channels pf
on rc.OnlineOrderFlag = pf.OnlineOrderFlag
inner join Volume_of_Transactions vt
on pf.OnlineOrderFlag = vt.OnlineOrderFlag


/*
Analysis of the Shift Toward Online Sales:

Using the described SQL techniques, we calculated and displayed data that supports the trend towards online sales. 
Our findings are summarized below:

1. Reseller Sales Revenue vs. Online Sales Revenue 
   - Insight: Reseller sales generate higher total revenue compared to online sales.  
   - Implication: This suggests that resellers likely deal with higher-value transactions, potentially driven by bulk purchases 
   or long-term contracts.

2. Profit Comparison: Online Sales vs. Reseller Sales  
   - Insight: Despite lower revenue, online sales yield higher profit margins compared to reseller sales.  
   - Implication: This indicates that online sales are more cost-efficient, with reduced overheads or higher markup potential.

3. Transaction Volume: Online Sales vs. Reseller Sales  
   - Insight: Online sales have a significantly higher volume of transactions compared to reseller sales.  
   - Implication: The convenience and accessibility of online platforms attract a larger number of customers,
   reflecting the growing preference for digital channels.


These findings underscore the importance of optimizing strategies for online sales while balancing the strengths of
reseller channels. Each channel has distinct advantages, and a hybrid approach could leverage the strengths of both to maximize 
growth and profitability.
*/

