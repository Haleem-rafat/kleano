# Qoyod Environment Setup

## Required Environment Variables

Add these environment variables to your `.env` file:

```env
# Qoyod Accounting Integration
QOYOD_API_KEY=your_qoyod_api_key_here
QOYOD_BASE_URL=https://api.qoyod.com/2.0
```

## Getting Your Qoyod API Key

1. **Login to Qoyod**
   - Go to https://app.qoyod.com/
   - Log in with your account credentials

2. **Navigate to API Settings**
   - Click on Settings (الإعدادات)
   - Find the "API" or "API Settings" section
   - Or go directly to: https://app.qoyod.com/settings/api

3. **Generate API Key**
   - Click on "Generate New API Key" or "إنشاء مفتاح API جديد"
   - Copy the generated API key (you will only see it once!)
   - Store it securely in your `.env` file

4. **Configure Permissions**
   - Make sure the API key has the following permissions:
     - Read Invoices
     - Create Invoices
     - Update Invoices
     - Delete Invoices
     - Read Payments
     - Create Payments

## Testing the Integration

After setting up the environment variables, you can test the integration:

1. **Start your server:**
   ```bash
   npm run start:dev
   ```

2. **Test with a simple request:**
   ```bash
   curl -X POST http://localhost:3000/qoyod/invoices \
     -H "Content-Type: application/json" \
     -d '{
       "contact": {
         "name": "Test Customer",
         "email": "test@example.com"
       },
       "invoice_date": "2025-11-09",
       "items": [{
         "description": "Test Service",
         "quantity": 1,
         "unit_price": 100
       }]
     }'
   ```

## Base URL Options

Depending on your Qoyod account type, you may need to use different base URLs:

- **Production:** `https://api.qoyod.com/2.0`
- **Sandbox/Testing:** (Contact Qoyod support for sandbox access)

## Troubleshooting

### Error: "QOYOD_API_KEY must be set in environment variables"
- Make sure you have added `QOYOD_API_KEY` to your `.env` file
- Restart your server after updating environment variables

### Error: "Authentication error with Qoyod"
- Verify your API key is correct
- Check if your API key has expired
- Ensure the API key has the required permissions

### Error: "Error communicating with Qoyod"
- Check your internet connection
- Verify the `QOYOD_BASE_URL` is correct
- Check if Qoyod API is accessible from your server

## Security Notes

- **Never commit your API key to version control**
- Keep your `.env` file in `.gitignore`
- Use different API keys for development and production
- Rotate your API keys regularly
- Monitor API key usage in Qoyod dashboard

## Rate Limiting

Qoyod API has rate limits. Default limits are:
- 1000 requests per hour per API key

If you exceed the rate limit, you'll receive a 429 error. Implement retry logic with exponential backoff if needed.

