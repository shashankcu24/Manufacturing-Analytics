use manu;
CREATE TABLE ManufacturingData (
    Buyer                        VARCHAR(100),
    Cust_Code                    VARCHAR(50),
    Cust_Name                    VARCHAR(150),
    Delivery_Period              VARCHAR(50),
    Department_Name              VARCHAR(100),
    Doc_Date                     DATE,
    Doc_Num                      BIGINT,
    EMP_Code                     VARCHAR(50),
    Emp_Name                     VARCHAR(150),
    Per_Day_Machine_Cost         DECIMAL(18,2),
    Press_Qty                    DECIMAL(18,2),
    Processed_Qty                DECIMAL(18,2),
    Produced_Qty                 DECIMAL(18,2),
    Rejected_Qty                 DECIMAL(18,2),
    Rejected_Rate                DECIMAL(10,2),
    Wastage_Percentage           DECIMAL(5,2),
    Total_Qty                    DECIMAL(18,2),
    Today_Manufactured_Qty       DECIMAL(18,2),
    Total_Manu_Cost              DECIMAL(18,2),
    Estimated_Days_2             INT,
    Estimated_Days               INT,
    Total_Wastage_Percentage     DECIMAL(5,2),
    Total_Value                  DECIMAL(18,2),
    Loss_Value                   DECIMAL(18,2),
    Cost_Per_Unit                DECIMAL(18,2),
    Shortfall                    DECIMAL(18,2),
    Delivery_Achievement_Percentage DECIMAL(5,2),
    Achievement_Percentage       DECIMAL(5,2),
    Total_Manu_Qty               DECIMAL(18,2),
    WO_Qty                       DECIMAL(18,2),
    Efficiency_Percentage        DECIMAL(5,2),
    Machine_Code                 VARCHAR(50),
    Operation_Name               VARCHAR(100),
    Operation_Code               VARCHAR(50),
    Item_Code                    VARCHAR(50)
);

SET sql_mode = '';
SET SQL_SAFE_UPDATES =0 ;

UPDATE manufacturingdata
SET Doc_Date = STR_TO_DATE(Doc_Date, '%y-%m-%d') ;
SHOW VARIABLES LIKE 'secure_file_priv';
LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/SQL_ DATASET2.csv"
INTO TABLE manufacturingdata
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * from manufacturingdata;

SELECT Department_Name,
       ROUND(AVG(Cost_Per_unit),2) AS AvgCostPerUnit, sum(total_value) as TotalCost,
       SUM(Loss_value) AS TotalLoss
FROM manufacturingdata
GROUP BY Department_Name;

-- STEP-1 “Department-wise Production & Rejection Rate Analysis”
SELECT 
    Department_Name,
    CONCAT(ROUND(SUM(Produced_Qty)/1000000, 2), ' M') AS TotalProduced_Million,
    CONCAT(ROUND(SUM(Rejected_Qty)/1000000, 2), ' M') AS TotalRejected_Million,
    CONCAT(
        ROUND((SUM(Rejected_Qty) * 100.0) / NULLIF(SUM(Produced_Qty), 0), 2), ' %'
    ) AS RejectionRate
FROM manufacturingdata
GROUP BY Department_Name;

-- STEP-2 "Manufacturing Efficiency and Cost-Loss Analysis" 
SELECT 
    Department_Name,
    ROUND(AVG(Cost_Per_unit), 2) AS AvgCostPerUnit, 
    CONCAT(ROUND(SUM(Produced_Qty)/1000000, 2), ' M') AS Accepted_Qty,
    CONCAT(ROUND(SUM(Rejected_Qty)/1000000, 2), ' M') AS Rejected_Qty,
    CONCAT(ROUND(SUM(total_value)/1000000, 2), ' M') AS TotalCost_Million,
    CONCAT(ROUND(SUM(Loss_value)/1000000, 2), ' M') AS TotalLoss_Million
FROM manufacturingdata
GROUP BY Department_Name;

-- STEP-3 “Employee Efficiency & Production Analysis”
select * from manufacturingdata;
select Emp_Name from manufacturingdata;
SELECT 
    Emp_Name,
    CONCAT(
        ROUND(AVG(CAST(REPLACE(Efficiency_percentage, '%', '') AS DECIMAL(10,2))), 2), ' %'
    ) AS AvgEfficiency,
    CONCAT(ROUND(SUM(Produced_Qty)/1000000, 2), ' M') AS TotalProduced_Million
FROM manufacturingdata
GROUP BY Emp_Name
ORDER BY AVG(CAST(REPLACE(Efficiency_percentage, '%', '') AS DECIMAL(10,2))) DESC;

-- STEP 4 “On-Time Delivery Analysis by Buyer”
SELECT 
    Buyer,
    COUNT(*) AS TotalOrders,
    CONCAT(
        ROUND(SUM(CASE WHEN Delivery_Period = 'On Time' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2), ' %'
    ) AS OnTimeDeliveryRate
FROM manufacturingdata
GROUP BY Buyer;

-- STEP-5 “Machine Performance Analysis”
SELECT 
    Machine_Code,
    CONCAT(ROUND(SUM(Produced_Qty)/1000000, 2), ' M') AS TotalProduced_Million,
    CONCAT(
        ROUND(AVG(CAST(REPLACE(Efficiency_percentage, '%', '') AS DECIMAL(10,2))), 2), ' %'
    ) AS AvgEfficiency
FROM manufacturingdata
GROUP BY Machine_Code
ORDER BY SUM(Produced_Qty) DESC;

-- STEP-6 “Manufacturing Performance KPIs” 
SELECT 
    CONCAT(ROUND(SUM(Total_manu_qty)/1000000, 2), ' M') AS TotalManufactured_Million,
    CONCAT(ROUND(SUM(Produced_Qty)/1000000, 2), ' M') AS TotalProduced_Million,
    CONCAT(ROUND(SUM(Rejected_Qty)/1000000, 2), ' M') AS TotalRejected_Million,
    CONCAT(
        ROUND((SUM(Produced_Qty) - SUM(Rejected_Qty)) * 100.0 / NULLIF(SUM(Produced_Qty),0), 2), ' %'
    ) AS AcceptanceRate,
    CONCAT(
        ROUND(AVG(CAST(REPLACE(Efficiency_percentage, '%', '') AS DECIMAL(10,2))), 2), ' %'
    ) AS AvgEfficiency,
    CONCAT(ROUND(SUM(Total_Manu_cost)/1000000, 2), ' M') AS TotalCost_Million,
    CONCAT(ROUND(SUM(Loss_value)/1000000, 2), ' M') AS TotalLoss_Million
FROM manufacturingdata;



