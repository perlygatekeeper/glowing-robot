INSERT INTO recipes ( product, ingredient_1, ingredient_2, last_updated, date_added )
SELECT e1.id, e2.id, e3.id, now(), now()
FROM elements e1, elements e2, elements e3
WHERE e1.name = 'Steam' AND e2.name = 'Water' AND e3.name = 'Fire';
