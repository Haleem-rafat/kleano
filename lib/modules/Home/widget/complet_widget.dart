import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:thewhsherbiker/core/resources/app_styles.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/modules/Home/bloc/home_bloc.dart';
import 'package:thewhsherbiker/modules/Home/screens/empty_screen.dart';
import 'package:thewhsherbiker/modules/Home/widget/completed_card.dart';
import 'package:thewhsherbiker/shared/components/loading.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';

class CompleteWidget extends StatefulWidget {
  const CompleteWidget({super.key});

  @override
  State<CompleteWidget> createState() => _CompleteWidgetState();
}

class _CompleteWidgetState extends State<CompleteWidget> {
  RefreshController refreshControllers = RefreshController();

  @override
  void initState() {
    super.initState();
    sl<HomeBloc>().add(BikerGetOrdersComplete());
  }

  @override
  void dispose() {
    refreshControllers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      bloc: sl<HomeBloc>(),
      listener: (BuildContext context, HomeState state) {
        if (state is BikerGetOrdersCompleteSuccess) {
          refreshControllers.loadComplete();
        }
      },
      builder: (BuildContext context, HomeState state) {
        if (state is BikerGetOrdersCompleteLoading) {
          return const LoadingWidget();
        } else if (state is BikerGetOrdersCompleteEmpty ||
            state is BikerGetOrdersCompleteFailed) {
          return EmptyScreen(
            notification: false,
            text: AppStrings.letYouKnow,
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "${sl<HomeBloc>().completeTotalLength} ${translate(AppStrings.requests)}",
                style: AppStyles.body14Medium.copyWith(
                  color: ColorManager.darkGrey,
                ),
              ),
              SizedBox(
                height: 7.h,
              ),
              Expanded(
                child: SmartRefresher(
                  enablePullDown: false,
                  controller: refreshControllers,
                  enablePullUp: true,
                  header: const ClassicHeader(
                    refreshStyle: RefreshStyle.UnFollow,
                  ),
                  footer: CustomFooter(
                    builder: (BuildContext context, LoadStatus? mode) {
                      Widget body;
                      if (mode == LoadStatus.idle) {
                        body = Container();
                      } else if (mode == LoadStatus.loading) {
                        body = const LoadingWidget();
                      } else if (mode == LoadStatus.failed) {
                        body = const Text("Load Failed!Click retry!");
                      } else if (mode == LoadStatus.canLoading) {
                        body = const Text("release to load more");
                      } else {
                        body = const Text("No more Data");
                      }
                      return SizedBox(
                        height: 55.0,
                        child: Center(child: body),
                      );
                    },
                  ),
                  onLoading: () {
                    sl<HomeBloc>().add(BikerGetOrdersCompletePagination());
                  },
                  child: ListView.separated(
                    itemCount: sl<HomeBloc>().completeList.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(
                        height: 16.h,
                      );
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return CompletedCard(
                        order: sl<HomeBloc>().completeList[index],
                      );
                    },
                  ),
                ),
              )
            ],
          );
        }
      },
    );
  }
}
