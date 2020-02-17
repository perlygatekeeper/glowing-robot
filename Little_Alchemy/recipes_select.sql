SELECT e1.name AS product, e2.name AS ingredient_1, e3.name AS ingredient_2
 FROM recipes, elements as e1, elements as e2, elements as e3
 WHERE product = e1.id AND ingredient_1 = e2.id AND ingredient_2 = e3.id;
