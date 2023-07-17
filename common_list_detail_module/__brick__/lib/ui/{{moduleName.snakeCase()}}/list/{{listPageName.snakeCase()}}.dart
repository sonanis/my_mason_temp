import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fm2/eventbusbean/event.dart';
import 'package:fm2/extension/export.dart';
import 'package:fm2/model/filter_config.dart';
import 'package:fm2/ui/extraTask/vm/extra_task_list_viewmodel.dart';
import 'package:fm2/ui/extraTask/widgets/extra_task_item.dart';
import 'package:fm2/ui/widgets/appbar_utils.dart';
import 'package:fm2/ui/widgets/card_container.dart';
import 'package:fm2/ui/widgets/content_multiple_state_widget.dart';
import 'package:fm2/ui/widgets/empty_data.dart';
import 'package:fm2/ui/widgets/filter_menu_box_v3.dart';
import 'package:fm2/ui/widgets/filter_menu_table.dart';
import 'package:fm2/ui/widgets/mixin_smart_refresh_state.dart';
import 'package:fm2/ui/widgets/search_box.dart';
import 'package:provider/provider.dart';

/// 创建时间：2022/12/27
/// 作者：LinMingQuan
/// 描述：临时任务/周期任务列表(周期任务改名为日常任务)

class ExtraTaskListPage extends StatefulWidget {

  /// [periodic] true表示周期任务，false表示临时任务
  const ExtraTaskListPage({Key? key, this.periodic = false}) : super(key: key);
  final bool periodic;
  @override
  State<ExtraTaskListPage> createState() => _ExtraTaskListPageState();
}

class _ExtraTaskListPageState extends State<ExtraTaskListPage> with MixinSmartRefreshState {

  final TextEditingController _searchEdit = TextEditingController();
  final FilterController _filterController = FilterController();
  StreamSubscription? _subscription;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).requestFocus(FocusNode());
      },
      behavior: HitTestBehavior.translucent,
      child: ChangeNotifierProvider(
        create: (_) => ExtraTaskListViewModel(widget.periodic)..initial(),
        builder: (ctx, _){
          _subscription ??= eventBus.on<StateChangeEvent>().listen((event) {
            if(event.topic == Topic.extraTask){
              ctx.read<ExtraTaskListViewModel>().updateState(
                event.id,
                state: event.state,
                stateLabel: event.stateLabel,
              );
            }
          });
          return Scaffold(
            appBar: AppBarUtils.appBar(titleText: '综合任务'),
            resizeToAvoidBottomInset: false,
            body: ContentMultStateWidget(
              control: ctx.read<ExtraTaskListViewModel>().initCtrl,
              contentBuilder: (_){
                return _buildContent();
              },
              onEmptyTap: (_){
                ctx.read<ExtraTaskListViewModel>().initial();
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(){
    return Column(
      children: [
        _buildFilterBar(),
        Expanded(child: _buildListView()),
      ],
    );
  }


  ValueNotifier<NodebeanFilterCondition> tempTimeRangeMenu = ValueNotifier(NodebeanFilterCondition());
  ValueNotifier<NodebeanFilterCondition> tempExceptionMenu = ValueNotifier(NodebeanFilterCondition());
  ValueNotifier<NodebeanFilterCondition> tempStateMenu = ValueNotifier(NodebeanFilterCondition());
  Widget _buildFilterBar(){
    return Builder(
      builder: (ctx) {
        return DividerContainer(
          child: FilterMenuBox(
            filterController: _filterController,
            child: SearchBox(
              hint: "搜索",
              cancelOffstage: true,
              controller: _searchEdit,
              onSubmit: (text){
                ctx.read<ExtraTaskListViewModel>().search(text);
              },
              onClean: (){
                ctx.read<ExtraTaskListViewModel>().search(null);
              },
            ),
            onPopupShowing: (){
              tempTimeRangeMenu.value = ctx.read<ExtraTaskListViewModel>().timeRangeMenu.copy() as NodebeanFilterCondition;
              tempExceptionMenu.value = ctx.read<ExtraTaskListViewModel>().exceptionMenu.copy() as NodebeanFilterCondition;
              tempStateMenu.value = ctx.read<ExtraTaskListViewModel>().stateMenu.copy() as NodebeanFilterCondition;
            },
            filterTypes: [
              FilterTypeItem(name: '筛选',
                dropDown: true,
                child: FilterMenuPanel(
                  child: Column(
                    children: [

                      ///任务时间
                      ValueListenableBuilder<NodebeanFilterCondition>(
                        valueListenable: tempTimeRangeMenu,
                        builder: (_, condition, __){
                          return FilterMenuTable(
                            name: condition.name,
                            selected: condition.selected,
                            layoutType: LayoutType.Table,
                            onTap: (bean){
                              tempTimeRangeMenu.value.selectNode(bean);
                              tempTimeRangeMenu.notifyListeners();
                              // _selectedExceptionMenu.toggle(bean, clean: true, emptyAble: false);
                            },
                            menus: condition.data ?? [],
                          );
                        },
                      ),

                      /// 异常状态
                      ValueListenableBuilder<NodebeanFilterCondition>(
                        valueListenable: tempExceptionMenu,
                        builder: (_, condition, __){
                          return FilterMenuTable(
                            name: condition.name,
                            selected: condition.selected,
                            layoutType: LayoutType.Table,
                            onTap: (bean){
                              tempExceptionMenu.value.selectNode(bean);
                              tempExceptionMenu.notifyListeners();
                              // _selectedExceptionMenu.toggle(bean, clean: true, emptyAble: false);
                            },
                            menus: condition.data ?? [],
                          );
                        },
                      ),

                      /// 工单状态
                      ValueListenableBuilder<NodebeanFilterCondition>(
                        valueListenable: tempStateMenu,
                        builder: (_, condition, __){
                          return FilterMenuTable(
                            name: condition.name,
                            selected: condition.selected,
                            layoutType: LayoutType.Table,
                            onTap: (bean){
                              tempStateMenu.value.selectNode(bean);
                              tempStateMenu.notifyListeners();
                              // _selectedExceptionMenu.toggle(bean, clean: true, emptyAble: false);
                            },
                            menus: condition.data ?? [],
                          );
                        },
                      ),

                      Container(height: 40.px(),),
                    ],
                  ),
                  text1: '重置',
                  text2: '确定',
                  onTap1: () async {
                    _filterController.cancel();
                    refreshController.requestRefresh(needCallback: false);
                    await ctx.read<ExtraTaskListViewModel>().setFilter();
                    refreshController.refreshCompleted();
                  },
                  onTap2: () async {
                    _filterController.cancel();
                    refreshController.requestRefresh(needCallback: false);
                    await ctx.read<ExtraTaskListViewModel>().setFilter(
                      time: tempTimeRangeMenu.value,
                      exception: tempExceptionMenu.value,
                      state: tempStateMenu.value,
                    );
                    refreshController.refreshCompleted();
                  },
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildListView(){
    return Builder(builder: (ctx){
      return Selector<ExtraTaskListViewModel, List>(
        selector: (_, model) => model.data,
        shouldRebuild: (pre, next) => pre != next,
        builder: (_, list, __){
          Widget? listView;
          if(!list.isNullOrEmpty()){
            listView = ListView.builder(
              itemCount: list.length,
                itemBuilder: (ctx, index){
              return ExtraTaskItemWidget(list[index]);
            });
          }
          return buildSmartRefresh(listView ?? EmptyDataWidget(),
            onRefresh: () async {
              await ctx.read<ExtraTaskListViewModel>().load(refresh: true);
              refreshController.refreshCompleted();
            },
            onLoading: () async {
              await ctx.read<ExtraTaskListViewModel>().load();
              refreshController.loadComplete();
            }
          );
        },
      );
    });
  }
}
