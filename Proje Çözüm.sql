---------------------------------------------------------------------------------------------------------------
--Case 1 : Sipariş Analizi
---------------------------------------------------------------------------------------------------------------



----Question 1 : 
------Aylık olarak order dağılımını inceleyiniz. Tarih verisi için order_approved_at kullanılmalıdır.

SELECT 
	DATE_TRUNC ('MONTH',order_approved_at)::DATE AS monthly,
	COUNT (order_id)
FROM orders
GROUP BY 1
ORDER BY 1



----Question 2 : 
------Aylık olarak order status kırılımında order sayılarını inceleyiniz. Sorgu sonucunda çıkan outputu excel ile görselleştiriniz. Dramatik bir düşüşün ya da yükselişin olduğu aylar var mı? Veriyi inceleyerek yorumlayınız.

SELECT 
	TO_CHAR(order_approved_at,'yyyy-mm') AS monthly,
	order_status,
	COUNT(order_id)
FROM orders
GROUP BY 1,2
ORDER BY 1,2



----Question 3 : 
------Ürün kategorisi kırılımında sipariş sayılarını inceleyiniz. Özel günlerde öne çıkan kategoriler nelerdir? Örneğin yılbaşı, sevgililer günü…

--NOT: Zaman filtreleri bu cevabın en sonunda gösterilmiştir.

SELECT 
	category_name_english AS category,
	COUNT (oi.order_id) AS order_count
FROM translation AS t
INNER JOIN products AS p
	ON p.product_category_name=t.category_name
INNER JOIN order_items AS oi
	ON oi.product_id=p.product_id
INNER JOIN orders AS o
	ON o.order_id=oi.order_id
GROUP BY 1
ORDER BY 2 DESC

--ZAMAN FİLTRELERİ 
--Cevapta belirtilen SQL sorgusuna:
--Yılbaşı için; 
WHERE TO_CHAR(order_approved_at,'yyyy-mm')='2017-12'

--Bağımsızlık Günü için; 
WHERE TO_CHAR(order_approved_at,'yyyy-mm-dd') BETWEEN '2017-08-07' AND '2017-09-07'

--Karnaval için; 
WHERE TO_CHAR(order_approved_at,'yyyy-mm')= '2017-02' or TO_CHAR(order_approved_at,'yyyy-mm')= '2018-02'
--Filtreleri eklenmiştir.



----Question 4 : 
------Haftanın günleri(pazartesi, perşembe, ….) ve ay günleri (ayın 1’i,2’si gibi) bazında order sayılarını inceleyiniz. Yazdığınız sorgunun outputu ile excel’de bir görsel oluşturup yorumlayınız.

--Haftanın günleri:

SELECT 
	TO_CHAR(order_approved_at, 'Day') AS week_days,
	COUNT (order_id) AS orders_count
FROM orders
WHERE TO_CHAR(order_approved_at, 'Day') IS NOT NULL
GROUP BY 1, EXTRACT (ISODOW FROM order_approved_at)
ORDER BY EXTRACT (ISODOW FROM order_approved_at)


--Ayın günleri:

SELECT 
    EXTRACT(DAY FROM order_approved_at) AS day_of_month,
    count (order_id) as orders_count
FROM 
    orders
WHERE EXTRACT(DAY FROM order_approved_at) IS NOT NULL
GROUP BY 1
ORDER BY 1


---------------------------------------------------------------------------------------------------------------
--Case 2 : Müşteri Analizi 
---------------------------------------------------------------------------------------------------------------



----Question 1 : 
------Hangi şehirlerdeki müşteriler daha çok alışveriş yapıyor? Müşterinin şehrini en çok sipariş verdiği şehir olarak belirleyip analizi ona göre yapınız. 

WITH all_customers AS
(
	SELECT
		c.customer_id,
		customer_city,
		COUNT (order_id) AS order_count
	FROM customers AS c
	JOIN orders AS o
		ON o.customer_id=c.customer_id
	GROUP BY 1,2
), 
	customer_with_city AS
(
	SELECT
		customer_id,
		customer_city,
		order_count,
		ROW_NUMBER () OVER (PARTITION BY customer_id ORDER BY order_count) AS rn
	FROM all_customers
)

SELECT 
	customer_id,
	customer_city,
	order_count
FROM customer_with_city
WHERE rn=1



---------------------------------------------------------------------------------------------------------------
--Case 3: Satıcı Analizi
---------------------------------------------------------------------------------------------------------------



----Question 1 : 
------Siparişleri en hızlı şekilde müşterilere ulaştıran satıcılar kimlerdir? Top 5 getiriniz. Bu satıcıların order sayıları ile ürünlerindeki yorumlar ve puanlamaları inceleyiniz ve yorumlayınız.

WITH sellers_shipping_time AS
(
	SELECT 
		s.seller_id,
		COUNT(o.order_id) total_order_count,
		AVG(order_delivered_carrier_date - order_purchase_timestamp) AS sellers_avg_shipping_time
	FROM sellers AS s
	JOIN order_items AS oi
		ON oi.seller_id=s.seller_id
	JOIN orders AS o
		ON o.order_id=oi.order_id
	WHERE (order_delivered_carrier_date - order_purchase_timestamp) IS NOT NULL AND (order_delivered_carrier_date - order_purchase_timestamp)>'0'
	GROUP BY 1
	ORDER BY 3
	LIMIT 5
)
SELECT
	sst.seller_id,
	total_order_count,
	sellers_avg_shipping_time,
	review_score,
	review_comment_message
FROM sellers_shipping_time AS sst
JOIN order_items AS oi
	ON sst.seller_id=oi.seller_id
JOIN reviews AS r
	ON oi.order_id=r.order_id



----Question 2 : 
------Hangi satıcılar daha fazla kategoriye ait ürün satışı yapmaktadır? Fazla kategoriye sahip satıcıların order sayıları da fazla mı? 

SELECT
	seller_id,
	COUNT(DISTINCT product_category_name) AS categories,
	COUNT (o.order_id) AS order_count
FROM order_items AS oi
JOIN products AS p
	ON p.product_id=oi.product_id
JOIN orders AS o
	ON oi.order_id=o.order_id
GROUP BY 1
ORDER BY 2 DESC



---------------------------------------------------------------------------------------------------------------
--Case 4 : Payment Analizi
---------------------------------------------------------------------------------------------------------------



----Question 1 : 
------Ödeme yaparken taksit sayısı fazla olan kullanıcılar en çok hangi bölgede yaşamaktadır? Bu çıktıyı yorumlayınız. 

SELECT 
	c.customer_city,
	MAX(payment_sequential) AS tax_,
	COUNT(o.order_id) AS order_count
FROM payments AS p
JOIN orders AS o
	ON o.order_id=p.order_id
JOIN customers AS c
	ON o.customer_id=c.customer_id
GROUP BY 1
ORDER BY 3 DESC



----Question 2 : 
------Ödeme tipine göre başarılı order sayısı ve toplam başarılı ödeme tutarını hesaplayınız. En çok kullanılan ödeme tipinden en az olana göre sıralayınız.

WITH succ_order AS
(
	SELECT
		payment_type,
		COUNT (DISTINCT p.order_id) AS order_count
	FROM payments AS p
	JOIN orders AS o
		ON p.order_id=o.order_id
	WHERE order_status='delivered'
	GROUP BY 1
	ORDER BY 2 DESC
)
SELECT 
	payment_type,
	order_count,
	(
		SELECT 
	 		ROUND(SUM(payment_value)::numeric,2)
	 	FROM payments AS p
	 	JOIN orders AS o
	 		ON o.order_id=p.order_id
		 WHERE order_status != 'canceled'
	) AS sum_succ_paymet
FROM succ_order



----Question 3 : 
------Tek çekimde ve taksitle ödenen siparişlerin kategori bazlı analizini yapınız. En çok hangi kategorilerde taksitle ödeme kullanılmaktadır?

WITH one_shot_payment AS
(
	SELECT 
		DISTINCT order_id AS one_shot_order_id,
		MAX(payment_sequential) AS one_shot
	FROM payments 
	GROUP BY 1
	HAVING MAX(payment_sequential)=1
	ORDER BY 2 DESC
),
taxit_payment AS
(
	SELECT 
		DISTINCT order_id AS tax_order_id,
		MAX(payment_sequential) AS one_shot
	FROM payments 
	GROUP BY 1
	HAVING MAX(payment_sequential)>1
	ORDER BY 2 ASC
)
SELECT 
	category_name_english,
	COUNT(DISTINCT tax_order_id) AS taxit_order_count,
	COUNT(DISTINCT one_shot_order_id) AS one_shot_order_count
FROM translation AS t
JOIN products AS pr 
	ON t.category_name=pr.product_category_name
JOIN order_items AS oi
	ON pr.product_id=oi.product_id
LEFT JOIN taxit_payment AS tp
	ON tp.tax_order_id=oi.order_id
LEFT JOIN one_shot_payment AS osp
	ON osp.one_shot_order_id=oi.order_id
GROUP BY 1
ORDER BY 2 DESC

---------------------------------------------------------------------------------------------------------------
--RFM ANALİZİ
---------------------------------------------------------------------------------------------------------------



with rfm_analysis as 
(
with recency_values as
(	with max_date as
 	(
		select
			distinct customer_id,
			max(invoicedate) as max_invoice_date
		from rfm
		group by 1
	)
	select
 		customer_id,
 		age('2011-12-09',max_invoice_date::date) as recency
 	from max_date
),
	frequency_values as
(
	select
		distinct customer_id,
		count(distinct invoiceno) as frequency
	from rfm
	group by 1
),
	monetary_values as
(
	select
		distinct customer_id,
		round(sum(quantity*unitprice)::numeric,2) as monetary
	from rfm
	--where unitprice>0 and quantity>0
	group by 1
)
select
	r.customer_id,
	recency,
	frequency,
	monetary
from recency_values as r
join frequency_values as f
	on r.customer_id=f.customer_id
join monetary_values as m
	on r.customer_id=m.customer_id
order by 2
)
select
	customer_id,
	case
		when recency<='3 days' then 5
		when recency>'3 days' and recency<='10 days' then 4
		when recency>'10 days' and recency<='30 days' then 3
		when recency>'30 days' and recency<='90 days' then 2
		when recency>'90 days' then 1
	end as recency,
	case
		when frequency<=5 then 1
		when frequency>5 and frequency<=20 then 2
		when frequency>20 and frequency<=50 then 3
		when frequency>50 and frequency<=100 then 4
		when frequency>100 then 5
	end as frequency,
	case
		when monetary<=200 then 1
		when monetary>200 and monetary<=500 then 2
		when monetary>500 and monetary<=1000 then 3
		when monetary>1000 and monetary<=50000 then 4
		when monetary>50000 then 5
	end as monetary
from rfm_analysis