import 'package:flutter/widgets.dart';

import '../theme/app_spacing.dart';

extension ContextExt on BuildContext {
  EdgeInsets get screenPadding =>
      const EdgeInsets.symmetric(horizontal: AppSpacing.spaceMD);
}
