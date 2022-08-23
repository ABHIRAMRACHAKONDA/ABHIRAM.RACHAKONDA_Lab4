use E_Commerce;
-- QUESTION 3: Display the total number of customers based on gender who have placed orders of worth at least Rs.3000.

select count(table2.cus_gender) as 'Number of customers', table2.cus_gender from 
(select table1.cus_id, table1.cus_gender, table1.ord_amount, table1.cus_name from 
(select `order`.*, customer.cus_gender, customer.cus_name from `order` inner join 
customer on `order`.cus_id=customer.cus_id having `order`.ord_amount >= 3000)
as table1 group by table1.cus_id) as table2 group by cus_gender order by cus_gender; 

-- other ways to write this:

select  count(*) as 'Number of customers' , CUS_GENDER AS gender from customer
where CUS_ID in (select distinct(CUS_ID) from `order` 
where ORD_AMOUNT >=3000)
group by CUS_GENDER
order by CUS_GENDER;

-- other ways to write this:

select COUNT(*) as 'Number of customers' , CUS_GENDER AS gender
	from (select distinct(CUS_ID) from `order` 
where ORD_AMOUNT >=3000 ) as Table1 
		inner join
		customer
		on customer.CUS_ID= Table1.CUS_ID
	group by customer.cus_gender
    order by CUS_GENDER;
    ;
    
    -- other ways to write this:
    
SELECT count(DISTINCT customer.CUS_ID) AS 'Number of customers' , customer.CUS_GENDER as 'gender' FROM customer
INNER JOIN 
`order` ON `order`.CUS_ID = customer.CUS_ID
WHERE `order`.ORD_AMOUNT >= 3000
GROUP BY customer.CUS_GENDER;

-- ------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------------------

-- QUESTION 4:  Display all the orders along with product name ordered by a customer having Customer_Id=2

-- Solution without inner joins

select  ORD.ORD_ID AS ORDER_ID , ORD.ORD_AMOUNT AS ORDER_AMOUNT , ORD.ORD_DATE AS ORDER_DATE , ORD.CUS_ID AS CUSTOMER_ID, ORD.PRICING_ID ,
PR.PRO_NAME AS PRODUCT_NAME
from `order` ORD, SUPPLIER_PRICING SP, product PR
where  ORD.CUS_ID = 2
and ORD.PRICING_ID = SP.PRICING_ID
and SP.PRO_ID = PR.PRO_ID;

-- Solution with inner joins

select  ORD.ORD_ID AS ORDER_ID , ORD.ORD_AMOUNT AS ORDER_AMOUNT , ORD.ORD_DATE AS ORDER_DATE , ORD.PRICING_ID ,
 PR.PRO_NAME AS PRODUCT_NAME, ORD.CUS_ID AS CUSTOMER_ID
from SUPPLIER_PRICING SP INNER JOIN product PR
ON SP.PRO_ID = PR.PRO_ID INNER JOIN 
`order` ORD ON ORD.PRICING_ID = SP.PRICING_ID
where  ORD.CUS_ID = 2;

-- other ways to do this

select `order`.*, product.pro_name
from `order`, supplier_pricing, product
where `order`.cus_id=2
and `order`.PRICING_ID = supplier_pricing.PRICING_ID
and supplier_pricing.PRO_ID = product.pro_id;

-- OTHER WAYS TO DO THIS SELECTING ALL COLUMNS FROM `order` AND PRODUCT NAME FROM product :

SELECT  product.PRO_NAME, `order`.*
   FROM `order`
INNER JOIN 
   supplier_pricing  ON supplier_pricing.PRICING_ID = `order`.PRICING_ID
INNER JOIN
product as product ON product.PRO_ID = supplier_pricing.PRO_ID
WHERE `order`.CUS_ID = 2;

-- ---------------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------------

-- QUESTION 5: Display the Supplier details who can supply more than one product.

select * from supplier where 
SUPP_ID in (select SUPP_ID from supplier_pricing group by SUPP_ID having count(SUPP_ID) > 1);

-- alternate way to write this: 

SELECT supplier.*
FROM supplier, supplier_pricing 
WHERE supplier.supp_id = supplier_pricing.supp_id 
GROUP BY supplier_pricing.supp_id 
HAVING COUNT(supplier_pricing.supp_id ) > 1;

-- other ways to do this:

SELECT supplier.* FROM supplier_pricing
INNER JOIN 
supplier ON supplier.SUPP_ID = supplier_pricing.SUPP_ID
GROUP BY supplier_pricing.SUPP_ID 
HAVING count(DISTINCT PRO_ID) > 1;

-- -------------------------------------------------------------------------------------------------------------------------

-- QUESTION 6: Find the least expensive product from each category and print the table with category id,
-- name and price of the product

-- below query is with product name
select C.Cat_Id , C.Cat_Name, P.Pro_Name,  O.ORD_AMOUNT 
from category C 
inner join product P on C.CAT_ID = P.CAT_ID 
inner join supplier_pricing sp on sp.PRO_ID = p.PRO_ID 
inner join `order` O on O.PRICING_ID = sp.PRICING_ID 
group by p.PRO_NAME 
order by O.ORD_AMOUNT 
limit 5;

-- NOTE FOR EVALUATOR: AS PER LAB SESSION, PRODUCT NAME AS ITS AMBIGUOUS. HENCE REMOVING PRODUCT NAME
-- THIS IS AS PER INSTRUCTIONS, KINDLY DO NOT REDUCE MARKS FOR THE SAME. WE HAVE CORRECTED QUESTION AS ABOVE.  


-- Solution using Inner joins 

select cat.CAT_ID as 'category Id' , cat.CAT_NAME as 'category name',  LEAST_CATEGORY_PRICE.LEAST_PRICE as ' Least price' from
(select  min(SUPP_PRICE) as LEAST_PRICE , PR.CAT_ID, PR.PRO_ID from supplier_pricing SP INNER JOIN product PR ON
SP.PRO_ID= PR.PRO_ID GROUP BY PR.CAT_ID) as LEAST_CATEGORY_PRICE 
INNER JOIN product PR ON PR.PRO_ID = LEAST_CATEGORY_PRICE.PRO_ID
 INNER JOIN category cat ON 
cat.CAT_ID = PR.CAT_ID;

-- other ways to write query 
select cat.CAT_ID AS 'category Id' , cat.CAT_NAME as 'category name',  LEAST_CATEGORY_PRICE.LEAST_PRICE as 'Least price' from
(select  min(SUPP_PRICE) as LEAST_PRICE , PR.CAT_ID, PR.PRO_ID from supplier_pricing SP INNER JOIN product PR ON
SP.PRO_ID= PR.PRO_ID GROUP BY PR.CAT_ID) as LEAST_CATEGORY_PRICE , product PR , category cat
where PR.PRO_ID = LEAST_CATEGORY_PRICE.PRO_ID
 AND cat.CAT_ID = PR.CAT_ID;
 
 -- More other ways to write query
select cat.CAT_ID AS 'category Id' , cat.CAT_NAME as ' category name',  MIN(SP.SUPP_PRICE) AS 'Least Price'
	from supplier_pricing SP 
		INNER JOIN  product PR on SP.PRO_ID = PR.PRO_ID
		INNER JOIN category CAT on PR.CAT_ID = CAT.CAT_ID
        GROUP BY  PR.CAT_ID
	    HAVING  MIN(SP.SUPP_PRICE) ORDER BY PR.CAT_ID;
        
-- More other ways to write query
select category.*, min(supplier_pricing.supp_price) from supplier_pricing 
     join product on product.pro_id = supplier_pricing.pro_id
     join category on category.cat_id=product.cat_id 
     group by product.cat_id order by product.cat_id ;
     
-- -----------------------------------------------------------------------------------------------------------------------------------
-- -----------------------------------------------------------------------------------------------------------------------------------
-- QUESTION 7: Display the Id and Name of the Product ordered after “2021-10-05”.

-- Solution without inner joins

select pr.PRO_ID as 'Id' , pr.PRO_NAME as 'Name of the Product' from product pr , supplier_pricing sp, `order` ord 
where pr.PRO_ID = sp.PRO_ID
and sp.PRICING_ID = ord.PRICING_ID
and ord.ORD_DATE > '2021-10-05';

-- Solution with inner joins
select pr.PRO_ID as 'Id' , pr.PRO_NAME as 'Name of the Product' from product pr  
INNER JOIN  supplier_pricing sp
ON  pr.PRO_ID = sp.PRO_ID
 INNER JOIN `order` ord
ON sp.PRICING_ID = ord.PRICING_ID
and ord.ORD_DATE > '2021-10-05';

-- ------------------------------------------------------------------------------------------------------------------------------
-- -------------------------------------------------------------------------------------------------------------------------------
-- QUESTION 8: Display customer name and gender whose names start or end with character 'A'

select CUS_NAME AS 'customer name ', CUS_GENDER as 'gender' from customer where CUS_NAME LIKE ( 'A%' ) OR 
CUS_NAME LIKE ( '%A' );

-- OTHER WAYS TO WRITE THIS 
SELECT CUS_NAME as CustomerName, CUS_GENDER as Gender 
FROM customer
WHERE ( CUS_NAME LIKE '%A' OR CUS_NAME LIKE 'A%') ;

/*
9) Create a stored procedure to display supplier id, 
name, rating and Type_of_Service. 
For Type_of_Service, If rating =5, print “Excellent
Service”,If rating >4 print “Good Service”, If rating >2 print “Average Service” 
else print “Poor Service”.
*/


DELIMITER &&
CREATE PROCEDURE display_supplier_ratings()
BEGIN

select s.supp_id, s.supp_name, avg(rat_ratstars),
	case when avg(rat_ratstars) = 5 then 'Excellent Service'
		 when avg(rat_ratstars) > 4 then 'Good Service'
         when avg(rat_ratstars) > 2 then 'Average Service'
         else 'Poor Service'
	end as type_of_service
    from supplier s, `order` o, supplier_pricing sp, rating r
    where s.supp_id = sp.supp_id
		and sp.pricing_id = o.pricing_id
        and o.ord_id = r.ord_id
	group by s.supp_id order by s.supp_id;

END &&
DELIMITER ;

call display_supplier_ratings();