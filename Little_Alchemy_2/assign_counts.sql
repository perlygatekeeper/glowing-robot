SELECT * FROM
( SELECT id1 as id, c1, c2, (c1+c2) AS used_in FROM
  ( SELECT ingredient_1 as id1, COUNT(*) AS c1 FROM recipes GROUP BY ingredient_1) AS s1,
  ( SELECT ingredient_2 as id2, COUNT(*) AS c2 FROM recipes GROUP BY ingredient_2) AS s2
  WHERE s1.id1=s2.id2
) as counts;

UPDATE elements,
  ( SELECT id1 as id, c1, c2, (c1+c2) AS used_in FROM
    ( SELECT ingredient_1 as id1, COUNT(*) AS c1 FROM recipes GROUP BY ingredient_1) AS s1,
    ( SELECT ingredient_2 as id2, COUNT(*) AS c2 FROM recipes GROUP BY ingredient_2) AS s2
    WHERE s1.id1=s2.id2
  ) as counts
  SET   elements.used_in = counts.used_in
  WHERE elements.id      = counts.id;


# histogram of number of elements for a given used_in values
select used_in, COUNT(*) FROM elements GROUP BY used_in;

# list elements by ascending popularity 
select name, used_in  FROM elements ORDER BY used_in ASC, name ASC;
