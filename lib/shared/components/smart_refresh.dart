import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:thewasher/shared/components/loading.dart';

class SmartRefresherCustomWidget extends StatelessWidget {
  final RefreshController? refreshController;
  final VoidCallback? onRefresh;
  final VoidCallback? onLoading;
  final Widget? child;
  final bool? enablePullUp;
  final bool? enablePullDown;
  const SmartRefresherCustomWidget({
    Key? key,
    this.refreshController,
    this.onRefresh,
    this.onLoading,
    this.child,
    this.enablePullUp = true,
    this.enablePullDown = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
        controller: refreshController!,
        enablePullUp: enablePullUp!,
        enablePullDown: enablePullDown!,
        // header: const ClassicHeader(
        //   refreshStyle: RefreshStyle.UnFollow,
        // ),
        onRefresh: onRefresh,
        onLoading: onLoading,
        footer: CustomFooter(
          builder: (BuildContext context, LoadStatus? mode) {
            Widget body;
            if (mode == LoadStatus.idle) {
              body = Container();
            } else if (mode == LoadStatus.loading) {
              body = const LoadingWidget();
            } else if (mode == LoadStatus.failed) {
              body = const Text("Load Failed!Click retry!");
            } else {
              // body = const Text("No more Data");
              body = const SizedBox();
            }
            return SizedBox(
              height: 55.0.h,
              child: Center(child: body),
            );
          },
        ),
        child: child!);
  }
}
