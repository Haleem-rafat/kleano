import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';

export type AggregatorPromoCodeModel = AggregatorPromoCode & Document;

export const aggregatorPromoCodeModelName = 'aggregator-promo-code';

export enum OperatorEnum {
  LESS_THAN = 'lessThan',
  GREATER_THAN = 'greaterThan',
  EQUALS = 'equals',
}

export enum ExpressionLeftSideEnum {
  ORDERS = 'orders',
}

@Schema()
export class AggregatorPromoCode {
  @Prop({
    type: String,
    required: true,
    enum: Object.values(ExpressionLeftSideEnum),
  })
  expressionLeftSide: ExpressionLeftSideEnum;

  @Prop({ type: String, required: true, enum: Object.values(OperatorEnum) })
  operator: OperatorEnum;

  @Prop({ type: Number, required: true, min: 1 })
  expressionRightSide: number;
}

export const AggregatorPromoCodeSchema =
  SchemaFactory.createForClass(AggregatorPromoCode);
