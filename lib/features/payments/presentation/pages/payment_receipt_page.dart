import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'dart:typed_data';

class PaymentReceiptPage extends StatefulWidget {
  final String receiptNumber;
  final Map<String, dynamic> paymentData;
  final Map<String, dynamic>? productData;
  final Map<String, dynamic>? customerData;

  const PaymentReceiptPage({
    super.key,
    required this.receiptNumber,
    required this.paymentData,
    this.productData,
    this.customerData,
  });

  @override
  State<PaymentReceiptPage> createState() => _PaymentReceiptPageState();
}

class _PaymentReceiptPageState extends State<PaymentReceiptPage> {
  late DateTime paymentDate;
  late double paymentAmount;
  String? notes;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    paymentAmount = (widget.paymentData['payment_amount'] as num).toDouble();

    final dateString = widget.paymentData['payment_date'] as String?;
    paymentDate = dateString != null
        ? DateTime.parse(dateString)
        : DateTime.now();

    notes = widget.paymentData['notes'] as String?;
  }

  Future<Uint8List> _generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Payment Receipt - ايصال دفعة',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'Receipt Number: ${widget.receiptNumber}',
                      style: const pw.TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 30),
              pw.Divider(),
              pw.SizedBox(height: 20),

              // Customer Info
              if (widget.customerData != null) ...[
                pw.Text(
                  'Customer Info:',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Name: ${widget.customerData!['customer_name']}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                if (widget.customerData!['phone_number'] != null)
                  pw.Text(
                    'Phone: ${widget.customerData!['phone_number']}',
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                pw.SizedBox(height: 20),
              ],

              // Product Info
              if (widget.productData != null) ...[
                pw.Text(
                  'Product Info:',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Product: ${widget.productData!['product_name']}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.Text(
                  'Final Price: ${(widget.productData!['final_price'] as num).toStringAsFixed(0)} SAR',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.SizedBox(height: 20),
              ],

              // Payment Info
              pw.Text(
                'Payment Details:',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),

              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(8),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Amount Paid:'),
                        pw.Text(
                          '${paymentAmount.toStringAsFixed(0)} SAR',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 5),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Payment Date:'),
                        pw.Text(
                          '${paymentDate.day}/${paymentDate.month}/${paymentDate.year}',
                        ),
                      ],
                    ),
                    if (notes != null && notes!.isNotEmpty) ...[
                      pw.SizedBox(height: 5),
                      pw.Text('Notes: $notes'),
                    ],
                  ],
                ),
              ),

              pw.Spacer(),

              // Footer
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Divider(),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'Generated on: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                    pw.Text(
                      'Thank You',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<void> _printReceipt() async {
    try {
      final pdfData = await _generatePdf();
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfData,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في الطباعة: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _shareReceiptAsPdf() async {
    try {
      final pdfData = await _generatePdf();
      await Printing.sharePdf(
        bytes: pdfData,
        filename: 'receipt_${widget.receiptNumber}.pdf',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في المشاركة: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _shareReceiptAsImage() async {
    try {
      final pdfData = await _generatePdf();
      final images = await Printing.raster(pdfData, pages: [0], dpi: 300);

      await for (final image in images) {
        final bytes = await image.toPng();
        await Share.shareXFiles([
          XFile.fromData(
            bytes,
            name: 'receipt_${widget.receiptNumber}.png',
            mimeType: 'image/png',
          ),
        ], text: 'إيصال دفعة رقم: ${widget.receiptNumber}');
        break; // Only share the first page
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في مشاركة الصورة: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إيصال الدفعة'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'إيصال دفعة',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'رقم الإيصال: ${widget.receiptNumber}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Customer Info
            if (widget.customerData != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.person, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'بيانات العميل',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'الاسم: ${widget.customerData!['customer_name']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      if (widget.customerData!['phone_number'] != null)
                        Text(
                          'الهاتف: ${widget.customerData!['phone_number']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Product Info
            if (widget.productData != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.shopping_bag, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'بيانات المنتج',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'اسم المنتج: ${widget.productData!['product_name']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'السعر النهائي: ${(widget.productData!['final_price'] as num).toStringAsFixed(0)} ريال',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Payment Info
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.payment, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          'بيانات الدفعة',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'مبلغ الدفعة:',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                '${paymentAmount.toStringAsFixed(0)} ريال',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'تاريخ الدفع:',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                '${paymentDate.day}/${paymentDate.month}/${paymentDate.year}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          if (notes != null && notes!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'ملاحظات:',
                                  style: TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    notes!,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: _printReceipt,
                  icon: const Icon(Icons.print),
                  label: const Text('طباعة الإيصال'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),

                const SizedBox(height: 12),

                ElevatedButton.icon(
                  onPressed: _shareReceiptAsPdf,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('مشاركة كـ PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),

                const SizedBox(height: 12),

                ElevatedButton.icon(
                  onPressed: _shareReceiptAsImage,
                  icon: const Icon(Icons.image),
                  label: const Text('مشاركة كصورة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Footer
            Center(
              child: Column(
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'تم إنشاء هذا الإيصال بتاريخ: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'شكراً لك',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
