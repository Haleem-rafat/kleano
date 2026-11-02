import { HttpService } from '@nestjs/axios';
import {
  BadRequestException,
  Injectable,
  InternalServerErrorException,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { OnEvent } from '@nestjs/event-emitter';
import { catchError, firstValueFrom, map } from 'rxjs';
import { AddOns } from 'src/add-ons/schemas/add-ons.schema';
import { EmailService } from 'src/common/services/email.service';
import { OrdersRepository } from 'src/orders/repositories/orders.repository';
import { WashingService } from 'src/washing-services/schemas/washing-services.schema';
import {
  CreateCreditNoteDto,
  CreditNoteLineItemDto,
} from '../dtos/create-credit-note.dto';
import { CreateInvoiceDto, LineItemDto } from '../dtos/create-invoice.dto';
import { PayInvoiceDto } from '../dtos/pay-invoice.dto';
import { CustomersQoyodService } from './customers-qoyod.service';

function roundMoney(value: number): number {
  return Math.round(value * 100) / 100;
}

@Injectable()
export class InvoicesQoyodService {
  private readonly logger = new Logger(InvoicesQoyodService.name);
  private readonly apiKey: string;
  private readonly baseUrl: string;

  constructor(
    private readonly httpService: HttpService,
    private readonly ordersRepository: OrdersRepository,
    private readonly emailService: EmailService,
    private readonly customersQoyodService: CustomersQoyodService,
  ) {
    this.apiKey = process.env.QOYOD_API_KEY;
    this.baseUrl = process.env.QOYOD_BASE_URL || 'https://api.qoyod.com/2.0';

    if (!this.apiKey) {
      this.logger.error('QOYOD_API_KEY is not configured');
      throw new Error('QOYOD_API_KEY must be set in environment variables');
    }
  }

  /**
   * Get default headers for Qoyod API requests
   */
  private getHeaders() {
    // Try different authentication header formats
    // Qoyod might use 'api-key', 'API-KEY', 'x-api-key', or 'Authorization'
    const headers = {
      'Content-Type': 'application/json',
      'API-KEY': this.apiKey,
    };
    this.logger.debug(
      `Request headers (API key hidden): ${JSON.stringify({
        ...headers,
        'api-key': '***',
      })}`,
    );
    return headers;
  }

  /**
   * Create a new invoice in Qoyod
   * @param createInvoiceDto - Invoice details
   * @returns Created invoice response
   */
  async createInvoice(createInvoiceDto: CreateInvoiceDto) {
    try {
      this.logger.log('Creating invoice in Qoyod');

      const invoiceData = {
        invoice: {
          contact_id: createInvoiceDto.contact_id,
          reference: createInvoiceDto.reference,
          description: createInvoiceDto.description,
          issue_date: createInvoiceDto.issue_date,
          due_date: createInvoiceDto.due_date,
          status: createInvoiceDto.status || 'Approved',
          inventory_id: createInvoiceDto.inventory_id,
          line_items: createInvoiceDto.line_items,
          notes: createInvoiceDto.notes,
        },
      };

      this.logger.debug(
        `Request body: ${JSON.stringify(invoiceData, null, 2)}`,
      );

      const response = await firstValueFrom(
        this.httpService
          .post(`${this.baseUrl}/invoices`, invoiceData, {
            headers: this.getHeaders(),
          })
          .pipe(
            map((res) => res.data),
            catchError((error) => {
              this.logger.error(
                `Failed to create invoice: ${
                  error.response?.data?.message || error.message
                }`,
              );
              this.logger.error(`Response status: ${error.response?.status}`);
              this.logger.error(
                `Response data: ${JSON.stringify(error.response?.data)}`,
              );
              this.logger.error(`Request URL: ${this.baseUrl}/invoices`);
              throw this.handleApiError(error);
            }),
          ),
      );

      this.logger.log(
        `Invoice created successfully. Response: ${JSON.stringify(response)}`,
      );

      // Extract invoice ID from response (Qoyod returns it in response.invoice.id)
      const invoiceId = response?.invoice?.id || response?.id || null;

      return {
        ...response,
        id: invoiceId,
      };
    } catch (error) {
      if (
        error instanceof BadRequestException ||
        error instanceof InternalServerErrorException
      ) {
        throw error;
      }
      this.logger.error(`Unexpected error creating invoice: ${error.message}`);
      throw new InternalServerErrorException({
        ar: 'فشل في إنشاء الفاتورة',
        en: 'Failed to create invoice',
      });
    }
  }

  /**
   * Record a payment for an invoice
   * @param payInvoiceDto - Payment details
   * @returns Payment response
   */
  async payInvoice(payInvoiceDto: PayInvoiceDto) {
    try {
      this.logger.log(
        `Recording payment for invoice: ${payInvoiceDto.invoice_id}`,
      );

      const paymentData = {
        invoice_payment: {
          invoice_id: payInvoiceDto.invoice_id,
          date: payInvoiceDto.date,
          amount: payInvoiceDto.amount,
          reference: payInvoiceDto.reference,
          account_id: payInvoiceDto.account_id,
        },
      };

      const response = await firstValueFrom(
        this.httpService
          .post(`${this.baseUrl}/invoice_payments`, paymentData, {
            headers: this.getHeaders(),
          })
          .pipe(
            map((res) => res.data),
            catchError((error) => {
              this.logger.error(
                `Failed to record payment: ${
                  error.response?.data?.message || error.message
                }`,
              );
              this.logger.error(`Response status: ${error.response?.status}`);
              this.logger.error(
                `Response data: ${JSON.stringify(error.response?.data)}`,
              );
              this.logger.error(`Request body: ${JSON.stringify(paymentData)}`);
              throw this.handleApiError(error);
            }),
          ),
      );

      this.logger.log(`Payment recorded successfully: ${response.id}`);
      return response;
    } catch (error) {
      if (
        error instanceof BadRequestException ||
        error instanceof NotFoundException ||
        error instanceof InternalServerErrorException
      ) {
        throw error;
      }
      this.logger.error(`Unexpected error recording payment: ${error.message}`);
      throw new InternalServerErrorException({
        ar: 'فشل في تسجيل الدفع',
        en: 'Failed to record payment',
      });
    }
  }

  /**
   * Get invoice details by ID
   * @param invoiceId - Invoice ID
   * @returns Invoice details
   */
  async getInvoice(invoiceId: string) {
    try {
      this.logger.log(`Fetching invoice: ${invoiceId}`);

      const response = await firstValueFrom(
        this.httpService
          .get(`${this.baseUrl}/invoices/${invoiceId}`, {
            headers: this.getHeaders(),
          })
          .pipe(
            map((res) => res.data),
            catchError((error) => {
              this.logger.error(
                `Failed to fetch invoice: ${
                  error.response?.data?.message || error.message
                }`,
              );
              throw this.handleApiError(error);
            }),
          ),
      );

      this.logger.log(`Invoice fetched successfully: ${invoiceId}`);
      return response;
    } catch (error) {
      if (
        error instanceof NotFoundException ||
        error instanceof InternalServerErrorException
      ) {
        throw error;
      }
      this.logger.error(`Unexpected error fetching invoice: ${error.message}`);
      throw new InternalServerErrorException({
        ar: 'فشل في جلب الفاتورة',
        en: 'Failed to fetch invoice',
      });
    }
  }

  /**
   * Get invoice as PDF
   * @param invoiceId - Invoice ID
   * @returns PDF URL and expiration date
   */
  async getInvoicePdf(invoiceId: string) {
    try {
      this.logger.log(`Fetching invoice PDF: ${invoiceId}`);

      const response = await firstValueFrom(
        this.httpService
          .get(`${this.baseUrl}/invoices/${invoiceId}/pdf`, {
            headers: this.getHeaders(),
          })
          .pipe(
            map((res) => res.data),
            catchError((error) => {
              this.logger.error(
                `Failed to fetch invoice PDF: ${
                  error.response?.data?.message || error.message
                }`,
              );
              throw this.handleApiError(error);
            }),
          ),
      );

      this.logger.log(`Invoice PDF fetched successfully: ${invoiceId}`);
      return response;
    } catch (error) {
      if (
        error instanceof NotFoundException ||
        error instanceof InternalServerErrorException
      ) {
        throw error;
      }
      this.logger.error(
        `Unexpected error fetching invoice PDF: ${error.message}`,
      );
      throw new InternalServerErrorException({
        ar: 'فشل في جلب ملف PDF للفاتورة',
        en: 'Failed to fetch invoice PDF',
      });
    }
  }

  /**
   * List all invoices with optional filters
   * @param params - Query parameters (page, per_page, status, etc.)
   * @returns List of invoices
   */
  async listInvoices(params?: {
    page?: number;
    per_page?: number;
    status?: string;
    contact_id?: string;
    from_date?: string;
    to_date?: string;
  }) {
    try {
      this.logger.log('Fetching invoices list');

      const queryParams = new URLSearchParams();
      if (params) {
        Object.entries(params).forEach(([key, value]) => {
          if (value !== undefined && value !== null) {
            queryParams.append(key, value.toString());
          }
        });
      }

      const url = `${this.baseUrl}/invoices${
        queryParams.toString() ? `?${queryParams.toString()}` : ''
      }`;

      const response = await firstValueFrom(
        this.httpService
          .get(url, {
            headers: this.getHeaders(),
          })
          .pipe(
            map((res) => res.data),
            catchError((error) => {
              this.logger.error(
                `Failed to fetch invoices: ${
                  error.response?.data?.message || error.message
                }`,
              );
              throw this.handleApiError(error);
            }),
          ),
      );

      this.logger.log('Invoices list fetched successfully');
      return response;
    } catch (error) {
      if (error instanceof InternalServerErrorException) {
        throw error;
      }
      this.logger.error(`Unexpected error fetching invoices: ${error.message}`);
      throw new InternalServerErrorException({
        ar: 'فشل في جلب قائمة الفواتير',
        en: 'Failed to fetch invoices list',
      });
    }
  }

  /**
   * Create a credit note in Qoyod (customer return / refund). Uses `contact_id` (= User.qoyodCustomerId).
   * @see https://apidoc.qoyod.com/ — Credit Notes
   */
  async createCreditNote(createCreditNoteDto: CreateCreditNoteDto) {
    try {
      this.logger.log(
        `Creating credit note for contact_id: ${createCreditNoteDto.contact_id}`,
      );

      const creditNoteData = {
        credit_note: {
          contact_id: createCreditNoteDto.contact_id,
          ...(createCreditNoteDto.reference != null && {
            reference: createCreditNoteDto.reference,
          }),
          issue_date: createCreditNoteDto.issue_date,
          status: createCreditNoteDto.status || 'Approved',
          inventory_id: createCreditNoteDto.inventory_id,
          terms_conditions: createCreditNoteDto.terms_conditions ?? '',
          notes: createCreditNoteDto.notes ?? '',
          line_items: createCreditNoteDto.line_items.map((line) =>
            this.serializeCreditNoteLineForApi(line),
          ),
        },
      };

      this.logger.debug(
        `Request body: ${JSON.stringify(creditNoteData, null, 2)}`,
      );

      const response = await firstValueFrom(
        this.httpService
          .post(`${this.baseUrl}/credit_notes`, creditNoteData, {
            headers: this.getHeaders(),
          })
          .pipe(
            map((res) => res.data),
            catchError((error) => {
              this.logger.error(
                `Failed to create credit note: ${
                  error.response?.data?.message || error.message
                }`,
              );
              this.logger.error(`Response status: ${error.response?.status}`);
              this.logger.error(
                `Response data: ${JSON.stringify(error.response?.data)}`,
              );
              this.logger.error(`Request URL: ${this.baseUrl}/credit_notes`);
              throw this.handleApiError(error, {
                notFoundAr: 'الإشعار الدائن أو جهة الاتصال غير موجودة',
                notFoundEn: 'Credit note or customer not found',
              });
            }),
          ),
      );

      this.logger.log(
        `Credit note created successfully. Response: ${JSON.stringify(
          response,
        )}`,
      );

      const creditNoteId = response?.credit_note?.id || response?.id || null;

      return {
        ...response,
        id: creditNoteId,
      };
    } catch (error) {
      if (
        error instanceof BadRequestException ||
        error instanceof InternalServerErrorException ||
        error instanceof NotFoundException
      ) {
        throw error;
      }
      this.logger.error(
        `Unexpected error creating credit note: ${error.message}`,
      );
      throw new InternalServerErrorException({
        ar: 'فشل في إنشاء الإشعار الدائن',
        en: 'Failed to create credit note',
      });
    }
  }

  /**
   * Handle API errors and convert them to NestJS exceptions
   */
  private handleApiError(
    error: any,
    notFoundLabels?: { notFoundAr: string; notFoundEn: string },
  ): Error {
    const status = error.response?.status;
    const message = error.response?.data?.message || error.message;
    const details = error.response?.data?.details;

    switch (status) {
      case 400:
        return new BadRequestException({
          ar: 'طلب غير صحيح',
          en: message || 'Bad request',
          details,
        });
      case 404:
        return new NotFoundException({
          ar: notFoundLabels?.notFoundAr ?? 'الفاتورة غير موجودة',
          en: message || notFoundLabels?.notFoundEn || 'Invoice not found',
          details,
        });
      case 401:
      case 403:
        return new InternalServerErrorException({
          ar: 'خطأ في المصادقة مع Qoyod',
          en: 'Authentication error with Qoyod',
          details,
        });
      default:
        return new InternalServerErrorException({
          ar: 'خطأ في الاتصال بـ Qoyod',
          en: message || 'Error communicating with Qoyod',
          details,
        });
    }
  }

  /**
   * Serializes credit note lines to shapes accepted by Qoyod (often string decimals).
   */
  private serializeCreditNoteLineForApi(
    line: CreditNoteLineItemDto,
  ): Record<string, unknown> {
    const row: Record<string, unknown> = {
      product_id: line.product_id,
      unit_price: String(line.unit_price),
      quantity: String(line.quantity),
    };

    if (line.description !== undefined && line.description !== '') {
      row.description = line.description;
    }

    if (line.unit_type != null) {
      row.unit_type = line.unit_type;
    }

    if (line.tax_percent != null) {
      row.tax_percent = String(line.tax_percent);
    }

    if (line.discount != null && line.discount > 0) {
      row.discount = String(line.discount);
      row.discount_type = line.discount_type ?? 'amount';
    } else {
      row.discount_percent =
        line.discount_percent != null ? String(line.discount_percent) : '0.0';
    }

    if (line.custom_fields?.length) {
      row.custom_fields = line.custom_fields;
    }

    return row;
  }

  /**
   * Same proportional allocation as PaymentService for invoice line items.
   */
  private distributeDiscountAcrossItems(
    items: Array<{
      product_id: number;
      quantity: number;
      unit_price: number;
    }>,
    totalDiscount: number,
  ): Array<{
    product_id: number;
    quantity: number;
    unit_price: number;
    discount: number;
  }> {
    if (totalDiscount <= 0 || items.length === 0) {
      return items.map((item) => ({ ...item, discount: 0 }));
    }

    const totalAmount = items.reduce(
      (sum, item) => sum + item.quantity * item.unit_price,
      0,
    );

    if (totalAmount <= 0) {
      return items.map((item) => ({ ...item, discount: 0 }));
    }

    let remainingDiscount = totalDiscount;
    const itemsWithDiscount = items.map((item, index) => {
      const itemTotal = item.quantity * item.unit_price;
      let itemDiscount: number;

      if (index === items.length - 1) {
        itemDiscount = remainingDiscount;
      } else {
        itemDiscount = (itemTotal / totalAmount) * totalDiscount;
      }

      itemDiscount = Math.min(itemDiscount, itemTotal);
      itemDiscount = Math.round(itemDiscount * 100) / 100;

      remainingDiscount -= itemDiscount;

      return {
        ...item,
        discount: itemDiscount,
      };
    });

    return itemsWithDiscount;
  }

  @OnEvent('order.created')
  async createInvoiceFromOrder({
    orderId,
    userId,
    orderItems,
  }: {
    orderId: string;
    userId: string;
    orderItems: LineItemDto[];
  }) {
    try {
      // Creates the Qoyod customer if it failed at sign-up or no longer exists
      const qoyodCustomerId =
        await this.customersQoyodService.ensureCustomerForUser(userId);

      const invoice = await this.createInvoice({
        contact_id: Number(qoyodCustomerId),
        issue_date: new Date().toISOString().split('T')[0],
        due_date: new Date(new Date().setDate(new Date().getDate() + 10))
          .toISOString()
          .split('T')[0],
        status: 'Approved',
        inventory_id: 1,
        line_items: orderItems.map((item) => ({
          product_id: item.product_id,
          quantity: item.quantity,
          unit_price: item.unit_price,
          is_inclusive: true,
          discount_type: 'amount',
          discount: item.discount || 0,
        })),
      });

      await this.ordersRepository.update(orderId, {
        qoyodInvoiceId: invoice.id,
      });

      // Extract invoice data from nested response structure
      const invoiceData = invoice.invoice || invoice;

      // Convert invoice.total to number if it's a string
      const totalAmount =
        typeof invoiceData.total === 'string'
          ? parseFloat(invoiceData.total)
          : invoiceData.total || invoice.total;

      await this.payInvoice({
        invoice_id: invoice.id?.toString() || String(invoice.id),
        date: new Date().toISOString().split('T')[0],
        amount: totalAmount,
        reference: invoiceData.reference || invoice.reference,
        account_id: qoyodCustomerId.toString(),
      });

      this.logger.log(`Invoice paid successfully: ${invoice.id}`);

      // Get the order with user information
      const order = await this.ordersRepository.findOrderByIdOr404(orderId);
      await order.populate('user', 'userName email');

      // Get invoice PDF
      if (order.user && (order.user as any).email) {
        try {
          const invoicePdf = await this.getInvoicePdf(invoice.id.toString());

          // Send email to user with invoice PDF
          await this.emailService.sendEmail('INVOICE_CREATED', {
            invoiceData: {
              invoiceNumber:
                invoiceData.reference ||
                invoice.reference ||
                `INV-${invoice.id}`,
              customerName: (order.user as any).userName || 'Customer',
              invoiceDate:
                invoiceData.issue_date ||
                invoice.issue_date ||
                new Date().toISOString().split('T')[0],
              dueDate:
                invoiceData.due_date ||
                invoice.due_date ||
                new Date().toISOString().split('T')[0],
              totalAmount:
                totalAmount || invoiceData.total || invoice.total || 0,
              pdfUrl: invoicePdf.pdf_file || invoicePdf.pdf_url || '#',
            },
            email: (order.user as any).email,
            senderName: 'Kleano',
            subject: `Your Kleano Invoice - ${
              invoiceData.reference || invoice.reference || invoice.id
            }`,
          });

          this.logger.log(
            `Invoice email sent successfully to ${(order.user as any).email}`,
          );
        } catch (emailError) {
          this.logger.error(
            `Failed to send invoice email: ${emailError.message}`,
          );
          // Don't throw - we don't want to break the invoice creation if email fails
        }
      }
    } catch (error) {
      this.logger.error(`Error creating invoice from order: ${error.message}`);
    }
  }

  /**
   * Mirrors createInvoiceFromOrder line items; scales by refund ratio when the refund is partial.
   */
  @OnEvent('order.cancelled')
  async createCreditNoteFromOrder(payload: {
    orderId: string;
    /** Passed when emitting from Moyasar refund success (before order.save in some flows). */
    refundAmount?: number;
  }) {
    try {
      if (process.env.NODE_ENV !== 'prod') {
        return;
      }

      const { orderId } = payload;

      const order = await this.ordersRepository.findOrderByIdPopulatedOr404(
        orderId,
      );

      await order.populate({
        path: 'user',
        select: 'qoyodCustomerId',
      });

      const qoyodCustomerId = (
        order.user as { qoyodCustomerId?: number | null }
      )?.qoyodCustomerId;

      if (qoyodCustomerId == null) {
        this.logger.debug(
          `Skipping Qoyod credit note: no qoyodCustomerId for order ${orderId}`,
        );
        return;
      }

      const refundAmount = payload.refundAmount ?? order.refundAmount ?? 0;
      const totalPay = order.totalPay ?? 0;

      if (refundAmount <= 0 || totalPay <= 0) {
        this.logger.debug(
          `Skipping Qoyod credit note: no refund recorded for order ${orderId}`,
        );
        return;
      }

      const creditRatio = Math.min(refundAmount / totalPay, 1);

      const washingServices = order.washingServices as WashingService[];
      const addOnsArr = order.addOns as AddOns[];

      const orderItems = (washingServices || []).map((service) => ({
        product_id: Number(service.qoyodProductId),
        quantity: 1,
        unit_price: roundMoney(service.price * creditRatio),
      }));

      const addOnsItems = (addOnsArr || []).map((addOn) => ({
        product_id: Number(addOn.qoyodProductId),
        quantity: 1,
        unit_price: roundMoney(addOn.price * creditRatio),
      }));

      const allItems = [...orderItems, ...addOnsItems];

      if (allItems.length === 0) {
        this.logger.warn(
          `Skipping Qoyod credit note: no line items for order ${orderId}`,
        );
        return;
      }

      const itemsWithDiscount = this.distributeDiscountAcrossItems(
        allItems,
        roundMoney((order.discount || 0) * creditRatio),
      );

      const line_items: CreditNoteLineItemDto[] = itemsWithDiscount.map(
        (item) => ({
          product_id: item.product_id,
          quantity: item.quantity,
          unit_price: item.unit_price,
          description: 'استرجاع',
          ...(item.discount > 0 && {
            discount: item.discount,
            discount_type: 'amount' as const,
          }),
        }),
      );

      await this.createCreditNote({
        contact_id: Number(qoyodCustomerId),
        reference: `REFUND-${orderId}`,
        notes:
          creditRatio < 1
            ? `Partial refund (${Math.round(creditRatio * 100)}% of order)`
            : 'Order cancelled — refund',
        issue_date: new Date().toISOString().split('T')[0],
        inventory_id: 1,
        status: 'Approved',
        line_items,
      });

      this.logger.log(
        `Qoyod credit note created for cancelled order ${orderId}`,
      );
    } catch (error) {
      this.logger.error(
        `Error creating credit note from order: ${error.message}`,
      );
    }
  }
}
