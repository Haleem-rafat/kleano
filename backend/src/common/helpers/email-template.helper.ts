import { LocalizedText } from '../types/localized-text.type';

export interface OrderDetailsData {
  orderId: string;
  orderNumber: string;
  customerName: string;
  customerPhone: string;
  customerEmail?: string;
  services: Array<{ name: LocalizedText; price: number }>;
  addOns?: Array<{ name: LocalizedText; price: number }>;
  vehicleDetails: string;
  locationAddress: string;
  bookingDate: string;
  timeSlot: string;
  totalPrice: number;
  discount?: number;
  totalPay: number;
  paymentStatus: string;
  paymentType: string;
  orderStatus: string;
  createdAt: string;
}

export interface InvoiceEmailData {
  invoiceNumber: string;
  customerName: string;
  invoiceDate: string;
  dueDate: string;
  totalAmount: number;
  pdfUrl: string;
}

export function InvoiceEmailTemplate(invoiceData: InvoiceEmailData): string {
  return `
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset="utf-8">
        <title>Invoice from Kleano</title>
      </head>
      <body style="font-family: Arial, sans-serif; margin: 0; padding: 0; background-color: #f4f4f4;">
        <div style="max-width: 600px; margin: 20px auto; background-color: #ffffff; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
          <!-- Header -->
          <div style="background-color: #4CAF50; padding: 30px; text-align: center;">
            <h1 style="color: #ffffff; margin: 0; font-size: 28px;">Kleano</h1>
            <p style="color: #ffffff; margin: 10px 0 0 0;">Your Invoice is Ready</p>
          </div>
          
          <!-- Content -->
          <div style="padding: 30px;">
            <p style="font-size: 16px; color: #333; margin-bottom: 20px;">
              Dear ${invoiceData.customerName},
            </p>
            
            <p style="font-size: 14px; color: #666; line-height: 1.6;">
              Thank you for choosing Kleano. Your invoice has been generated and is ready for download.
            </p>
            
            <!-- Invoice Details Box -->
            <div style="background-color: #f9f9f9; border-left: 4px solid #4CAF50; padding: 20px; margin: 20px 0; border-radius: 4px;">
              <h3 style="margin: 0 0 15px 0; color: #333;">Invoice Details</h3>
              <table style="width: 100%; border-collapse: collapse;">
                <tr>
                  <td style="padding: 8px 0; color: #666;">Invoice Number:</td>
                  <td style="padding: 8px 0; color: #333; font-weight: bold; text-align: right;">${
                    invoiceData.invoiceNumber
                  }</td>
                </tr>
                <tr>
                  <td style="padding: 8px 0; color: #666;">Issue Date:</td>
                  <td style="padding: 8px 0; color: #333; text-align: right;">${
                    invoiceData.invoiceDate
                  }</td>
                </tr>
                <tr>
                  <td style="padding: 8px 0; color: #666;">Due Date:</td>
                  <td style="padding: 8px 0; color: #333; text-align: right;">${
                    invoiceData.dueDate
                  }</td>
                </tr>
                <tr>
                  <td style="padding: 8px 0; color: #666; font-size: 16px; padding-top: 15px; border-top: 1px solid #ddd;">Total Amount:</td>
                  <td style="padding: 8px 0; color: #4CAF50; font-weight: bold; font-size: 20px; text-align: right; padding-top: 15px; border-top: 1px solid #ddd;">${
                    invoiceData.totalAmount
                  } SAR</td>
                </tr>
              </table>
            </div>
            
            <!-- Download Button -->
            <div style="text-align: center; margin: 30px 0;">
              <a href="${
                invoiceData.pdfUrl
              }" style="display: inline-block; background-color: #4CAF50; color: #ffffff; text-decoration: none; padding: 14px 30px; border-radius: 4px; font-weight: bold; font-size: 16px;">
                Download Invoice PDF
              </a>
            </div>
            
            <p style="font-size: 14px; color: #666; line-height: 1.6; margin-top: 30px;">
              If you have any questions about this invoice, please don't hesitate to contact us.
            </p>
          </div>
          
          <!-- Footer -->
          <div style="background-color: #f4f4f4; padding: 20px; text-align: center; border-top: 1px solid #ddd;">
            <p style="margin: 0; font-size: 12px; color: #999;">
              © ${new Date().getFullYear()} Kleano. All rights reserved.
            </p>
            <p style="margin: 10px 0 0 0; font-size: 12px; color: #999;">
              This is an automated email. Please do not reply.
            </p>
          </div>
        </div>
      </body>
    </html>
  `;
}

export function OrderDetailsEmailTemplate(orderData: OrderDetailsData): string {
  const servicesHtml = orderData.services
    .map(
      (service) => `
        <tr>
          <td style="padding: 8px; border-bottom: 1px solid #eee;">${service.name.en}</td>
          <td style="padding: 8px; border-bottom: 1px solid #eee; text-align: right;">${service.price} SAR</td>
        </tr>
      `,
    )
    .join('');

  const addOnsHtml = orderData.addOns?.length
    ? orderData.addOns
        .map(
          (addOn) => `
        <tr>
          <td style="padding: 8px; border-bottom: 1px solid #eee;">${addOn.name.en}</td>
          <td style="padding: 8px; border-bottom: 1px solid #eee; text-align: right;">${addOn.price} SAR</td>
        </tr>
      `,
        )
        .join('')
    : '';

  const discountHtml = orderData.discount
    ? `
      <tr>
        <td style="padding: 8px; font-weight: bold;">Discount:</td>
        <td style="padding: 8px; text-align: right; color: #e74c3c;">-${orderData.discount} SAR</td>
      </tr>
    `
    : '';

  return `
    <!DOCTYPE html>
    <html>
    <head>
      <title>New Order - KleanO</title>
      <meta charset="utf-8">
      <style>
        body {
          font-family: Arial, sans-serif;
          line-height: 1.6;
          color: #333;
          max-width: 800px;
          margin: 0 auto;
          padding: 20px;
          background-color: #f4f4f4;
        }
        .container {
          background-color: #ffffff;
          border-radius: 8px;
          padding: 30px;
          box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .header {
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          color: white;
          padding: 20px;
          border-radius: 8px 8px 0 0;
          margin: -30px -30px 20px -30px;
        }
        .header h1 {
          margin: 0;
          font-size: 24px;
        }
        .order-id {
          background-color: #f8f9fa;
          padding: 15px;
          border-left: 4px solid #667eea;
          margin-bottom: 20px;
        }
        .section {
          margin-bottom: 25px;
        }
        .section-title {
          font-size: 18px;
          font-weight: bold;
          color: #667eea;
          margin-bottom: 10px;
          border-bottom: 2px solid #667eea;
          padding-bottom: 5px;
        }
        .info-row {
          display: flex;
          justify-content: space-between;
          padding: 8px 0;
          border-bottom: 1px solid #eee;
        }
        .info-label {
          font-weight: bold;
          color: #555;
        }
        .info-value {
          color: #333;
        }
        table {
          width: 100%;
          border-collapse: collapse;
          margin-top: 10px;
        }
        .status-badge {
          display: inline-block;
          padding: 6px 12px;
          border-radius: 20px;
          font-size: 14px;
          font-weight: bold;
        }
        .status-paid {
          background-color: #d4edda;
          color: #155724;
        }
        .status-pending {
          background-color: #fff3cd;
          color: #856404;
        }
        .status-active {
          background-color: #cce5ff;
          color: #004085;
        }
        .total-row {
          font-size: 20px;
          font-weight: bold;
          color: #667eea;
        }
        .footer {
          margin-top: 30px;
          padding-top: 20px;
          border-top: 2px solid #eee;
          text-align: center;
          color: #777;
          font-size: 14px;
        }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>🚗 New Order Received - KleanO</h1>
        </div>

        <div class="order-id">
          <strong>Order ID:</strong> ${orderData.orderId}<br>
          <strong>Order Number:</strong> #${orderData.orderNumber}<br>
          <strong>Created:</strong> ${orderData.createdAt}
        </div>

        <div class="section">
          <div class="section-title">👤 Customer Information</div>
          <div class="info-row">
            <span class="info-label">Name:</span>
            <span class="info-value">${orderData.customerName}</span>
          </div>
          <div class="info-row">
            <span class="info-label">Phone:</span>
            <span class="info-value">${orderData.customerPhone}</span>
          </div>
          ${
            orderData.customerEmail
              ? `
          <div class="info-row">
            <span class="info-label">Email:</span>
            <span class="info-value">${orderData.customerEmail}</span>
          </div>
          `
              : ''
          }
        </div>

        <div class="section">
          <div class="section-title">🚙 Vehicle & Location</div>
          <div class="info-row">
            <span class="info-label">Vehicle:</span>
            <span class="info-value">${orderData.vehicleDetails}</span>
          </div>
          <div class="info-row">
            <span class="info-label">Location:</span>
            <span class="info-value">${orderData.locationAddress}</span>
          </div>
        </div>

        <div class="section">
          <div class="section-title">📅 Booking Details</div>
          <div class="info-row">
            <span class="info-label">Date:</span>
            <span class="info-value">${orderData.bookingDate}</span>
          </div>
          <div class="info-row">
            <span class="info-label">Time Slot:</span>
            <span class="info-value">${orderData.timeSlot}</span>
          </div>
        </div>

        <div class="section">
          <div class="section-title">🧼 Services & Add-ons</div>
          <table>
            ${servicesHtml}
            ${addOnsHtml}
            <tr>
              <td style="padding: 8px; font-weight: bold;">Subtotal:</td>
              <td style="padding: 8px; text-align: right; font-weight: bold;">${
                orderData.totalPrice
              } SAR</td>
            </tr>
            ${discountHtml}
            <tr class="total-row">
              <td style="padding: 12px;">Total Amount:</td>
              <td style="padding: 12px; text-align: right;">${
                orderData.totalPay
              } SAR</td>
            </tr>
          </table>
        </div>

        <div class="section">
          <div class="section-title">💳 Payment & Status</div>
          <div class="info-row">
            <span class="info-label">Payment Method:</span>
            <span class="info-value">${orderData.paymentType}</span>
          </div>
          <div class="info-row">
            <span class="info-label">Payment Status:</span>
            <span class="info-value">
              <span class="status-badge ${
                orderData.paymentStatus === 'PAID'
                  ? 'status-paid'
                  : 'status-pending'
              }">
                ${orderData.paymentStatus}
              </span>
            </span>
          </div>
          <div class="info-row">
            <span class="info-label">Order Status:</span>
            <span class="info-value">
              <span class="status-badge status-active">
                ${orderData.orderStatus}
              </span>
            </span>
          </div>
        </div>

        <div class="footer">
          <p>This is an automated notification from KleanO Admin System</p>
          <p style="font-size: 12px; color: #999;">
            Please do not reply to this email. For support, contact the development team.
          </p>
        </div>
      </div>
    </body>
    </html>
  `;
}
