# Find the next set of steps-unassigned products
SELECT e1.name AS product,      (1+if(e2.steps>e3.steps,e2.steps,e3.steps)) as product_stops,
       e2.name AS ingredient_1, e2.steps                                    as steps_1,
       e3.name AS ingredient_2, e3.steps                                    as steps_2
 FROM recipes, elements as e1, elements as e2, elements as e3
 WHERE product = e1.id
  AND ingredient_1 = e2.id
  AND ingredient_2 = e3.id
  AND e1.steps is NULL
  AND e2.steps is NOT NULL
  AND e3.steps is NOT NULL;

# Assign next set of steps-unassigned products
UPDATE elements,
( SELECT e3.id as id, ( 1 + if( e1.steps > e2.steps, e1.steps, e2.steps ) ) as steps
   FROM recipes, elements as e3, elements as e1, elements as e2
   WHERE product = e3.id
    AND ingredient_1 = e1.id
    AND ingredient_2 = e2.id
    AND e3.steps is NULL
    AND e1.steps is NOT NULL
    AND e2.steps is NOT NULL ) AS products
SET   elements.steps = products.steps
WHERE elements.id    = products.id;

# Display steps-assinged products
SELECT * FROM elements WHERE steps IS NOT NULL;

# Display steps-unassinged products
SELECT * FROM elements WHERE steps IS NULL;
