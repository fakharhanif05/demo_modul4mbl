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
        return UserModel(
          id: response.user!.id,
          email: response.user!.email!,
          createdAt: response.user!.createdAt != null 
              ? DateTime.parse(response.user!.createdAt!) 
              : null,
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
        return UserModel(
          id: response.user!.id,
          email: response.user!.email!,
          createdAt: response.user!.createdAt != null 
              ? DateTime.parse(response.user!.createdAt!) 
              : null,
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
      print('🔄 Creating invoice...');
      print('User ID: ${currentUser?.id}');
      print('Local Invoice ID: ${invoice.id}');

      // Prepare invoice data - include local ID
      final invoiceData = invoice.toSupabase();
      invoiceData['id'] = invoice.id; // Use local UUID
      
      print('Invoice data: $invoiceData');

      // Insert invoice with specific ID
      final result = await client
          .from('invoices')
          .insert(invoiceData)
          .select()
          .single();

      final invoiceId = result['id'].toString();
      print('✓ Invoice created with ID: $invoiceId');

      // Insert invoice items
      if (invoice.items.isNotEmpty) {
        final items = invoice.items.map((item) {
          return {
            'invoice_id': invoiceId,
            ...item.toJson(),
          };
        }).toList();

        print('🔄 Inserting ${items.length} items...');
        await client.from('invoice_items').insert(items);
        print('✓ Items inserted');
      }

      return invoiceId;
    } on PostgrestException catch (e) {
      print('❌ PostgrestException:');
      print('Message: ${e.message}');
      print('Code: ${e.code}');
      print('Details: ${e.details}');
      print('Hint: ${e.hint}');
      rethrow;
    } catch (e) {
      print('❌ Error creating invoice: $e');
      rethrow;
    }
  }

  static Future<List<InvoiceModel>> getInvoices() async {
    try {
      print('🔄 Fetching invoices from Supabase...');
      print('User ID: ${currentUser?.id}');
      print('Is Logged In: $isLoggedIn');
      
      if (currentUser == null) {
        print('❌ No user logged in!');
        return [];
      }

      final data = await client
          .from('invoices')
          .select('*, invoice_items(*)')
          .eq('user_id', currentUser!.id)
          .order('created_at', ascending: false);

      print('✓ Raw data received: ${data.length} invoices');

      if (data.isEmpty) {
        print('⚠️ No invoices found for user ${currentUser!.id}');
        return [];
      }

      final invoices = data.map<InvoiceModel>((json) {
        try {
          print('Processing invoice: ${json['invoice_number']}');
          
          // Parse items from raw JSON
          final itemsJson = json['invoice_items'] as List?;
          final items = itemsJson?.map((item) {
            return InvoiceItem.fromJson(item as Map<String, dynamic>);
          }).toList() ?? [];
          
          print('  - Items count: ${items.length}');
          
          // Create new JSON without invoice_items key
          final invoiceJson = Map<String, dynamic>.from(json);
          invoiceJson.remove('invoice_items');
          
          // Create invoice with items as JSON
          return InvoiceModel.fromJson({
            ...invoiceJson,
            'items': items.map((item) => item.toJson()).toList(),
          });
        } catch (e) {
          print('❌ Error parsing invoice: $e');
          print('   JSON: $json');
          rethrow;
        }
      }).toList();

      print('✓ Successfully parsed ${invoices.length} invoices');
      return invoices;
    } on PostgrestException catch (e) {
      print('❌ PostgrestException on getInvoices:');
      print('Message: ${e.message}');
      print('Code: ${e.code}');
      print('Details: ${e.details}');
      rethrow;
    } catch (e) {
      print('❌ Error fetching invoices: $e');
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

      final itemsJson = data['invoice_items'] as List;
      final items = itemsJson.map((item) {
        return InvoiceItem.fromJson(item as Map<String, dynamic>);
      }).toList();

      final invoiceJson = Map<String, dynamic>.from(data);
      invoiceJson.remove('invoice_items');

      return InvoiceModel.fromJson({
        ...invoiceJson,
        'items': items.map((item) => item.toJson()).toList(),
      });
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateInvoice(String id, InvoiceModel invoice) async {
    try {
      print('🔄 Updating invoice: $id');
      
      // Update invoice
      await client
          .from('invoices')
          .update(invoice.toSupabase())
          .eq('id', id);

      print('✓ Invoice updated');

      // Delete old items first
      await client.from('invoice_items').delete().eq('invoice_id', id);
      print('✓ Old items deleted');

      // Insert new items
      if (invoice.items.isNotEmpty) {
        final items = invoice.items.map((item) {
          return {
            'invoice_id': id,
            ...item.toJson(),
          };
        }).toList();

        await client.from('invoice_items').insert(items);
        print('✓ New items inserted');
      }
    } on PostgrestException catch (e) {
      print('❌ PostgrestException on update:');
      print('Message: ${e.message}');
      print('Code: ${e.code}');
      rethrow;
    } catch (e) {
      print('❌ Error updating invoice: $e');
      rethrow;
    }
  }

  static Future<void> deleteInvoice(String id) async {
    try {
      print('🔄 Deleting invoice: $id');
      
      // Delete items first
      await client.from('invoice_items').delete().eq('invoice_id', id);
      print('✓ Items deleted');
      
      // Delete invoice
      await client.from('invoices').delete().eq('id', id);
      print('✓ Invoice deleted');
    } on PostgrestException catch (e) {
      print('❌ PostgrestException on delete:');
      print('Message: ${e.message}');
      print('Code: ${e.code}');
      rethrow;
    } catch (e) {
      print('❌ Error deleting invoice: $e');
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