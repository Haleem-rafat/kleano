import { OrderDetailsData } from '../helpers/email-template.helper';

export interface InvoiceData {
  invoiceNumber: string;
  customerName: string;
  invoiceDate: string;
  dueDate: string;
  totalAmount: number;
  pdfUrl: string;
}

export interface EmailOptions {
  orderData?: OrderDetailsData;
  invoiceData?: InvoiceData;
  email: string;
  senderName: string;
  subject: string;
}
