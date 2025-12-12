import '../models/category.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';

class CategoryService {
  static final CategoryService instance = CategoryService._init();

  CategoryService._init();

  // Get all categories by type
  Future<List<Category>> getCategoriesByType(String type) async {
    return await DatabaseService.instance.getCategoriesByType(type);
  }

  // Add a new category
  Future<int> addCategory(String name, String type) async {
    // Check if category name already exists for this type
    final exists = await DatabaseService.instance.categoryNameExists(name, type);
    if (exists) {
      throw Exception('Category "$name" already exists for $type');
    }

    final category = Category(
      name: name,
      type: type,
      isDefault: false,
      createdAt: DateTime.now(),
    );

    return await DatabaseService.instance.createCategory(category);
  }

  // Update category name
  Future<bool> updateCategory(int id, String newName) async {
    final category = await DatabaseService.instance.readCategory(id);
    if (category == null) {
      throw Exception('Category not found');
    }

    // Check if new name already exists for this type (excluding current category)
    final exists = await DatabaseService.instance.categoryNameExists(
      newName,
      category.type,
      excludeId: id,
    );
    if (exists) {
      throw Exception('Category "$newName" already exists for ${category.type}');
    }

    final updatedCategory = category.copyWith(name: newName);
    final result = await DatabaseService.instance.updateCategory(updatedCategory);
    return result > 0;
  }

  // Delete a category (only if not default)
  Future<bool> deleteCategory(int id) async {
    final category = await DatabaseService.instance.readCategory(id);
    if (category == null) {
      throw Exception('Category not found');
    }

    if (category.isDefault) {
      throw Exception('Cannot delete default category');
    }

    final result = await DatabaseService.instance.deleteCategory(id);
    return result > 0;
  }

  // Initialize default categories on first run
  Future<void> initializeDefaultCategories() async {
    // This is now handled by the database service during database creation
    // This method is kept for API compatibility but doesn't need to do anything
  }

  // Get all income categories
  Future<List<String>> getIncomeCategoryNames() async {
    final categories = await getCategoriesByType(AppConstants.typeIncome);
    return categories.map((c) => c.name).toList();
  }

  // Get all expense categories
  Future<List<String>> getExpenseCategoryNames() async {
    final categories = await getCategoriesByType(AppConstants.typeExpense);
    return categories.map((c) => c.name).toList();
  }
}
