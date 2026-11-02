import { Body, Controller, Get, Param, Post, Query } from '@nestjs/common';
import { CreateInvoiceDto } from '../dtos/create-invoice.dto';
import { PayInvoiceDto } from '../dtos/pay-invoice.dto';
import { InvoicesQoyodService } from '../services/invoices-qoyod.service';

/**
 * Qoyod Controller
 * Handles invoice creation, payment processing, and PDF generation via Qoyod API
 */
@Controller('qoyod')
export class QoyodController {
  constructor(private readonly invoicesQoyodService: InvoicesQoyodService) {}

  /**
   * Create a new invoice in Qoyod
   * POST /qoyod/invoices
   */
  @Post('invoices')
  async createInvoice(@Body() createInvoiceDto: CreateInvoiceDto) {
    return await this.invoicesQoyodService.createInvoice(createInvoiceDto);
  }

  /**
   * Record a payment for an invoice
   * POST /qoyod/payments
   */
  @Post('payments')
  async payInvoice(@Body() payInvoiceDto: PayInvoiceDto) {
    return await this.invoicesQoyodService.payInvoice(payInvoiceDto);
  }

  /**
   * Get invoice details by ID
   * GET /qoyod/invoices/:id
   */
  @Get('invoices/:id')
  async getInvoice(@Param('id') id: string) {
    return await this.invoicesQoyodService.getInvoice(id);
  }

  /**
   * Get invoice PDF URL
   * GET /qoyod/invoices/:id/pdf
   * Returns a JSON object with pdf_file URL and expire_at timestamp
   */
  @Get('invoices/:id/pdf')
  async getInvoicePdf(@Param('id') id: string) {
    return await this.invoicesQoyodService.getInvoicePdf(id);
  }

  /**
   * List all invoices with optional filters
   * GET /qoyod/invoices
   */
  @Get('invoices')
  async listInvoices(
    @Query('page') page?: number,
    @Query('per_page') perPage?: number,
    @Query('status') status?: string,
    @Query('contact_id') contactId?: string,
    @Query('from_date') fromDate?: string,
    @Query('to_date') toDate?: string,
  ) {
    return await this.invoicesQoyodService.listInvoices({
      page,
      per_page: perPage,
      status,
      contact_id: contactId,
      from_date: fromDate,
      to_date: toDate,
    });
  }
}
