import 'package:iconsax/iconsax.dart';
import 'package:listsbysam/app/controller/controller.dart';
import 'package:listsbysam/app/modules/todos/widgets/todos_list.dart';
import 'package:listsbysam/app/widgets/my_delegate.dart';
import 'package:listsbysam/app/widgets/text_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AllTodos extends StatefulWidget {
  const AllTodos({super.key});

  @override
  State<AllTodos> createState() => _AllTodosState();
}

class _AllTodosState extends State<AllTodos> {
  final todoController = Get.put(TodoController());
  TextEditingController searchTodos = TextEditingController();
  String filter = '';

  applyFilter(String value) async {
    filter = value.toLowerCase();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    applyFilter('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'allTasks'.tr,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          physics: const NeverScrollableScrollPhysics(),
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: MyTextForm(
                  labelText: 'searchTodo'.tr,
                  type: TextInputType.text,
                  icon: const Icon(
                    Iconsax.search_normal_1,
                    size: 20,
                  ),
                  controller: searchTodos,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  onChanged: applyFilter,
                  iconButton: searchTodos.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            searchTodos.clear();
                            applyFilter('');
                          },
                          icon: const Icon(
                            Iconsax.close_circle,
                            color: Colors.grey,
                            size: 20,
                          ),
                        )
                      : null,
                ),
              ),
              SliverOverlapAbsorber(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: SliverPersistentHeader(
                  delegate: MyDelegate(
                    TabBar(
                      isScrollable: true,
                      dividerColor: Colors.transparent,
                      splashFactory: NoSplash.splashFactory,
                      overlayColor: MaterialStateProperty.resolveWith<Color?>(
                        (Set<MaterialState> states) {
                          return Colors.transparent;
                        },
                      ),
                      tabs: [
                        Tab(text: 'doing'.tr),
                        Tab(text: 'done'.tr),
                      ],
                    ),
                  ),
                  floating: true,
                  pinned: true,
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              TodosList(
                calendare: false,
                allTodos: true,
                done: false,
                searchTodo: filter,
              ),
              TodosList(
                calendare: false,
                allTodos: true,
                done: true,
                searchTodo: filter,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
