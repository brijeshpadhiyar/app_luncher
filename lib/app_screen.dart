import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DisplayMode {
  grid,
  list,
}

final appsProvider = FutureProvider<List<Application>>((ref) async {
  return DeviceApps.getInstalledApplications(
    includeAppIcons: true,
    onlyAppsWithLaunchIntent: true,
    includeSystemApps: true,
  );
});


final modeProvider = StateProvider<DisplayMode>((ref) {
  return DisplayMode.grid;
});

class AppPage extends StatefulWidget {
  const AppPage({super.key});

  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer(
      builder: (context, ref, child) {
        final appInfo = ref.watch(appsProvider);
        final mode = ref.watch(modeProvider);
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            elevation: 0,
            actionsIconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
            iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
            backgroundColor: Colors.transparent,
            actions: [
              IconButton(
                icon: Icon(mode == DisplayMode.grid ? Icons.list : Icons.grid_on),
                onPressed: () {
                  ref
                      .read(modeProvider.notifier)
                      .update((state) => mode == DisplayMode.grid ? DisplayMode.list : DisplayMode.grid);
                },
              )
            ],
          ),
          body: appInfo.when(
            data: (List<Application> apps) => mode == DisplayMode.list
                ? ListView.builder(
                    itemCount: apps.length,
                    itemBuilder: (context, index) {
                      ApplicationWithIcon app = apps[index] as ApplicationWithIcon;
                      return ListTile(
                        leading: Image.memory(
                          app.icon,
                          width: 40,
                        ),
                        title: Text(app.appName),
                        onTap: () => DeviceApps.openApp(app.packageName),
                      );
                    },
                  )
                : GridView(
                    padding: const EdgeInsets.fromLTRB(16.0, kToolbarHeight + 16.0, 16.0, 16.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    children: [
                      ...apps.map((e) => AppGridItem(
                            application: e as ApplicationWithIcon,
                          ))
                    ],
                  ),
            error: (error, stackTrace) => Container(),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        );
      },
    );
  }
}

class AppGridItem extends StatelessWidget {
  final ApplicationWithIcon? application;
  const AppGridItem({
    this.application,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        DeviceApps.openApp(application!.packageName);
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Image.memory(
              application!.icon,
              fit: BoxFit.contain,
              width: 40,
            ),
          ),
          Text(
            application!.appName,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
