create database project;
use project;

select * from categories;
select * from customers;
select * from employees;
select * from order_details;
select * from orders;
select * from products;
select * from shippers;
select * from suppliers;

-- Average orders per customer
Select AVG(Order_Count) as Avg_Orders_Per_Customer
From (
    Select CustomerID, COUNT(OrderID) as Order_Count
    From orders
    Group By CustomerID
) as customer_orders;

-- Are there hight-value repeat customers? threshold>10000 repetitive>3
Select CustomerID,COUNT(o.OrderID) Order_Count, ROUND(SUM(Total_Price),2) Amount_Spent, ROUND(AVG(Total_Price),2) Average_Order_Value
From orders o 
   Join order_details od 
        on o.OrderID=od.OrderID
Group By CustomerID
Having COUNT(o.OrderID)>3
and SUM(Total_Price)>10000;

-- How do customers order pattern vary by city/country
select o.ShipCountry, o.ShipCity, count(distinct o.OrderID) Order_Count, 
round(sum(od.UnitPrice*od.Quantity*(1-od.Discount)),2) Total_Revenue, 
round(sum(od.UnitPrice*od.Quantity*(1-od.Discount))/count(distinct o.OrderID),2) as Avg_Order_Value
from orders o 
join order_details od 
on o.OrderID=od.OrderID
group by o.ShipCountry,o.ShipCity
order by Total_Revenue desc
limit 10;

-- for each customer calculate their preferred category
select CustomerID,Total_Spend,Order_Count,CategoryName
 from (
select distinct(o.CustomerID),count(od.OrderID) Order_Count,c.CategoryName,sum(Total_Price) Total_Spend,
row_number() over(partition by o.CustomerID order by count(od.OrderID) desc) as row_num
from orders o join order_details od on o.OrderID=od.OrderID
join products p on p.ProductID=od.ProductID
join Categories c on c.CategoryID=p.CategoryID
group by o.CustomerID,c.CategoryName)t
where row_num=1;

-- which product category contribute the most to order revenue
Select c.CategoryName,p.ProductName,Round(SUM(Total_Price),2) as Revenue
from order_details od
join products p on
od.ProductID = p.ProductID
join Categories c 
on p.CategoryID = c.CategoryID
Group By c.CategoryName, p.ProductName
Order By Revenue desc
limit 10;

-- Frequency of Orders by Customer Segment
Select c.CustomerID,Count(o.OrderID) as OrderFrequency,
    Round(Sum(Total_Price),2) as TotalSpend
from customers c
join orders o on c.CustomerID = o.CustomerID
join order_details od on o.OrderID = od.OrderID
Group By c.CustomerID, c.CompanyName
Order By OrderFrequency desc;

-- Geographic and Title wise Distribution of Employees
Select City,Title,Count(EmployeeID) as EmployeeCount
From employees
Group By City, Title
Order By EmployeeCount desc;

-- Trends in hire date across EmployeesTitles
Select Title, Year(HireDate) as HireYear,
    Count(EmployeeID) as EmployeesHired
from employees
Group By Title, Year(HireDate)
Order By HireYear, EmployeesHired desc;

-- Patterns in Employee Title and Courtesy Title
Select TitleOfCourtesy, Title,
    Count(EmployeeID) as Count
from employees
Group By TitleOfCourtesy, Title
Order By Count desc;

-- Correlation Between Product Pricing, Stock Levels, and Sales
Select p.ProductName,p.UnitPrice,p.UnitsInStock,Sum(od.Quantity) as UnitsSold
from products p
join order_details od 
on p.ProductID = od.ProductID
Group By p.ProductName, p.UnitPrice, p.UnitsInStock
Order By UnitsSold desc;

-- Seasonal Demand Trends for Products
Select Month(o.OrderDate) as Month, p.Product_Name,Sum(od.Quantity) as Units_Sold
from Orders o
join order_details od on o.OrderID = od.OrderID
join products p on od.ProductID = p.ProductID
Group By Month(o.OrderDate), p.Product_Name
Order By Month, Units_Sold desc;

-- Anomalies in Product Sales/revenue
Select p.ProductID, p.ProductName, Sum(Total_Price) as TotalSales,
    Avg(Sum(Total_Price)) over() as AvgSales,
    STDDEV(Sum(Total_Price)) over() as StdDevSales
from order_details od
join products p on od.ProductID = p.ProductID
Group By p.ProductID, p.ProductName
Order By TotalSales desc;

-- Regional Trends in Supplier Distribution and Pricing
Select s.Country, Count(distinct s.SupplierID) as TotalSuppliers, Avg(p.UnitPrice) as AvgSales
from suppliers s
join products p on s.SupplierID = p.SupplierID
Group By s.Country
Order By TotalSuppliers desc;

-- Suppliers Distribution across Product Categories
Select c.CategoryName, Count(distinct p.SupplierID) as TotalSuppliers
from products p
join categories c on p.CategoryID = c.CategoryID
Group By c.CategoryName
Order By TotalSuppliers desc;

-- Supplier Pricing and Categories across Regions
Select s.Country, c.CategoryName,round(Avg(p.UnitPrice),2) as AvgUnitPrice
from suppliers s
join products p on s.SupplierID = p.SupplierID
join categories c on p.CategoryID = c.CategoryID
Group By s.Country, c.CategoryName
Order By AvgUnitPrice desc;

-- Correlation Between Orders and Customer Location or Product Category
Select c.Country, ca.CategoryName, Count(o.OrderID) as Total_Orders,
Sum(Total_price) as Revenue
from orders o
join customers c on o.CustomerID = c.CustomerID
join order_details od on o.OrderID = od.OrderID
join products p on od.ProductID = p.ProductID
join categories ca on p.CategoryID = ca.CategoryID
Group By c.Country, ca.CategoryName
Order By Revenue desc;

-- Frequency of Orders on Monthly basis by Customers
Select c.CustomerID,Year(o.OrderDate) as OrderYear,Month(o.OrderDate) as OrderMonth,
    Count(o.OrderID) as MonthlyOrderCount,
    Round(Sum(Total_Price),2) as MonthlySpend
from customers c
join orders o on c.CustomerID = o.CustomerID
join order_details od on o.OrderID = od.OrderID
Group By c.CustomerID,Year(o.OrderDate),Month(o.OrderDate)
Order By c.CustomerID,OrderYear,OrderMonth;

-- Frequency of Orders on Yearly basis by Customers
Select c.CustomerID,Year(o.OrderDate) as OrderYear,
    Count(o.OrderID) as YearlyOrderCount,
    Round(Sum(Total_Price),2) as YearlySpend
from customers c
join orders o on c.CustomerID = o.CustomerID
join order_details od on o.OrderID = od.OrderID
Group By c.CustomerID,Year(o.OrderDate)
Order By c.CustomerID,OrderYear;





