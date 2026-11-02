export interface QoyodConfig {
  apiKey: string;
  baseUrl: string;
}

export interface QoyodInvoiceItem {
  item_id?: string;
  description: string;
  quantity: number;
  unit_price: number;
  discount?: number;
  discount_type?: 'percentage' | 'fixed';
  tax_percent?: number;
}

export interface QoyodInvoiceCustomer {
  name: string;
  email?: string;
  phone?: string;
  address?: string;
  tax_number?: string;
  customer_id?: string;
}

export interface QoyodCreateInvoiceRequest {
  contact: QoyodInvoiceCustomer;
  invoice_date: string; // Format: YYYY-MM-DD
  due_date?: string; // Format: YYYY-MM-DD
  invoice_number?: string;
  reference?: string;
  currency?: string; // Default: SAR
  items: QoyodInvoiceItem[];
  notes?: string;
  terms_and_conditions?: string;
  discount?: number;
  discount_type?: 'percentage' | 'fixed';
  tax_inclusive?: boolean;
  status?: 'draft' | 'sent' | 'paid' | 'partial';
}

export interface QoyodInvoiceResponse {
  id: string;
  invoice_number: string;
  reference?: string;
  contact: QoyodInvoiceCustomer;
  invoice_date: string;
  due_date: string;
  currency: string;
  subtotal: number;
  total_discount: number;
  total_tax: number;
  total: number;
  amount_due: number;
  status: string;
  items: QoyodInvoiceItem[];
  notes?: string;
  terms_and_conditions?: string;
  created_at: string;
  updated_at: string;
  pdf_url?: string;
}

export interface QoyodPaymentRequest {
  invoice_id: string;
  payment_date: string; // Format: YYYY-MM-DD
  amount: number;
  payment_method: 'cash' | 'bank_transfer' | 'credit_card' | 'cheque' | 'other';
  reference?: string;
  notes?: string;
  account_id?: string;
}

export interface QoyodPaymentResponse {
  id: string;
  invoice_id: string;
  payment_date: string;
  amount: number;
  payment_method: string;
  reference?: string;
  notes?: string;
  created_at: string;
  updated_at: string;
}

export interface QoyodApiError {
  error: {
    message: string;
    code: string;
    details?: any;
  };
}

export interface QoyodCreateReceiptRequest {
  receipt: {
    contact: string;
    reference?: string;
    kind: 'received' | 'paid';
    account_id: number;
    amount: number;
    description?: string;
    date: string;
    notes?: string;
  };
}

export interface QoyodReceiptResponse {
  id: string;
  receipt_number: string;
  contact_id: number;
  contact_name: string;
  kind: string;
  account_id: number;
  amount: number;
  description?: string;
  date: string;
  notes?: string;
  reference?: string;
  status: string;
  created_at: string;
  updated_at: string;
  pdf_url?: string;
}
