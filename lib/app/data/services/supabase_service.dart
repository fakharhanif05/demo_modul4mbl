// ============ supabase_service.dart ============
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/invoice_model.dart';
import '../models/user_model.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  // Auth
  static User? get currentUser => client.auth.currentUser;
  
  static bool get isLoggedIn => currentUser != null;

  static Future<UserModel?> signIn(String email, String password) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        final user = response.user!;
        return UserModel(
          id: user.id,
          email: user.email!,
          createdAt: DateTime.parse(user.createdAt),
        );
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  static Future<UserModel?> signUp(String email, String password) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        final user = response.user!;
        return UserModel(
          id: user.id,
          email: user.email!,
          createdAt: DateTime.parse(user.createdAt),
        );
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  // Invoices CRUD
  static Future<String> createInvoice(InvoiceModel invoice) async {
    try {
      // Insert invoice
      final invoiceData = await client
          .from('invoices')
          .insert(invoice.toSupabase())
          .select()
          .single();

      final invoiceId = invoiceData['id'].toString();

      // Insert invoice items
      final items = invoice.items.map((item) {
        return {
          'invoice_id': invoiceId,
          ...item.toJson(),
        };
      }).toList();

      await client.from('invoice_items').insert(items);

      return invoiceId;
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<InvoiceModel>> getInvoices() async {
    try {
      final data = await client
          .from('invoices')
          .select('*, invoice_items(*)')
          .eq('user_id', currentUser!.id)
          .order('created_at', ascending: false);

      return data.map((json) {
        final items = (json['invoice_items'] as List)
            .map((item) => InvoiceItem.fromJson(item))
            .toList();
        
        return InvoiceModel.fromJson({
          ...json,
          'items': items,
        });
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<InvoiceModel> getInvoiceById(String id) async {
    try {
      final data = await client
          .from('invoices')
          .select('*, invoice_items(*)')
          .eq('id', id)
          .single();

      final items = (data['invoice_items'] as List)
          .map((item) => InvoiceItem.fromJson(item))
          .toList();

      return InvoiceModel.fromJson({
        ...data,
        'items': items,
      });
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateInvoice(String id, InvoiceModel invoice) async {
    try {
      // Update invoice
      await client
          .from('invoices')
          .update(invoice.toSupabase())
          .eq('id', id);

      // Delete old items
      await client.from('invoice_items').delete().eq('invoice_id', id);

      // Insert new items
      final items = invoice.items.map((item) {
        return {
          'invoice_id': id,
          ...item.toJson(),
        };
      }).toList();

      await client.from('invoice_items').insert(items);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteInvoice(String id) async {
    try {
      // Delete items first (cascade)
      await client.from('invoice_items').delete().eq('invoice_id', id);
      
      // Delete invoice
      await client.from('invoices').delete().eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

  // Sync
  static Future<void> syncInvoices(List<InvoiceModel> localInvoices) async {
    try {
      for (var invoice in localInvoices) {
        if (!invoice.isSynced) {
          await createInvoice(invoice);
        }
      }
    } catch (e) {
      rethrow;
    }
  }
}