import { AppError } from './errors.js';

const supportedMimeTypes = new Set(['image/jpeg', 'image/png', 'image/webp']);

export function validateImage(file: Express.Multer.File | undefined): Express.Multer.File {
  if (!file) throw new AppError('INVALID_IMAGE', 'An image field is required.', 400);
  if (!supportedMimeTypes.has(file.mimetype)) {
    throw new AppError('UNSUPPORTED_IMAGE_TYPE', 'The uploaded file is not a supported image.', 415);
  }
  const bytes = file.buffer;
  const jpeg = bytes[0] === 0xff && bytes[1] === 0xd8 && bytes[2] === 0xff;
  const png = bytes.subarray(0, 8).equals(Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]));
  const webp = bytes.subarray(0, 4).toString() === 'RIFF' && bytes.subarray(8, 12).toString() === 'WEBP';
  if (!jpeg && !png && !webp) {
    throw new AppError('INVALID_IMAGE', 'The uploaded file is not a valid image.', 400);
  }
  return file;
}
