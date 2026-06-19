

create or replace view users as (
	select 
			id,
			current_age,
			gender,
			cast(replace(replace(yearly_income,'$',''),',','') as numeric) as c_yearly_income,
			cast(replace(replace(per_capita_income,'$',''),',','') as numeric) as c_per_capita_income,
			cast(replace(replace(total_debt,'$',''),',','') as numeric) as c_total_debt,
			num_credit_cards,
			credit_score
	from users_data 
);

SELECT * FROM users;




SELECT * FROM cards  ;

create or replace view cards as (
	select 
			id,
			client_id,
			card_brand,
			card_type,
			cast(replace(replace(credit_limit,'$',''),',','') as numeric) as c_credit_limit
	from cards_data 
);




SELECT * FROM transactions_data ; 


create or replace view transactions as (
 			select id,
 					date,
 					client_id,
 					card_id,
 					CAST(REPLACE(amount, ',', '.') AS NUMERIC) AS c_amount,
 					mcc,
 					errors,
 					"Broad_Category" AS broad_category    
 			from transactions_data 
		join mcc_codes_grouped_final
			on mcc_codes_grouped_final.mcc_id = transactions_data.mcc
)
SELECT * FROM transactions;
SELECT
    TRIM(errors) AS error_type,
    COUNT(DISTINCT client_id) AS customer_count
FROM transactions
WHERE errors IS NOT NULL
GROUP BY TRIM(errors)
ORDER BY customer_count DESC;
SELECT 
    COUNT(DISTINCT client_id) AS customer_count
FROM transactions
WHERE errors IS NULL
ORDER BY customer_count DESC;



WITH customers AS  (
	select 
			id as user_id,
			current_age,
			gender,
			-- 1.distribution customer group based on age
			case 
				when current_age < 30 then 'Under 30'
				when current_age between 30 and 58 then 'Middle_age'
				else 'Senior'
			end as age_group,
			c_yearly_income,
			c_total_debt ,
			-- 2.DTI rate (debt-to-income)
			round((c_total_debt / nullif(c_yearly_income,0)) * 100.0 ,2) as dti_ratio,
			num_credit_cards,
			credit_score,
			-- 3.Credit ratings
			case 
				when credit_score >= 740 then 'Excellent'
				when credit_score >= 670 then 'Good'
				when credit_score >= 580 then 'Fair'
				else 'Poor'
			end credit_tier
		from users
			)

SELECT *
FROM customers
 		

WITH card_summary AS (
    SELECT
        client_id,

        COUNT(DISTINCT CASE
            WHEN card_type LIKE 'Credit'
            THEN id
        END) AS credit_card_count,

        COUNT(DISTINCT CASE
            WHEN card_type LIKE 'Debit%'
            THEN id
        END) AS debit_card_count

    FROM cards
    GROUP BY client_id
)

SELECT
    t.*,
    cs.credit_card_count,
    cs.debit_card_count
FROM transactions t
LEFT JOIN card_summary cs
    ON t.client_id = cs.client_id;

