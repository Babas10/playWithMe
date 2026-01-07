// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurrence_rule_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RecurrenceRuleModelImpl _$$RecurrenceRuleModelImplFromJson(
  Map<String, dynamic> json,
) => _$RecurrenceRuleModelImpl(
  frequency:
      $enumDecodeNullable(_$RecurrenceFrequencyEnumMap, json['frequency']) ??
      RecurrenceFrequency.none,
  interval: (json['interval'] as num?)?.toInt() ?? 1,
  count: (json['count'] as num?)?.toInt(),
  endDate: _dateTimeFromJson(json['endDate'] as String?),
  daysOfWeek: (json['daysOfWeek'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
);

Map<String, dynamic> _$$RecurrenceRuleModelImplToJson(
  _$RecurrenceRuleModelImpl instance,
) => <String, dynamic>{
  'frequency': _$RecurrenceFrequencyEnumMap[instance.frequency]!,
  'interval': instance.interval,
  'count': instance.count,
  'endDate': _dateTimeToJson(instance.endDate),
  'daysOfWeek': instance.daysOfWeek,
};

const _$RecurrenceFrequencyEnumMap = {
  RecurrenceFrequency.none: 'none',
  RecurrenceFrequency.weekly: 'weekly',
  RecurrenceFrequency.monthly: 'monthly',
};
