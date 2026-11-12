/// 轻量格式化工具。
///
/// 之所以不直接上 intl：企业应用里 90% 的日期展示只要 `yyyy-MM-dd`，
/// 引一个包换一个函数不划算。等真要做多语言时再换。
String formatDate(DateTime? value, {String placeholder = '—'}) {
  if (value == null) return placeholder;
  final y = value.year.toString().padLeft(4, '0');
  final m = value.month.toString().padLeft(2, '0');
  final d = value.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

/// 相对时间，列表里比绝对日期更有信息量。
String formatRelative(DateTime? value, {String placeholder = '暂无跟进'}) {
  if (value == null) return placeholder;
  final diff = DateTime.now().difference(value);
  if (diff.inMinutes < 1) return '刚刚';
  if (diff.inHours < 1) return '${diff.inMinutes} 分钟前';
  if (diff.inDays < 1) return '${diff.inHours} 小时前';
  if (diff.inDays < 30) return '${diff.inDays} 天前';
  return formatDate(value);
}
