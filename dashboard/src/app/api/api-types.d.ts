declare interface IFormField extends React.InputHTMLAttributes<HTMLInputElement> {
  name: string;
  title: string;
  placeholder: string;
  type?: string;
  iconField?: string;
  pattern?: string;
  wrapperClassName?: string;
  options?: { value: string; label: string }[];
}

interface IEndpointRequest<Params, Body> {
  params: Params;
  body: Body;
}

interface IEndpointResponse<DataResponseType, ErrorResponseType> {
  success: boolean;

  // error?: ErrorResponseType;

  data?: DataResponseType;
  pages?: number;
  page?: number;
  limit?: number;
  total?: number;
}

declare interface Pagination {
  totalPages: number;
  totalItems: number;
  page: number;
  perPage: number;
}
declare interface IPagination {
  page?: number;
  limit?: number;
  startupId?: string;
}

// NEW TYPES
export interface IResponsePayload<T> {
  length: number;
  data?: T[] | T;
  pages?: number;
  page?: number;
  limit?: number;
  total?: number;
}

export interface ICustomResponse<T = unknown> {
  data?: IResponsePayload<T>;
  localizedMessage: ILocalizedText;
  statusCode: number;
  event: string;
}

export interface ICustomError {
  localizedMessage: ILocalizedText;
  event: string;
  errorType: EErrorType;
  error?: IFieldWithErrors[];
}

export interface ILocalizedText {
  en: string;
  ar: string;
}

export enum EErrorType {
  MISSING = 'MISSING',
  INVALID = 'INVALID',
  DUPLICATE = 'DUPLICATE',
  NOT_FOUND = 'NOT_FOUND',
  WRONG_REQUEST = 'WRONG_REQUEST',
  UNAUTHORIZED = 'UNAUTHORIZED',
  FORBIDDEN = 'FORBIDDEN',
  UNVERIFIED = 'UNVERIFIED',
  UNKNOWN = 'UNKNOWN',
  WRONG_INPUT = 'WRONG_INPUT',
  SAME_PASSWORD = 'SAME_PASSWORD',
  MANY_TRIALS = 'MANY_TRIALS',
  BACKEND_CODE = 'BACKEND_CODE',
  UNHEALTHY = 'UNHEALTHY_SERVICE',
  CONFLICT = 'CONFLICT',
}

export interface IFieldWithErrors {
  fieldName: string;
  constraints: { [x: string]: string };
}
