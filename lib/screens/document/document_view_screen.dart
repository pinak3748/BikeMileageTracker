import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../models/document.dart';
import '../../providers/document_provider.dart';
import '../../utils/constants.dart';
import '../../utils/date_formatter.dart';

class DocumentViewScreen extends StatefulWidget {
  final Document document;

  const DocumentViewScreen({
    super.key,
    required this.document,
  });

  @override
  State<DocumentViewScreen> createState() => _DocumentViewScreenState();
}

class _DocumentViewScreenState extends State<DocumentViewScreen> {
  bool _isLoading = false;
  bool _fileExists = false;
  late String _fileName;
  late String _fileExtension;

  @override
  void initState() {
    super.initState();
    _checkFile();
  }

  Future<void> _checkFile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final file = File(widget.document.filePath);
      _fileExists = await file.exists();
      _fileName = path.basename(widget.document.filePath);
      _fileExtension = path.extension(widget.document.filePath).toLowerCase();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error checking file: $error'),
          backgroundColor: AppColors.current.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteDocument() async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Document'),
        content: const Text(
          'Are you sure you want to delete this document? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Delete',
              style: TextStyle(color: AppColors.current.danger),
            ),
          ),
        ],
      ),
    );

    if (confirmDelete != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final documentProvider = Provider.of<DocumentProvider>(context, listen: false);
      await documentProvider.deleteDocument(widget.document.id!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Document deleted successfully'),
            backgroundColor: AppColors.current.success,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting document: $error'),
            backgroundColor: AppColors.current.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteDocument,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.current.accent))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Document title and type
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.document.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Chip(
                                label: Text(widget.document.documentType),
                                backgroundColor: _getDocumentTypeColor(widget.document.documentType).withOpacity(0.2),
                                labelStyle: TextStyle(
                                  color: _getDocumentTypeColor(widget.document.documentType),
                                ),
                              ),
                              const Spacer(),
                              if (widget.document.isExpired)
                                Chip(
                                  label: const Text('Expired'),
                                  backgroundColor: AppColors.current.danger.withOpacity(0.2),
                                  labelStyle: TextStyle(
                                    color: AppColors.current.danger,
                                  ),
                                ),
                              if (widget.document.isExpiringSoon && !widget.document.isExpired)
                                Chip(
                                  label: const Text('Expiring Soon'),
                                  backgroundColor: AppColors.current.warning.withOpacity(0.2),
                                  labelStyle: TextStyle(
                                    color: AppColors.current.warning,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Dates
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                            'Date Added',
                            DateFormatter.formatDate(widget.document.date),
                            Icons.calendar_today,
                          ),
                          if (widget.document.expiryDate != null)
                            _buildInfoRow(
                              'Expiry Date',
                              DateFormatter.formatDate(widget.document.expiryDate!),
                              Icons.event_busy,
                              color: widget.document.isExpired
                                  ? AppColors.current.danger
                                  : widget.document.isExpiringSoon
                                      ? AppColors.current.warning
                                      : null,
                            ),
                          if (widget.document.expiryDate != null) ...[
                            const SizedBox(height: 8),
                            _buildDaysLeftIndicator(),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // File info
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'File Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                            'File Name',
                            _fileName,
                            Icons.insert_drive_file,
                          ),
                          _buildInfoRow(
                            'File Status',
                            _fileExists ? 'Available' : 'Missing',
                            _fileExists ? Icons.check_circle : Icons.error,
                            color: _fileExists ? AppColors.current.success : AppColors.current.danger,
                          ),
                          if (_fileExists) ...[
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.visibility),
                                label: const Text('View Document'),
                                onPressed: _handleViewDocument,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Notes
                  if (widget.document.notes != null && widget.document.notes!.isNotEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notes',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.text,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              widget.document.notes!,
                              style: TextStyle(
                                color: AppColors.text,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: color ?? AppColors.current.textLight,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.current.textLight,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color ?? AppColors.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaysLeftIndicator() {
    if (widget.document.expiryDate == null) return const SizedBox();
    
    final daysLeft = widget.document.expiryDate!.difference(DateTime.now()).inDays;
    
    Color statusColor;
    String statusText;
    
    if (daysLeft < 0) {
      statusColor = AppColors.current.danger;
      statusText = 'Expired ${-daysLeft} days ago';
    } else if (daysLeft <= 30) {
      statusColor = AppColors.current.warning;
      statusText = 'Expires in $daysLeft days';
    } else {
      statusColor = AppColors.current.success;
      statusText = 'Expires in $daysLeft days';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(
            daysLeft < 0 ? Icons.warning : Icons.access_time,
            color: statusColor,
            size: 20,
          ),
          const SizedBox(width: 16),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _handleViewDocument() {
    // This would open the document in a relevant viewer
    // For this app version, we'll just show a dialog with file info
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('View Document'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Document: ${widget.document.title}'),
            const SizedBox(height: 8),
            Text('File path: ${widget.document.filePath}'),
            const SizedBox(height: 16),
            const Text(
              'Note: Document viewing functionality would be implemented with a file viewer specific to the file type. For security reasons, we limit direct file access in this version.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Color _getDocumentTypeColor(String docType) {
    switch (docType) {
      case 'Insurance':
        return Colors.blue;
      case 'Registration':
        return Colors.green;
      case 'Service Manual':
        return Colors.orange;
      case 'Warranty':
        return Colors.purple;
      case 'Purchase Receipt':
        return Colors.teal;
      default:
        return AppColors.current.primary;
    }
  }
}
