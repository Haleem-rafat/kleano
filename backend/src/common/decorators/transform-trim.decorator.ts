import { Transform, TransformFnParams } from 'class-transformer';

export function TransformTrim() {
  return Transform(({ value }: TransformFnParams) => transformTrim(value));
}

export function transformTrim(value: any) {
  const transformedValue = typeof value === 'string' ? value.trim() : value;
  return transformedValue;
}
