# Food Analysis Prompt Examples

These compact examples define expected behavior. Each output must also include a
runtime-generated `requestId`. Nutrition values are intentionally approximate.

## Pizza
Input: Photo of two slices of pepperoni pizza.
Output: `{"foodName":"Pepperoni Pizza","calories":620,"protein":26,"carbohydrates":68,"fat":28,"fiber":4,"sugar":7,"sodium":1380,"confidence":0.9,"servingDescription":"2 slices","servingWeightGrams":260,"healthScore":42,"isFoodDetected":true,"analysisDescription":"Estimated values for two restaurant-style slices; cheese, crust, and toppings may vary.","warnings":["Sodium varies by cheese and processed meat."],"detectedFoods":[{"name":"Pepperoni pizza","estimatedWeightGrams":260,"calories":620,"confidence":0.9}]}`

## Hamburger
Input: Restaurant cheeseburger with bun and sauce.
Output: `{"foodName":"Cheeseburger","calories":690,"protein":34,"carbohydrates":48,"fat":39,"fiber":3,"sugar":9,"sodium":1210,"confidence":0.84,"servingDescription":"1 restaurant burger","servingWeightGrams":310,"healthScore":38,"isFoodDetected":true,"analysisDescription":"Estimated restaurant portion; patty fat, sauce, and cheese may vary.","warnings":["Hidden sauce and cooking fat reduce certainty."],"detectedFoods":[{"name":"Cheeseburger","estimatedWeightGrams":310,"calories":690,"confidence":0.84}]}`

## Salad
Input: Mixed green salad with tomato, cucumber, feta, and dressing.
Output: `{"foodName":"Feta Garden Salad","calories":310,"protein":10,"carbohydrates":20,"fat":22,"fiber":7,"sugar":9,"sodium":590,"confidence":0.82,"servingDescription":"1 medium bowl","servingWeightGrams":380,"healthScore":82,"isFoodDetected":true,"analysisDescription":"Estimated values; dressing quantity is the main source of uncertainty.","warnings":["Dressing may materially change calories."],"detectedFoods":[{"name":"Mixed vegetables","estimatedWeightGrams":280,"calories":110,"confidence":0.9},{"name":"Feta and dressing","estimatedWeightGrams":100,"calories":200,"confidence":0.7}]}`

## Döner
Input: Plate of chicken döner with rice and salad.
Output: `{"foodName":"Chicken Döner Plate","calories":760,"protein":45,"carbohydrates":78,"fat":29,"fiber":8,"sugar":8,"sodium":1460,"confidence":0.8,"servingDescription":"1 restaurant plate","servingWeightGrams":560,"healthScore":58,"isFoodDetected":true,"analysisDescription":"Estimated restaurant portion; meat oil and rice preparation may vary.","warnings":["Added oil and salt are not fully visible."],"detectedFoods":[{"name":"Chicken döner","estimatedWeightGrams":200,"calories":390,"confidence":0.84},{"name":"Rice","estimatedWeightGrams":220,"calories":290,"confidence":0.82},{"name":"Salad","estimatedWeightGrams":140,"calories":80,"confidence":0.88}]}`

## Sushi
Input: Eight pieces of salmon avocado sushi.
Output: `{"foodName":"Salmon Avocado Sushi","calories":440,"protein":20,"carbohydrates":62,"fat":12,"fiber":5,"sugar":8,"sodium":760,"confidence":0.91,"servingDescription":"8 pieces","servingWeightGrams":300,"healthScore":70,"isFoodDetected":true,"analysisDescription":"Estimated values for eight visible pieces; rice seasoning may vary.","warnings":["Soy sauce is excluded unless visibly consumed."],"detectedFoods":[{"name":"Salmon avocado sushi","estimatedWeightGrams":300,"calories":440,"confidence":0.91}]}`

## Pasta
Input: Bowl of spaghetti with tomato sauce and parmesan.
Output: `{"foodName":"Tomato Parmesan Spaghetti","calories":590,"protein":20,"carbohydrates":92,"fat":16,"fiber":8,"sugar":12,"sodium":820,"confidence":0.86,"servingDescription":"1 medium bowl","servingWeightGrams":430,"healthScore":62,"isFoodDetected":true,"analysisDescription":"Estimated home-style serving; oil and parmesan quantity may vary.","warnings":["Sauce oil is difficult to estimate visually."],"detectedFoods":[{"name":"Cooked spaghetti","estimatedWeightGrams":300,"calories":470,"confidence":0.9},{"name":"Tomato sauce and parmesan","estimatedWeightGrams":130,"calories":120,"confidence":0.75}]}`

## Kahvaltı tabağı
Input: Turkish breakfast plate with egg, cheese, olives, tomato, cucumber, bread.
Output: `{"foodName":"Turkish Breakfast Plate","calories":650,"protein":27,"carbohydrates":58,"fat":35,"fiber":9,"sugar":10,"sodium":1320,"confidence":0.83,"servingDescription":"1 breakfast plate","servingWeightGrams":520,"healthScore":66,"isFoodDetected":true,"analysisDescription":"Estimated mixed breakfast; bread, cheese, and olive portions may vary.","warnings":["Salt content depends strongly on cheese and olives."],"detectedFoods":[{"name":"Egg","estimatedWeightGrams":60,"calories":90,"confidence":0.95},{"name":"Cheese and olives","estimatedWeightGrams":110,"calories":300,"confidence":0.82},{"name":"Bread","estimatedWeightGrams":100,"calories":250,"confidence":0.86},{"name":"Tomato and cucumber","estimatedWeightGrams":250,"calories":10,"confidence":0.9}]}`

## Çorba
Input: Bowl of lentil soup.
Output: `{"foodName":"Lentil Soup","calories":260,"protein":13,"carbohydrates":38,"fat":7,"fiber":11,"sugar":5,"sodium":720,"confidence":0.88,"servingDescription":"1 medium bowl","servingWeightGrams":360,"healthScore":79,"isFoodDetected":true,"analysisDescription":"Estimated bowl of lentil soup; oil and salt may vary by recipe.","warnings":["Recipe-specific oil is not fully visible."],"detectedFoods":[{"name":"Lentil soup","estimatedWeightGrams":360,"calories":260,"confidence":0.88}]}`

## Tatlı
Input: One slice of chocolate cake.
Output: `{"foodName":"Chocolate Cake","calories":480,"protein":6,"carbohydrates":62,"fat":24,"fiber":3,"sugar":42,"sodium":360,"confidence":0.86,"servingDescription":"1 slice","servingWeightGrams":140,"healthScore":25,"isFoodDetected":true,"analysisDescription":"Estimated bakery-style slice; frosting and recipe may vary.","warnings":["Sugar and fat vary substantially by recipe."],"detectedFoods":[{"name":"Chocolate cake","estimatedWeightGrams":140,"calories":480,"confidence":0.86}]}`

## Yemek olmayan fotoğraf
Input: Photo of a laptop on a desk.
Output: `{"foodName":null,"calories":null,"protein":null,"carbohydrates":null,"fat":null,"fiber":null,"sugar":null,"sodium":null,"confidence":0,"servingDescription":null,"servingWeightGrams":null,"healthScore":null,"isFoodDetected":false,"analysisDescription":"No food could be detected in this image.","warnings":[],"detectedFoods":[]}`
