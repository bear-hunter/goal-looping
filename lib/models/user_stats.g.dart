// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_stats.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserStatsAdapter extends TypeAdapter<UserStats> {
  @override
  final int typeId = 20;

  @override
  UserStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserStats(
      totalXP: fields[0] as int,
      coins: fields[1] as int,
      currentStreak: fields[2] as int,
      longestStreak: fields[3] as int,
      lastActiveDate: fields[4] as DateTime?,
      freezeTokens: fields[5] as int,
      unlockedBadgeIds: (fields[6] as List?)?.cast<String>(),
      createdAt: fields[7] as DateTime?,
      xpEarnedToday: fields[8] as int,
      coinsEarnedToday: fields[9] as int,
      actionsToday: fields[10] as int,
      lastResetDate: fields[11] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, UserStats obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.totalXP)
      ..writeByte(1)
      ..write(obj.coins)
      ..writeByte(2)
      ..write(obj.currentStreak)
      ..writeByte(3)
      ..write(obj.longestStreak)
      ..writeByte(4)
      ..write(obj.lastActiveDate)
      ..writeByte(5)
      ..write(obj.freezeTokens)
      ..writeByte(6)
      ..write(obj.unlockedBadgeIds)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.xpEarnedToday)
      ..writeByte(9)
      ..write(obj.coinsEarnedToday)
      ..writeByte(10)
      ..write(obj.actionsToday)
      ..writeByte(11)
      ..write(obj.lastResetDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserStatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
