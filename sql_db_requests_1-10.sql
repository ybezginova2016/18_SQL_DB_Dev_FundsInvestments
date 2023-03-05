-- 1. Посчитайте, сколько компаний закрылось.
SELECT count(*)
FROM company
WHERE status='closed';

--2. Отобразите количество привлечённых средств для новостных
-- компаний США. Используйте данные из таблицы company.
-- Отсортируйте таблицу по убыванию значений в поле funding_total.

SELECT funding_total
FROM company
WHERE category_code='news' AND country_code='USA'
--GROUP BY funding_total
ORDER BY funding_total DESC;

-- 3. Найдите общую сумму сделок по покупке одних компаний другими
-- в долларах. Отберите сделки, которые осуществлялись только за
-- наличные с 2011 по 2013 год включительно.

SELECT SUM(price_amount)
FROM acquisition
WHERE term_code='cash' AND EXTRACT(YEAR FROM CAST(acquired_at AS date)) IN (2011, 2012, 2013);

-- 4. Отобразите имя, фамилию и названия аккаунтов людей в твиттере,
-- у которых названия аккаунтов начинаются на 'Silver'.
SELECT first_name, last_name, twitter_username
FROM people
WHERE twitter_username LIKE 'Silver%';

-- 5. Выведите на экран всю информацию о людях, у которых названия
-- аккаунтов в твиттере содержат подстроку 'money', а фамилия
-- начинается на 'K'.
SELECT *
FROM people
WHERE twitter_username LIKE '%money%' AND last_name LIKE 'K%';

-- 6. Для каждой страны отобразите общую сумму привлечённых
-- инвестиций, которые получили компании, зарегистрированные в этой
-- стране. Страну, в которой зарегистрирована компания, можно
-- определить по коду страны. Отсортируйте данные по убыванию суммы.
SELECT country_code, SUM(funding_total) AS total_invest
FROM company
GROUP BY country_code
ORDER BY total_invest DESC;

-- 7. Составьте таблицу, в которую войдёт дата проведения раунда,
-- а также минимальное и максимальное значения суммы инвестиций,
-- привлечённых в эту дату.
-- Оставьте в итоговой таблице только те записи, в которых
-- минимальное значение суммы инвестиций не равно нулю и не
-- равно максимальному значению.

SELECT CAST(funded_at AS timestamp)::date AS funded_date,
    MIN(raised_amount),
    MAX(raised_amount)
FROM funding_round
GROUP BY funded_date
HAVING MIN(raised_amount)!=MAX(raised_amount) AND
MIN(raised_amount)!=0;

-- 8. Создайте поле с категориями:
-- Для фондов, которые инвестируют в 100 и более компаний, назначьте
-- категорию high_activity.
-- Для фондов, которые инвестируют в 20 и более компаний до 100,
-- назначьте категорию middle_activity.
-- Если количество инвестируемых компаний фонда не достигает 20,
-- назначьте категорию low_activity.
-- Отобразите все поля таблицы fund и новое поле с категориями.
SELECT *,
    CASE
        WHEN invested_companies>=100 THEN 'high_activity'
        WHEN invested_companies>=20 AND invested_companies<100 THEN 'middle_activity'
        WHEN invested_companies<20 THEN 'low_activity'
    END
FROM fund;

-- 9. Для каждой из категорий, назначенных в предыдущем задании,
-- посчитайте округлённое до ближайшего целого числа среднее
-- количество инвестиционных раундов, в которых фонд принимал
-- участие. Выведите на экран категории и среднее число инвестиционных
-- раундов. Отсортируйте таблицу по возрастанию среднего.
SELECT ROUND(AVG(investment_rounds)) AS avg_num_rounds,
       CASE
           WHEN invested_companies>=100 THEN 'high_activity'
           WHEN invested_companies>=20 THEN 'middle_activity'
           ELSE 'low_activity'
       END AS activity
FROM fund
GROUP BY activity
ORDER BY avg_num_rounds ASC;

-- 10. Проанализируйте, в каких странах находятся фонды, которые чаще
-- всего инвестируют в стартапы.
-- Для каждой страны посчитайте минимальное, максимальное и среднее
-- число компаний, в которые инвестировали фонды этой страны,
-- основанные с 2010 по 2012 год включительно. Исключите страны
-- с фондами, у которых минимальное число компаний, получивших
-- инвестиции, равно нулю. Выгрузите десять самых активных
-- стран-инвесторов.
-- Отсортируйте таблицу по среднему количеству компаний от
-- большего к меньшему, а затем по коду страны в лексикографическом
-- порядке.

SELECT country_code,
    MIN(invested_companies),
    MAX(invested_companies),
    AVG(invested_companies)

FROM fund
WHERE EXTRACT(YEAR FROM CAST(founded_at AS timestamp)) IN (2010,
                                                           2011,
                                                           2012)
GROUP BY country_code
HAVING MIN(invested_companies) != 0
ORDER BY AVG(invested_companies) DESC, country_code ASC
LIMIT 10
;