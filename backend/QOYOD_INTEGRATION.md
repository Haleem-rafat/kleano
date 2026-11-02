# Qoyod API Integration - Quick Start Guide

This document provides a quick guide to using the Qoyod API integration in your Kleano backend.

## 📋 Overview

The Qoyod integration allows you to:
- ✅ Create invoices automatically when orders are completed
- ✅ Record payments for invoices
- ✅ Download invoices as PDF
- ✅ Retrieve invoice details
- ✅ List and filter invoices

## 🚀 Quick Setup

### 1. Add Environment Variables

Add these to your `.env` file:

```env
QOYOD_API_KEY=your_api_key_here
QOYOD_BASE_URL=https://api.qoyod.com/2.0
```

### 2. Get Your API Key

1. Login to [Qoyod](https://app.qoyod.com/)
2. Go to Settings → API Settings
3. Generate a new API key
4. Copy it to your `.env` file

See [src/qoyod/ENVIRONMENT_SETUP.md](src/qoyod/ENVIRONMENT_SETUP.md) for detailed instructions.

## 📚 API Endpoints

All endpoints are prefixed with `/qoyod`

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/qoyod/invoices` | Create a new invoice |
| POST | `/qoyod/payments` | Record a payment |
| GET | `/qoyod/invoices/:id` | Get invoice details |
| GET | `/qoyod/invoices/:id/pdf` | Download invoice PDF |
| GET | `/qoyod/invoices/:id/pdf-url` | Get PDF URL |
| GET | `/qoyod/invoices` | List invoices with filters |
| DELETE | `/qoyod/invoices/:id` | Delete an invoice |

## 💡 Usage Examples

### Example 1: Create Invoice

```bash
curl -X POST http://localhost:3000/qoyod/invoices \
  -H "Content-Type: application/json" \
  -d '{
    "contact": {
      "name": "Ahmed Ali",
      "email": "ahmed@example.com",
      "phone": "+966501234567"
    },
    "invoice_date": "2025-11-09",
    "due_date": "2025-11-16",
    "reference": "ORDER-12345",
    "items": [
      {
        "description": "Car Wash - Exterior & Interior",
        "quantity": 1,
        "unit_price": 150.00,
        "tax_percent": 15
      }
    ],
    "notes": "Thank you for choosing Kleano!",
    "status": "sent"
  }'
```

### Example 2: Record Payment

```bash
curl -X POST http://localhost:3000/qoyod/payments \
  -H "Content-Type: application/json" \
  -d '{
    "invoice_id": "inv_123456",
    "payment_date": "2025-11-09",
    "amount": 172.50,
    "payment_method": "credit_card",
    "reference": "TXN-98765"
  }'
```

### Example 3: Download Invoice PDF

```bash
curl -X GET http://localhost:3000/qoyod/invoices/inv_123456/pdf \
  --output invoice.pdf
```

## 🔧 Integration with Your Orders

### Step 1: Import the Service

In your `orders.service.ts`:

```typescript
import { QoyodService } from '../qoyod/services/qoyod.service';

@Injectable()
export class OrdersService {
  constructor(
    private readonly qoyodService: QoyodService,
    // ... other services
  ) {}
}
```

### Step 2: Create Invoice After Order

```typescript
async handleOrderCompletion(orderId: string) {
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
      unit_price: order.totalPay / 1.15, // Excluding VAT
      tax_percent: 15,
    }],
    status: 'sent',
  });
  
  // Save invoice ID to order
  order.qoyodInvoiceId = invoice.id;
  await order.save();
  
  return invoice;
}
```

### Step 3: Record Payment

```typescript
async handlePaymentSuccess(orderId: string, transactionId: string) {
  const order = await this.getOrderById(orderId);
  
  // Record payment in Qoyod
  if (order.qoyodInvoiceId) {
    await this.qoyodService.payInvoice({
      invoice_id: order.qoyodInvoiceId,
      payment_date: new Date().toISOString().split('T')[0],
      amount: order.totalPay,
      payment_method: 'credit_card',
      reference: transactionId,
    });
  }
}
```

## 📖 Complete Examples

See [src/qoyod/examples/integration-example.ts](src/qoyod/examples/integration-example.ts) for complete integration examples including:
- Creating invoices for orders
- Recording payments
- Generating PDFs
- Listing customer invoices
- Monthly revenue reports

## 📄 Request/Response Formats

### Create Invoice Request

```typescript
{
  contact: {
    name: string;
    email?: string;
    phone?: string;
    address?: string;
    tax_number?: string;
  };
  invoice_date: string; // YYYY-MM-DD
  due_date?: string; // YYYY-MM-DD
  reference?: string; // Your order ID
  currency?: string; // Default: SAR
  items: [
    {
      description: string;
      quantity: number;
      unit_price: number;
      tax_percent?: number; // Default: 0
      discount?: number;
      discount_type?: 'percentage' | 'fixed';
    }
  ];
  notes?: string;
  status?: 'draft' | 'sent' | 'paid' | 'partial';
}
```

### Invoice Response

```typescript
{
  id: string;
  invoice_number: string;
  reference: string;
  contact: {...};
  invoice_date: string;
  due_date: string;
  currency: string;
  subtotal: number;
  total_tax: number;
  total: number;
  amount_due: number;
  status: string;
  items: [...];
  pdf_url?: string;
  created_at: string;
  updated_at: string;
}
```

## 🔐 Security Best Practices

1. **Never commit API keys** - Keep them in `.env` file
2. **Use different keys** - Separate keys for dev/staging/production
3. **Rotate keys regularly** - Change API keys every 3-6 months
4. **Monitor usage** - Check Qoyod dashboard for unusual activity

## 🐛 Troubleshooting

### Error: "QOYOD_API_KEY must be set"
- Add `QOYOD_API_KEY` to your `.env` file
- Restart your server

### Error: "Authentication error"
- Verify your API key is correct
- Check if key has expired
- Ensure key has proper permissions

### Error: "Invoice not found"
- Verify the invoice ID is correct
- Check if invoice was deleted

## 📚 Documentation

- **Module Documentation**: [src/qoyod/README.md](src/qoyod/README.md)
- **Environment Setup**: [src/qoyod/ENVIRONMENT_SETUP.md](src/qoyod/ENVIRONMENT_SETUP.md)
- **Integration Examples**: [src/qoyod/examples/integration-example.ts](src/qoyod/examples/integration-example.ts)
- **Qoyod API Docs**: https://apidoc.qoyod.com/

## 🆘 Support

For issues with:
- **This integration**: Contact your development team
- **Qoyod API**: Visit https://www.qoyod.com/support or contact Qoyod support

## 🎯 Next Steps

1. Set up your API key in `.env`
2. Test with a simple invoice creation
3. Integrate with your order completion workflow
4. Add payment recording to your payment webhook
5. Enable PDF generation for customer receipts

Happy coding! 🚀

