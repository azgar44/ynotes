part of components;

class ZApp extends StatelessWidget {
  final YPage page;

  const ZApp({Key? key, required this.page}) : super(key: key);

  bool get _showDrawer => responsive<bool>(def: false, md: true);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: theme.colors.backgroundColor,
      child: Row(
        children: [
          if (_showDrawer) SizedBox(height: 100.vh, width: 310, child: const _Drawer()),
          Expanded(
            child: _ConnectionStatus(
              child: YPage(
                key: page.key,
                drawer: Builder(builder: (context) => const _Drawer()),
                appBar: Builder(builder: (context) {
                  if (_showDrawer && Scaffold.of(context).isDrawerOpen) {
                    Future.delayed(const Duration(seconds: 0), () {
                      Scaffold.of(context).openEndDrawer();
                    });
                  }
                  final YAppBar appBar = page.appBar as YAppBar;
                  return YAppBar(
                    title: appBar.title,
                    actions: appBar.actions,
                    bottom: appBar.bottom,
                    leading: YIconButton(
                        icon: Icons.menu_rounded,
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        }),
                    removeLeading: _showDrawer,
                  );
                }),
                body: page.body,
                floatingButtons: page.floatingButtons,
                navigationElements: page.navigationElements,
                navigationInitialIndex: page.navigationInitialIndex,
                scrollable: page.scrollable,
                onRefresh: page.onRefresh,
                useBottomNavigation: page.useBottomNavigation,
                onPageChanged: page.onPageChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
