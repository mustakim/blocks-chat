import 'dart:convert';

import 'package:l3_flutter_selise_blocksconstruct/core/utils/typedefs.dart';

class Utils {
  static JSON decodeJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('invalid token');
    }
    final payload = parts[1];
    final String normalized = base64Url.normalize(payload);
    final String resp = utf8.decode(base64Url.decode(normalized));
    final Map<String, dynamic> payloadMap = json.decode(resp);
    return payloadMap;
  }

  // Single static function to group conversations in Dart
  static List<Map<String, dynamic>> groupConversations(List<Map<String, dynamic>> conversations) {
    final Map<String, int> indexGroupIdMap = {};
    final List<Map<String, dynamic>> result = [];
    final now = DateTime.now();
    final currentYear = now.year;

    // Sort conversations by createdDate in descending order
    final sortedConversations = List<Map<String, dynamic>>.from(conversations)
      ..sort((a, b) {
        final dateA = DateTime.parse(a['CreatedDate']);
        final dateB = DateTime.parse(b['CreatedDate']);
        return dateB.compareTo(dateA);
      });

    for (final conversation in sortedConversations) {
      DateTime? createdDate;

      try {
        createdDate = DateTime.parse(conversation['CreatedDate']);
      } catch (e) {
        print('Invalid date for conversation ${conversation['conversationId']}: ${conversation['createdDate']}');
        continue; // Skip invalid dates
      }

      String groupId;
      String groupLabel;

      // Check if date is today
      if (createdDate.year == now.year && createdDate.month == now.month && createdDate.day == now.day) {
        groupId = 'today';
        groupLabel = 'Today';
      }
      // Check if date is yesterday
      else if (createdDate.year == now.subtract(const Duration(days: 1)).year &&
          createdDate.month == now.subtract(const Duration(days: 1)).month &&
          createdDate.day == now.subtract(const Duration(days: 1)).day) {
        groupId = 'yesterday';
        groupLabel = 'Yesterday';
      } else {
        // Calculate difference in days
        final startDate = DateTime(createdDate.year, createdDate.month, createdDate.day);
        final endDate = DateTime(now.year, now.month, now.day);
        final diffInDays = endDate.difference(startDate).inDays;

        if (diffInDays <= 7) {
          groupId = 'week';
          groupLabel = 'Previous 7 Days';
        } else if (diffInDays <= 30) {
          groupId = 'month';
          groupLabel = 'Previous 30 Days';
        } else {
          final year = createdDate.year;

          if (year == currentYear) {
            final monthNumber = createdDate.month;
            final monthNames = [
              'January',
              'February',
              'March',
              'April',
              'May',
              'June',
              'July',
              'August',
              'September',
              'October',
              'November',
              'December'
            ];
            final monthName = monthNames[monthNumber - 1]; // month is 1-based, array is 0-based
            groupId = '$year-${monthNumber.toString().padLeft(2, '0')}'; // Example: "2025-04" for April 2025
            groupLabel = monthName[0].toUpperCase() + monthName.substring(1); // Simple PascalCase
          } else {
            groupId = year.toString();
            groupLabel = year.toString();
          }
        }
      }

      // Create the group if it doesn't exist
      if (!indexGroupIdMap.containsKey(groupId)) {
        indexGroupIdMap[groupId] = result.length;
        result.add({
          'id': groupId,
          'label': groupLabel,
          'items': <Map<String, dynamic>>[],
        });
      }

      result[indexGroupIdMap[groupId]!]['items'].add(conversation);
    }

    return result;
  }
}
