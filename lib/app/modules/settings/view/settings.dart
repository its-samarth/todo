import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:listsbysam/app/controller/controller.dart';
import 'package:listsbysam/app/data/schema.dart';
import 'package:listsbysam/app/modules/settings/widgets/settings_card.dart';
import 'package:listsbysam/main.dart';
import 'package:listsbysam/theme/theme_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final todoController = Get.put(TodoController());
  final themeController = Get.put(ThemeController());
  String? appVersion;

  Future<void> infoVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
    });
  }

  updateLanguage(Locale locale) {
    settings.language = '$locale';
    isar.writeTxn(() async => isar.settings.put(settings));
    Get.updateLocale(locale);
    Get.back();
  }

  @override
  void initState() {
    infoVersion();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'settings'.tr,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SettingCard(
              icon: const Icon(Iconsax.brush_1),
              text: 'appearance'.tr,
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                      builder: (BuildContext context, setState) {
                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 15),
                                child: Text(
                                  'appearance'.tr,
                                  style: context.textTheme.titleLarge?.copyWith(
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              SettingCard(
                                elevation: 4,
                                icon: const Icon(Iconsax.moon),
                                text: 'theme'.tr,
                                switcher: true,
                                value: Get.isDarkMode,
                                onChange: (_) {
                                  if (Get.isDarkMode) {
                                    themeController
                                        .changeThemeMode(ThemeMode.light);
                                    themeController.saveTheme(false);
                                  } else {
                                    themeController
                                        .changeThemeMode(ThemeMode.dark);
                                    themeController.saveTheme(true);
                                  }
                                },
                              ),
                              SettingCard(
                                elevation: 4,
                                icon: const Icon(Iconsax.mobile),
                                text: 'amoledTheme'.tr,
                                switcher: true,
                                value: settings.amoledTheme,
                                onChange: (value) {
                                  themeController.saveOledTheme(value);
                                  MyApp.updateAppState(context,
                                      newAmoledTheme: value);
                                },
                              ),
                              SettingCard(
                                elevation: 4,
                                icon: const Icon(Iconsax.colorfilter),
                                text: 'materialColor'.tr,
                                switcher: true,
                                value: settings.materialColor,
                                onChange: (value) {
                                  themeController.saveMaterialTheme(value);
                                  MyApp.updateAppState(context,
                                      newMaterialColor: value);
                                },
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
            SettingCard(
              icon: const Icon(Iconsax.code),
              text: 'functions'.tr,
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                      builder: (BuildContext context, setState) {
                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 15),
                                child: Text(
                                  'functions'.tr,
                                  style: context.textTheme.titleLarge?.copyWith(
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              SettingCard(
                                elevation: 4,
                                icon: const Icon(Iconsax.cloud_plus),
                                text: 'backup'.tr,
                                onPressed: todoController.backup,
                              ),
                              SettingCard(
                                elevation: 4,
                                icon: const Icon(Iconsax.cloud_add),
                                text: 'restore'.tr,
                                onPressed: todoController.restore,
                              ),
                              SettingCard(
                                elevation: 4,
                                icon: const Icon(Iconsax.cloud_minus),
                                text: 'deleteAllBD'.tr,
                                onPressed: () => Get.dialog(
                                  AlertDialog(
                                    title: Text(
                                      'deleteAllBDTitle'.tr,
                                      style: context.textTheme.titleLarge,
                                    ),
                                    content: Text(
                                      'deleteAllBDQuery'.tr,
                                      style: context.textTheme.titleMedium,
                                    ),
                                    actions: [
                                      TextButton(
                                          onPressed: () => Get.back(),
                                          child: Text('cancel'.tr,
                                              style: context
                                                  .theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                      color:
                                                          Colors.blueAccent))),
                                      TextButton(
                                          onPressed: () async {
                                            await isar.writeTxn(() async {
                                              await isar.todos.clear();
                                              await isar.tasks.clear();
                                              todoController.tasks.clear();
                                              todoController.todos.clear();
                                            });
                                            EasyLoading.showSuccess(
                                                'deleteAll'.tr);
                                            Get.back();
                                          },
                                          child: Text('delete'.tr,
                                              style: context
                                                  .theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                      color: Colors.red))),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
            SettingCard(
              icon: const Icon(Iconsax.language_square),
              text: 'language'.tr,
              info: true,
              infoSettings: true,
              textInfo: appLanguages.firstWhere(
                  (element) => (element['locale'] == locale),
                  orElse: () => appLanguages.first)['name'],
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                      builder: (BuildContext context, setState) {
                        return ListView(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              child: Text(
                                'language'.tr,
                                style: context.textTheme.titleLarge?.copyWith(
                                  fontSize: 20,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              itemCount: appLanguages.length,
                              itemBuilder: (context, index) {
                                return Card(
                                  elevation: 4,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 5),
                                  child: ListTile(
                                    title: Center(
                                      child: Text(
                                        appLanguages[index]['name'],
                                        style: context.textTheme.labelLarge,
                                      ),
                                    ),
                                    onTap: () {
                                      MyApp.updateAppState(context,
                                          newLocale: appLanguages[index]
                                              ['locale']);
                                      updateLanguage(
                                          appLanguages[index]['locale']);
                                    },
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
            SettingCard(
              icon: const Icon(Iconsax.hierarchy_square_2),
              text: 'version'.tr,
              info: true,
              textInfo: '$appVersion',
            ),
            SettingCard(
              icon: Image.asset(
                'assets/images/github.png',
                scale: 20,
              ),
              text: '${'project'.tr} GitHub',
              onPressed: () async {
                final Uri url =
                    Uri.parse('https://github.com/DarkMooNight/listsbysam');
                if (!await launchUrl(url,
                    mode: LaunchMode.externalApplication)) {
                  throw Exception('Could not launch $url');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
