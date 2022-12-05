import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../model/widget_settings.dart';
import '../resources/storage_keys.dart';
import '../utils/storage_manager.dart';
import '../utils/utils.dart';
import 'widgets/analog_clock_widget.dart';
import 'widgets/digital_clock_widget.dart';
import 'widgets/message_widget.dart';

abstract class WidgetModelBase with ChangeNotifier, LazyInitializationMixin {
  WidgetType type = WidgetType.none;

  late DigitalClockWidgetSettings digitalClockSettings;
  late AnalogClockWidgetSettings analogueClockSettings;
  late MessageWidgetSettings messageSettings;

  void setType(WidgetType type);

  void updateDigitalClockSettings(DigitalClockWidgetSettings settings);

  void updateAnalogClockSettings(AnalogClockWidgetSettings settings);

  void updateMessageSettings(MessageWidgetSettings settings,
      {bool save = true});
}

class WidgetModel extends WidgetModelBase {
  late final LocalStorageManager storage =
      GetIt.instance.get<LocalStorageManager>();

  @override
  Future<void> init() async {
    type = await storage.getEnum<WidgetType>(
            StorageKeys.widgetType, WidgetType.values) ??
        WidgetType.digitalClock;

    digitalClockSettings =
        await storage.getSerializableObject<DigitalClockWidgetSettings>(
                StorageKeys.digitalClockSettings,
                DigitalClockWidgetSettings.fromJson) ??
            DigitalClockWidgetSettings();

    analogueClockSettings =
        await storage.getSerializableObject<AnalogClockWidgetSettings>(
                StorageKeys.analogueClockSettings,
                AnalogClockWidgetSettings.fromJson) ??
            AnalogClockWidgetSettings();

    messageSettings =
        await storage.getSerializableObject<MessageWidgetSettings>(
                StorageKeys.messageSettings, MessageWidgetSettings.fromJson) ??
            MessageWidgetSettings();

    initialized = true;
    notifyListeners();
  }

  @override
  void setType(WidgetType type) {
    this.type = type;
    storage.setEnum(StorageKeys.widgetType, type);
    notifyListeners();
  }

  @override
  void updateDigitalClockSettings(DigitalClockWidgetSettings settings) {
    digitalClockSettings = settings;
    storage.setJson(StorageKeys.digitalClockSettings, settings.toJson());
    notifyListeners();
  }

  @override
  void updateAnalogClockSettings(AnalogClockWidgetSettings settings) {
    analogueClockSettings = settings;
    storage.setJson(StorageKeys.analogueClockSettings, settings.toJson());
    notifyListeners();
  }

  @override
  void updateMessageSettings(MessageWidgetSettings settings,
      {bool save = false}) {
    messageSettings = settings;
    if (save) storage.setJson(StorageKeys.messageSettings, settings.toJson());
    notifyListeners();
  }
}

class HomeWidget extends StatelessWidget {
  const HomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WidgetModelBase>(
      builder: (context, model, child) {
        switch (model.type) {
          case WidgetType.digitalClock:
            return const DigitalClockWidget();
          case WidgetType.analogClock:
            return const AnalogClockWidget();
          case WidgetType.text:
            return const MessageWidget();
          case WidgetType.none:
            return const SizedBox.shrink();
        }
      },
    );
  }
}
