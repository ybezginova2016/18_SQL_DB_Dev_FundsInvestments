-- 11. Отобразите имя и фамилию всех сотрудников стартапов. Добавьте
-- поле с названием учебного заведения, которое окончил сотрудник,
-- если эта информация известна.

SELECT p.first_name,
        p.last_name,
        e.instituition

FROM people AS p
LEFT JOIN education AS e ON p.id=e.person_id;

-- 12. Для каждой компании найдите количество учебных заведений,
-- которые окончили её сотрудники. Выведите название компании и число
-- уникальных названий учебных заведений. Составьте топ-5 компаний
-- по количеству университетов.

WITH a AS
(SELECT DISTINCT e.instituition AS institute,
     p.company_id AS company_id
FROM people AS p
LEFT JOIN education AS e ON p.id=e.person_id),

b AS
(SELECT  p.company_id AS company_id,
 c.name AS comp_name
FROM company AS c
LEFT JOIN people AS p ON c.id=p.company_id)

SELECT b.comp_name, COUNT(DISTINCT a.institute) AS num_of_institutes
FROM a
INNER JOIN b ON a.company_id=b.company_id
WHERE b.comp_name IS NOT NULL
GROUP BY comp_name
ORDER BY num_of_institutes DESC
LIMIT 5;

-- 13. Составьте список с уникальными названиями закрытых компаний,
-- для которых первый раунд финансирования оказался последним.

SELECT DISTINCT name AS comp_name
FROM company AS c
LEFT JOIN funding_round AS f ON c.id=f.company_id

WHERE c.status='closed' AND f.is_first_round=1 AND f.is_last_round=1;

-- 14. Составьте список уникальных номеров сотрудников, которые
-- работают в компаниях, отобранных в предыдущем задании.
SELECT DISTINCT p.id
FROM company AS c
LEFT JOIN people AS p ON c.id=p.company_id
WHERE p.company_id IN (
    SELECT DISTINCT company_id
    FROM company AS c
    LEFT JOIN funding_round AS f ON c.id=f.company_id
    WHERE c.status='closed' AND f.is_first_round=1 AND f.is_last_round=1
);

-- 15. Составьте таблицу, куда войдут уникальные пары с номерами
-- сотрудников из предыдущей задачи и учебным заведением, которое
-- окончил сотрудник.
SELECT DISTINCT p.id
FROM company AS c
LEFT JOIN people AS p ON c.id=p.company_id
WHERE p.company_id IN (
    SELECT DISTINCT company_id
    FROM company AS c
    LEFT JOIN funding_round AS f ON c.id=f.company_id
    WHERE c.status='closed' AND f.is_first_round=1 AND f.is_last_round=1
);

-- 16. Посчитайте количество учебных заведений для каждого сотрудника
-- из предыдущего задания. При подсчёте учитывайте, что некоторые
-- сотрудники могли окончить одно и то же заведение дважды.
SELECT distinct a.employee_id, count(b.institute_name)
FROM
(SELECT p.id AS employee_id
FROM company AS c
LEFT JOIN people AS p ON c.id=p.company_id
WHERE p.company_id IN (
    SELECT DISTINCT company_id
    FROM company AS c
    LEFT JOIN funding_round AS f ON c.id=f.company_id
    WHERE c.status='closed' AND f.is_first_round=1 AND f.is_last_round=1)) AS a
LEFT JOIN
(SELECT e.person_id AS employee_id, instituition AS institute_name
FROM people AS p
LEFT JOIN education AS e ON p.id=e.person_id) AS b ON a.employee_id=b.employee_id
WHERE b.institute_name IS NOT NULL
GROUP BY a.employee_id;

-- 17. Дополните предыдущий запрос и выведите среднее число учебных
-- заведений (всех, не только уникальных), которые окончили сотрудники
-- разных компаний. Нужно вывести только одну запись, группировка
-- здесь не понадобится.
SELECT AVG(w.number_of_institutes)
FROM
(SELECT distinct a.employee_id, count(b.institute_name) AS number_of_institutes, a.company_name
FROM
(SELECT p.id AS employee_id, c.name AS company_name
FROM company AS c
LEFT JOIN people AS p ON c.id=p.company_id
WHERE p.company_id IN (
    SELECT DISTINCT company_id
    FROM company AS c
    LEFT JOIN funding_round AS f ON c.id=f.company_id
    WHERE c.status='closed' AND f.is_first_round=1 AND f.is_last_round=1)) AS a
LEFT JOIN
(SELECT e.person_id AS employee_id, instituition AS institute_name
FROM people AS p
LEFT JOIN education AS e ON p.id=e.person_id) AS b ON a.employee_id=b.employee_id
WHERE b.institute_name IS NOT NULL
GROUP BY a.employee_id, a.company_name) as w;

-- 18. Напишите похожий запрос: выведите среднее число учебных
-- заведений (всех, не только уникальных), которые окончили сотрудники
-- Facebook*. *(сервис, запрещённый на территории РФ)
SELECT AVG(w.number_of_institutes)
FROM
(SELECT distinct a.employee_id, count(b.institute_name) AS number_of_institutes, a.company_name
FROM
(SELECT p.id AS employee_id, c.name AS company_name
FROM company AS c
LEFT JOIN people AS p ON c.id=p.company_id
WHERE c.name='Facebook') AS a
LEFT JOIN
(SELECT e.person_id AS employee_id, instituition AS institute_name
FROM people AS p
LEFT JOIN education AS e ON p.id=e.person_id) AS b ON a.employee_id=b.employee_id
WHERE b.institute_name IS NOT NULL
GROUP BY a.employee_id, a.company_name) as w;

-- 19. Составьте таблицу из полей:
-- name_of_fund — название фонда;
-- name_of_company — название компании;
-- amount — сумма инвестиций, которую привлекла компания в раунде.
-- В таблицу войдут данные о компаниях, в истории которых было больше
-- шести важных этапов, а раунды финансирования проходили с 2012 по
-- 2013 год включительно.
SELECT f.name AS name_of_fund,
        c.name AS name_of_company,
        fr.raised_amount AS amount
        --, EXTRACT(YEAR FROM CAST(fr.funded_at AS timestamp)) as year
FROM investment AS i
LEFT JOIN company AS c ON i.company_id=c.id
LEFT JOIN fund AS f ON i.fund_id=f.id
LEFT JOIN funding_round AS fr ON i.id=fr.id
WHERE c.milestones > 6 AND EXTRACT(YEAR FROM CAST(fr.funded_at AS timestamp)::date) IN (2012, 2013);

-- 20. Выгрузите таблицу, в которой будут такие поля:
-- название компании-покупателя;
-- сумма сделки;
-- название компании, которую купили;
-- сумма инвестиций, вложенных в купленную компанию;
-- доля, которая отображает, во сколько раз сумма покупки превысила
-- сумму вложенных в компанию инвестиций, округлённая до ближайшего
-- целого числа.
-- Не учитывайте те сделки, в которых сумма покупки равна нулю.
-- Если сумма инвестиций в компанию равна нулю, исключите такую
-- компанию из таблицы.
-- Отсортируйте таблицу по сумме сделки от большей к меньшей, а
-- затем по названию купленной компании в лексикографическом порядке.
-- Ограничьте таблицу первыми десятью записями
WITH buyers AS (SELECT
                    a.id AS id2,
                    c.name AS name_acquiring,
                    a.price_amount AS total
                FROM company AS c
                LEFT JOIN acquisition AS a ON c.id = a.acquiring_company_id),

sellers AS (SELECT
                a.id AS id2,
                c.name AS name_acquired,
                c.funding_total AS sale
            FROM company AS c
            LEFT JOIN acquisition AS a ON c.id = a.acquired_company_id
            WHERE status = 'acquired')

SELECT
    buyers.name_acquiring,
    buyers.total,
    sellers.name_acquired,
    sellers.sale,
    ROUND(buyers.total/sellers.sale)
FROM buyers
LEFT JOIN sellers ON buyers.id2 = sellers.id2
WHERE buyers.total != 0 AND sellers.sale != 0
ORDER BY buyers.total DESC, sellers.name_acquired
LIMIT 10;

-- 21. Выгрузите таблицу, в которую войдут названия компаний из
-- категории social, получившие финансирование с 2010 по 2013 год
-- включительно. Проверьте, что сумма инвестиций не равна нулю.
-- Выведите также номер месяца, в котором проходил раунд
-- финансирования.
WITH
period AS (SELECT
           company_id, funded_at, id
           FROM funding_round
           WHERE (EXTRACT(YEAR FROM CAST(funded_at AS DATE)) BETWEEN '2010' AND '2013') AND raised_amount <> 0),

comp_non_zero AS (SELECT *,
                   SUM(funding_total) OVER (PARTITION BY name) AS sum_f
                  FROM company),

sum AS (SELECT name AS company_name, id AS comp_id, sum_f
         FROM comp_non_zero
         WHERE category_code = 'social'),

query AS (SELECT *, sum.sum_f
          FROM period
          JOIN sum ON sum.comp_id = period.company_id
          WHERE company_id IN (SELECT comp_id FROM sum))

SELECT
   --*
    company_name,
    EXTRACT(MONTH FROM funded_at)
FROM query;

-- 22. Отберите данные по месяцам с 2010 по 2013 год, когда проходили
-- инвестиционные раунды. Сгруппируйте данные по номеру месяца и
-- получите таблицу, в которой будут поля:
-- номер месяца, в котором проходили раунды;
-- количество уникальных названий фондов из США, которые инвестировали в этом месяце;
-- количество компаний, купленных за этот месяц;
-- общая сумма сделок по покупкам в этом месяце.
WITH
rounds AS (SELECT
           *
          FROM funding_round
          WHERE funded_at BETWEEN '2010-01-01' AND '2013-12-31'),

a_comps AS (SELECT
           *
           FROM acquisition
           WHERE acquired_at BETWEEN '2010-01-01' AND '2013-12-31'),

fund_count_dis AS (SELECT i.funding_round_id AS f_round_id_i,
                      f.name AS fund_name,
                      i.company_id AS c_name

                   FROM investment AS i
                   LEFT JOIN fund AS f ON f.id = i.fund_id

                   WHERE f.country_code = 'USA'),

purchase AS (SELECT EXTRACT(MONTH FROM a.acquired_at) AS comp_month,
                    COUNT(a.acquired_company_id) AS comp,
                    SUM(a.price_amount) AS total_purchase

            FROM a_comps AS a
            GROUP BY comp_month),

rounds_and_funds AS (SELECT EXTRACT(MONTH FROM rounds.funded_at) AS month,
                            COUNT(DISTINCT fund_count_dis.fund_name) AS funds

                     FROM rounds
                     LEFT JOIN fund_count_dis ON fund_count_dis.f_round_id_i = rounds.id
                     GROUP BY month)

SELECT rounds_and_funds.month, rounds_and_funds.funds, purchase.comp, purchase.total_purchase
FROM rounds_and_funds
LEFT JOIN purchase ON rounds_and_funds.month = purchase.comp_month;

-- 23. Составьте сводную таблицу и выведите среднюю сумму инвестиций
-- для стран, в которых есть стартапы, зарегистрированные в 2011,
-- 2012 и 2013 годах. Данные за каждый год должны быть в отдельном
-- поле. Отсортируйте таблицу по среднему значению инвестиций за
-- 2011 год от большего к меньшему.

WITH

y2011 AS (SELECT
          country_code,
          AVG(funding_total) AS avg_ft

          FROM company
          WHERE id IN (SELECT id FROM company WHERE EXTRACT(YEAR FROM founded_at) = 2011)
          GROUP BY country_code),

y2012 AS (SELECT
          country_code,
          AVG(funding_total) AS avg_ft

          FROM company
          WHERE id IN (SELECT id FROM company WHERE EXTRACT(YEAR FROM founded_at) = 2012)
          GROUP BY country_code),

y2013 AS (SELECT
          country_code,
          AVG(funding_total) AS avg_ft

          FROM company
          WHERE id IN (SELECT id FROM company WHERE EXTRACT(YEAR FROM founded_at) = 2013)
          GROUP BY country_code)

SELECT y2011.country_code AS country_code,
       y2011.avg_ft AS value_2011,
       y2012.avg_ft AS value_2012,
       y2013.avg_ft AS value_2013

FROM y2011
JOIN y2012 ON y2011.country_code  = y2012.country_code
JOIN y2013 ON y2011.country_code  = y2013.country_code

ORDER BY y2011.avg_ft DESC;

