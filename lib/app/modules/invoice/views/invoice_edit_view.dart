// ============ modules/invoice/views/invoice_edit_view.dart ============
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/invoice_controller.dart';
import 'invoice_create_view.dart';

class InvoiceEditView extends GetView<InvoiceController> {
  const InvoiceEditView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Nota'),
      ),
      body: const InvoiceCreateView(), // Reuse same form
    );
  }
}