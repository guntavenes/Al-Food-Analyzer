import { barcodeProductResponseSchema, type BarcodeProductResponse } from '../contracts.js';
import { AppError } from '../errors.js';

type OpenFoodFactsProduct = {
  product_name?: unknown;
  brands?: unknown;
  image_front_url?: unknown;
  quantity?: unknown;
  serving_size?: unknown;
  nutriments?: Record<string, unknown>;
};

const textOrNull = (value: unknown) =>
  typeof value === 'string' && value.trim() ? value.trim() : null;

const numberOrNull = (value: unknown) => {
  const parsed = typeof value === 'number' ? value : Number(value);
  return Number.isFinite(parsed) && parsed >= 0 ? parsed : null;
};

export async function findProductByBarcode(
  barcode: string,
): Promise<BarcodeProductResponse> {
  const endpoint = `https://world.openfoodfacts.org/api/v2/product/${barcode}.json`;
  let response: Response;
  try {
    response = await fetch(endpoint, {
      headers: {
        'User-Agent': 'AI Food Analyzer/1.0 (product lookup)',
        Accept: 'application/json'
      },
      signal: AbortSignal.timeout(8000)
    });
  } catch {
    throw new AppError('SERVICE_UNAVAILABLE', 'Product lookup is temporarily unavailable.', 503);
  }
  if (!response.ok) {
    throw new AppError('SERVICE_UNAVAILABLE', 'Product lookup is temporarily unavailable.', 503);
  }
  const body = await response.json() as { status?: number; product?: OpenFoodFactsProduct };
  const product = body.product;
  const name = textOrNull(product?.product_name);
  if (body.status !== 1 || !product || !name) {
    throw new AppError('PRODUCT_NOT_FOUND', 'No product was found for this barcode.', 404);
  }
  const nutrients = product.nutriments ?? {};
  const calories = numberOrNull(nutrients['energy-kcal_100g']);
  const sodiumGrams = numberOrNull(nutrients['sodium_100g']);
  return barcodeProductResponseSchema.parse({
    barcode,
    name,
    brand: textOrNull(product.brands),
    imageUrl: textOrNull(product.image_front_url),
    quantity: textOrNull(product.quantity),
    servingSize: textOrNull(product.serving_size),
    nutritionPer100g: {
      calories,
      protein: numberOrNull(nutrients['proteins_100g']),
      carbohydrates: numberOrNull(nutrients['carbohydrates_100g']),
      fat: numberOrNull(nutrients['fat_100g']),
      fiber: numberOrNull(nutrients['fiber_100g']),
      sugar: numberOrNull(nutrients['sugars_100g']),
      sodiumMilligrams: sodiumGrams == null ? null : sodiumGrams * 1000
    },
    sourceName: 'Open Food Facts',
    sourceUrl: `https://world.openfoodfacts.org/product/${barcode}`
  });
}
