import 'package:flutter/material.dart';
import '../models/document.dart';
import '../services/database_helper.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class DocumentProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Uuid _uuid = const Uuid();
  
  List<Document> _documents = [];
  bool _isLoading = false;
  
  List<Document> get documents => [..._documents];
  bool get isLoading => _isLoading;
  
  Future<void> loadDocuments(String bikeId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final documentMaps = await _dbHelper.getDocuments(bikeId);
      _documents = documentMaps.map((map) => Document.fromMap(map)).toList();
    } catch (error) {
      debugPrint('Error loading documents: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<Document?> getDocument(String id) async {
    try {
      final document = _documents.firstWhere((doc) => doc.id == id);
      return document;
    } catch (error) {
      debugPrint('Error getting document: $error');
      return null;
    }
  }
  
  Future<bool> addDocument(Document document, File file) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Save file to app's document directory
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '${_uuid.v4()}_${file.path.split('/').last}';
      final savedFile = await file.copy('${appDir.path}/documents/$fileName');
      
      // Create document with path to saved file
      final documentWithPath = document.copyWith(filePath: savedFile.path);
      
      // Insert to database
      final id = await _dbHelper.insertDocument(documentWithPath.toMap());
      final newDocument = documentWithPath.copyWith(id: id);
      
      // Update local list
      _documents.insert(0, newDocument);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      debugPrint('Error adding document: $error');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> updateDocument(Document document, File? newFile) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      Document updatedDocument = document;
      
      // If there's a new file, save it and update path
      if (newFile != null) {
        // Delete old file
        final oldFile = File(document.filePath);
        if (await oldFile.exists()) {
          await oldFile.delete();
        }
        
        // Save new file
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = '${_uuid.v4()}_${newFile.path.split('/').last}';
        final savedFile = await newFile.copy('${appDir.path}/documents/$fileName');
        
        // Update document with new file path
        updatedDocument = document.copyWith(filePath: savedFile.path);
      }
      
      // Update in database
      await _dbHelper.updateDocument(updatedDocument.toMap());
      
      // Update in local list
      final index = _documents.indexWhere((d) => d.id == document.id);
      if (index >= 0) {
        _documents[index] = updatedDocument;
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      debugPrint('Error updating document: $error');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> deleteDocument(String id) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Get document to delete its file
      final document = await getDocument(id);
      if (document != null) {
        // Delete the file
        final file = File(document.filePath);
        if (await file.exists()) {
          await file.delete();
        }
      }
      
      // Delete from database
      await _dbHelper.deleteDocument(id);
      
      // Remove from local list
      _documents.removeWhere((document) => document.id == id);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      debugPrint('Error deleting document: $error');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  List<Document> getDocumentsByType(String bikeId, String documentType) {
    try {
      return _documents.where((doc) => 
        doc.bikeId == bikeId && doc.documentType == documentType).toList();
    } catch (error) {
      debugPrint('Error getting documents by type: $error');
      return [];
    }
  }
  
  List<Document> getExpiringDocuments() {
    return _documents.where((doc) => doc.isExpiringSoon).toList();
  }
  
  List<Document> getExpiredDocuments() {
    return _documents.where((doc) => doc.isExpired).toList();
  }
}
