# Qoyod Integration Module

This module provides integration with [Qoyod](https://www.qoyod.com/) accounting system for invoice management and payment processing.

## Features

- ✅ Create invoices in Qoyod
- ✅ Record invoice payments
- ✅ Get invoice details
- ✅ Download invoices as PDF
- ✅ List invoices with filters
- ✅ Delete invoices

## Setup

### 1. Environment Variables

Add the following environment variables to your `.env` file:

```env
QOYOD_API_KEY=your_qoyod_api_key_here
QOYOD_BASE_URL=https://api.qoyod.com/2.0
```

### 2. Get Your API Key

1. Log in to your Qoyod account
2. Go to Settings → API Settings
3. Generate a new API key
4. Copy the API key to your `.env` file

## API Endpoints

### Create Invoice

**POST** `/qoyod/invoices`

Create a new invoice in Qoyod.

**Request Body:**

```json
{
  "contact": {
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "+966501234567",
    "address": "Riyadh, Saudi Arabia",
    "tax_number": "123456789"
  },
  "invoice_date": "2025-11-09",
  "due_date": "2025-11-19",
  "reference": "ORDER-001",
  "currency": "SAR",
  "items": [
    {
      "description": "Car Wash Service",
      "quantity": 1,
      "unit_price": 100.00,
      "tax_percent": 15
    }
  ],
  "notes": "Thank you for your business",
  "status": "sent"
}
```

**Response:**

```json
{
  "id": "inv_123456",
  "invoice_number": "INV-2025-001",
  "reference": "ORDER-001",
  "contact": {...},
  "invoice_date": "2025-11-09",
  "due_date": "2025-11-19",
  "currency": "SAR",
  "subtotal": 100.00,
  "total_tax": 15.00,
  "total": 115.00,
  "amount_due": 115.00,
  "status": "sent",
  "items": [...],
  "pdf_url": "https://app.qoyod.com/invoices/inv_123456/pdf"
}
```

---

### Record Payment

**POST** `/qoyod/payments`

Record a payment for an invoice.

**Request Body:**

```json
{
  "invoice_id": "inv_123456",
  "payment_date": "2025-11-09",
  "amount": 115.00,
  "payment_method": "credit_card",
  "reference": "TXN-98765",
  "notes": "Payment received via credit card"
}
```

**Response:**

```json
{
  "id": "pay_789012",
  "invoice_id": "inv_123456",
  "payment_date": "2025-11-09",
  "amount": 115.00,
  "payment_method": "credit_card",
  "reference": "TXN-98765",
  "created_at": "2025-11-09T10:30:00Z"
}
```

---

### Get Invoice

**GET** `/qoyod/invoices/:id`

Get invoice details by ID.

**Response:** Same as Create Invoice response

---

### Get Invoice PDF

**GET** `/qoyod/invoices/:id/pdf`

Download invoice as PDF file.

**Response:** Binary PDF file

---

### Get Invoice PDF URL

**GET** `/qoyod/invoices/:id/pdf-url`

Get the URL to download invoice PDF.

**Response:**

```json
{
  "pdf_url": "https://app.qoyod.com/invoices/inv_123456/pdf"
}
```

---

### List Invoices

**GET** `/qoyod/invoices`

List all invoices with optional filters.

**Query Parameters:**
- `page` - Page number (default: 1)
- `per_page` - Results per page (default: 20)
- `status` - Filter by status (draft, sent, paid, partial)
- `contact_id` - Filter by contact ID
- `from_date` - Filter by date range (YYYY-MM-DD)
- `to_date` - Filter by date range (YYYY-MM-DD)

**Response:**

```json
{
  "invoices": [...],
  "meta": {
    "current_page": 1,
    "total_pages": 5,
    "per_page": 20,
    "total_count": 98
  }
}
```

---

### Delete Invoice

**DELETE** `/qoyod/invoices/:id`

Delete an invoice.

**Response:**

```json
{
  "message": {
    "ar": "تم حذف الفاتورة بنجاح",
    "en": "Invoice deleted successfully"
  }
}
```

## Usage in Your Code

### Import the Service

```typescript
import { QoyodService } from './qoyod/services/qoyod.service';

@Injectable()
export class YourService {
  constructor(private readonly qoyodService: QoyodService) {}

  async createOrderInvoice(order: Order) {
    const invoice = await this.qoyodService.createInvoice({
      contact: {
        name: order.user.name,
        email: order.user.email,
        phone: order.user.phone,
      },
      invoice_date: new Date().toISOString().split('T')[0],
      items: order.items.map(item => ({
        description: item.description,
        quantity: item.quantity,
        unit_price: item.price,
        tax_percent: 15,
      })),
      reference: order.id,
      status: 'sent',
    });

    return invoice;
  }
}
```

## Payment Methods

The following payment methods are supported:

- `cash` - Cash payment
- `bank_transfer` - Bank transfer
- `credit_card` - Credit/debit card
- `cheque` - Cheque
- `other` - Other payment methods

## Invoice Statuses

- `draft` - Invoice is in draft mode
- `sent` - Invoice has been sent to customer
- `paid` - Invoice has been fully paid
- `partial` - Invoice has been partially paid

## Error Handling

The service includes comprehensive error handling with bilingual error messages (Arabic/English):

```typescript
try {
  const invoice = await this.qoyodService.createInvoice(data);
} catch (error) {
  // Error will be a NestJS exception with bilingual messages
  // BadRequestException, NotFoundException, or InternalServerErrorException
}
```

## Integration with Orders

You can easily integrate Qoyod with your existing orders module:

```typescript
@Injectable()
export class OrdersService {
  constructor(
    private readonly qoyodService: QoyodService,
  ) {}

  async completeOrder(orderId: string) {
    const order = await this.getOrderById(orderId);
    
    // Create invoice in Qoyod
    const invoice = await this.qoyodService.createInvoice({
      contact: {
        name: order.user.name,
        email: order.user.email,
        phone: order.user.phone,
      },
      invoice_date: new Date().toISOString().split('T')[0],
      reference: orderId,
      items: [{
        description: order.service.name,
        quantity: 1,
        unit_price: order.totalPay,
        tax_percent: 15,
      }],
      status: 'sent',
    });

    // Store invoice ID with order
    order.qoyodInvoiceId = invoice.id;
    await order.save();

    return invoice;
  }

  async recordOrderPayment(orderId: string, paymentData: any) {
    const order = await this.getOrderById(orderId);
    
    // Record payment in Qoyod
    const payment = await this.qoyodService.payInvoice({
      invoice_id: order.qoyodInvoiceId,
      payment_date: new Date().toISOString().split('T')[0],
      amount: paymentData.amount,
      payment_method: 'credit_card',
      reference: paymentData.transactionId,
    });

    return payment;
  }
}
```

## API Documentation

For complete Qoyod API documentation, visit:
https://apidoc.qoyod.com/

## Support

For issues or questions about this integration, please contact the development team.

