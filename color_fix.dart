import 'dart:io';

void main() {
  // Get all Dart files in the lib directory
  final directory = Directory('lib');
  final files = directory.listSync(recursive: true)
      .where((file) => file.path.endsWith('.dart'))
      .toList();

  int fixedFiles = 0;
  int totalReplacements = 0;

  // Process each file
  for (final file in files) {
    String content = File(file.path).readAsStringSync();
    
    // Skip constants.dart as we've already updated it
    if (file.path.endsWith('constants.dart')) {
      continue;
    }
    
    final originalContent = content;
    
    // Replace AppColors.X with AppColors.current.X
    content = content.replaceAll('AppColors.primary', 'AppColors.current.primary');
    content = content.replaceAll('AppColors.secondary', 'AppColors.current.secondary');
    content = content.replaceAll('AppColors.accent', 'AppColors.current.accent');
    content = content.replaceAll('AppColors.success', 'AppColors.current.success');
    content = content.replaceAll('AppColors.warning', 'AppColors.current.warning');
    content = content.replaceAll('AppColors.error', 'AppColors.current.error');
    content = content.replaceAll('AppColors.danger', 'AppColors.current.danger');
    content = content.replaceAll('AppColors.info', 'AppColors.current.info');
    content = content.replaceAll('AppColors.background', 'AppColors.current.background');
    content = content.replaceAll('AppColors.textLight', 'AppColors.current.textLight');
    content = content.replaceAll('AppColors.textPrimary', 'AppColors.current.textPrimary');
    content = content.replaceAll('AppColors.textSecondary', 'AppColors.current.textSecondary');
    content = content.replaceAll('AppColors.textDark', 'AppColors.current.textDark');
    content = content.replaceAll('AppColors.border', 'AppColors.current.border');
    content = content.replaceAll('AppColors.divider', 'AppColors.current.divider');
    content = content.replaceAll('AppColors.surface', 'AppColors.current.surface');
    content = content.replaceAll('AppColors.cardBackground', 'AppColors.current.cardBackground');
    
    // Avoid double replacements (in case we've already fixed some)
    content = content.replaceAll('AppColors.current.current.', 'AppColors.current.');
    
    // Count replacements
    final replacements = originalContent.length - content.length;
    
    // Only write the file if changes were made
    if (originalContent != content) {
      File(file.path).writeAsStringSync(content);
      fixedFiles++;
      totalReplacements += replacements ~/ 10; // Estimate the number of replacements
      print('Fixed ${file.path} - ~${replacements ~/ 10} replacements');
    }
  }
  
  print('Done! Fixed $fixedFiles files with approximately $totalReplacements total replacements.');
}