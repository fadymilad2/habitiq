import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habit_iq/core/data/services/hive_service.dart';
import 'package:habit_iq/features/habit/data/models/habit_model.dart';
import 'package:habit_iq/features/profile/data/models/user_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:developer';

class SyncRepository {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Pushes all local habits AND user profile to Firestore.
  /// Replaces existing cloud documents with current local state.
  static Future<void> pushToCloud(
    String userId,
    List<HabitModel> localHabits, {
    UserModel? userModel,
  }) async {
    try {
      final userDocRef = _firestore.collection('users').doc(userId);
      final habitsCollection = userDocRef.collection('habits');

      // Push user profile if provided
      if (userModel != null) {
        await userDocRef.set({
          'id': userModel.id,
          'name': userModel.name,
          'avatarPath': userModel.avatarPath,
          'level': userModel.level,
          'xp': userModel.xp,
          'streakCount': userModel.streakCount,
          'createdAt': userModel.createdAt.toIso8601String(),
        }, SetOptions(merge: true));
      }

      // Push habits using a WriteBatch
      final batch = _firestore.batch();

      // Delete existing cloud habits first (clean overwrite)
      final existingDocs = await habitsCollection.get();
      for (var doc in existingDocs.docs) {
        batch.delete(doc.reference);
      }

      // Add all local habits
      for (final habit in localHabits) {
        final docRef = habitsCollection.doc(habit.id);
        batch.set(docRef, habit.toMap());
      }

      await batch.commit();
      log(
        'SyncRepository: Pushed ${localHabits.length} habits and user profile for $userId',
      );
    } catch (e) {
      log('SyncRepository: pushToCloud failed: $e');
      rethrow; // Re-throw so the UI can show an error message
    }
  }

  /// Pulls all habits and user profile from Firestore and overwrites local Hive.
  static Future<void> pullFromCloud(
    String userId,
    Box<HabitModel> habitsBox, {
    Box<UserModel>? userBox,
  }) async {
    try {
      final userDocRef = _firestore.collection('users').doc(userId);

      // Pull user profile
      if (userBox != null) {
        final userSnap = await userDocRef.get();
        if (userSnap.exists && userSnap.data() != null) {
          final data = userSnap.data()!;
          final cloudUser = UserModel(
            id: userId,
            name: data['name'] as String? ?? 'User',
            avatarPath: data['avatarPath'] as String?,
            level: data['level'] as int? ?? 1,
            xp: data['xp'] as int? ?? 0,
            streakCount: data['streakCount'] as int? ?? 0,
            createdAt: data['createdAt'] != null
                ? DateTime.parse(data['createdAt'] as String)
                : DateTime.now(),
          );
          // Save user to Hive under their userId key
          await userBox.put(userId, cloudUser);
          // CRITICAL: also set the active pointer so UserRepositoryImpl.getCurrentUser() works
          await HiveService.settingsBox.put('active_user_id', userId);
          log('SyncRepository: Pulled user profile from cloud for $userId');
        } else {
          // No cloud profile yet — still set the active_user_id so a local
          // profile created later is correctly linked to this user.
          await HiveService.settingsBox.put('active_user_id', userId);
          log(
            'SyncRepository: No cloud user profile for $userId (first time login)',
          );
        }
      }

      // Pull habits
      final habitsSnap = await userDocRef.collection('habits').get();
      if (habitsSnap.docs.isNotEmpty) {
        final cloudHabits = habitsSnap.docs.map((doc) {
          return HabitModel.fromMap(doc.data(), doc.id);
        }).toList();

        await habitsBox.clear();
        final mapToSave = {for (var h in cloudHabits) h.id: h};
        await habitsBox.putAll(mapToSave);
        log('SyncRepository: Pulled ${cloudHabits.length} habits for $userId');
      } else {
        log(
          'SyncRepository: No cloud habits for $userId (new user or empty cloud)',
        );
      }
    } catch (e) {
      log('SyncRepository: pullFromCloud failed: $e');
      // Don't rethrow on pull — just let local data stay as-is
    }
  }
}
